//sport.js
import express from "express";
import pool from "../db.js";
// [TODO] เพิ่ม middleware ตรวจสอบ token ถ้ามี

const router = express.Router();

// 1. GET: ดึง Category (หน้า Home)
// [FIX] แก้ไขให้รับ studentId และใช้ SQL query ใหม่
router.get("/categories", async (req, res) => {
  try {
    const { studentId } = req.query; // รับ studentId จาก app
    if (!studentId) {
      return res.status(400).json({ success: false, message: "Missing studentId" });
    }

    // [FIX] ใช้ SQL ใหม่ที่ JOIN เพื่อตรวจสอบสถานะ Pending ของ "ฉัน"
    const [rows] = await pool.query(
      `SELECT 
          sc.category_id,
          sc.category_name,
          sc.category_image,
          SUM(CASE WHEN si.status = 'Available' THEN 1 ELSE 0 END) AS available_count,
          CASE
              -- 1. ถ้ามี 'Available' = 'Available'
              WHEN SUM(CASE WHEN si.status = 'Available' THEN 1 ELSE 0 END) > 0 THEN 'Available'
              
              -- 2. ถ้าไม่มี 'Available' แต่มี 'Pending' โดย "ฉัน" = 'Pending'
              WHEN SUM(CASE WHEN si.status = 'Pending' AND br.student_id = ? THEN 1 ELSE 0 END) > 0 
                   AND SUM(CASE WHEN si.status = 'Available' THEN 1 ELSE 0 END) = 0 THEN 'Pending'
              
              -- 3. ถ้าไม่มี 'Available' หรือ 'Pending โดยฉัน' แต่มี 'Borrowed' = 'Borrowed'
              WHEN SUM(CASE WHEN si.status = 'Borrowed' THEN 1 ELSE 0 END) > 0 
                   AND SUM(CASE WHEN si.status IN ('Available') THEN 1 ELSE 0 END) = 0 
                   AND SUM(CASE WHEN si.status = 'Pending' AND br.student_id = ? THEN 1 ELSE 0 END) = 0 THEN 'Borrowed'
              
              -- 4. นอกนั้น (เช่น Pending โดยคนอื่น, Disable ล้วน, หรือของหมด) = 'Disable'
              ELSE 'Disable'
          END AS category_status
      FROM sport_category sc
      LEFT JOIN sport_item si ON sc.category_id = si.category_id
      LEFT JOIN borrow_request br ON si.item_id = br.item_id AND br.request_status = 'Pending'
      GROUP BY sc.category_id, sc.category_name, sc.category_image`,
      [studentId, studentId] // ส่ง studentId เข้า SQL 2 ครั้ง
    );
    
    res.json({ success: true, data: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// 2. GET: ดึง Item (หน้ารายละเอียด)
// [FIX] แก้ไขให้รับ studentId และใช้ SQL query ใหม่
router.get("/items/:categoryId", async (req, res) => {
  try {
    const { categoryId } = req.params;
    const { studentId } = req.query; // รับ studentId จาก app
    if (!studentId) {
      return res.status(400).json({ success: false, message: "Missing studentId" });
    }

    // [FIX] ใช้ SQL ใหม่ที่ JOIN และมี CASE
    const [rows] = await pool.query(
      `SELECT 
        si.item_id, 
        si.category_id, 
        si.item_name, 
        si.item_image, 
        -- Logic: ถ้า 'Pending' โดยคนอื่น ให้ส่ง 'Disable' กลับไปแทน
        CASE 
          WHEN si.status = 'Pending' AND br.student_id = ? THEN 'Pending'
          WHEN si.status = 'Pending' AND br.student_id != ? THEN 'Disable'
          ELSE si.status
        END AS status
      FROM sport_item si
      LEFT JOIN borrow_request br ON si.item_id = br.item_id AND br.request_status = 'Pending'
      WHERE si.category_id = ?`,
      [studentId, studentId, categoryId] // ส่ง studentId 2 ครั้ง, categoryId 1 ครั้ง
    );
    
    res.json({ success: true, data: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});


// 3. POST: สร้างคำขอยืมใหม่ (Borrow Request) - (โค้ดเดิมที่แก้แล้ว)
// 3. POST: สร้างคำขอยืมใหม่ (Borrow Request)
// 3. POST: สร้างคำขอยืมใหม่ (Borrow Request)
router.post("/borrow/request", async (req, res) => {
  const { student_id, item_id, return_date } = req.body;

  if (!student_id || !item_id || !return_date) {
    return res
      .status(400)
      .json({ success: false, message: "Missing fields" });
  }

  try {
    const today = new Date().toISOString().split("T")[0];

const [activeBorrow] = await pool.query(
  `SELECT request_id, item_id, request_status, return_date, actual_return_date
   FROM borrow_request
   WHERE student_id = ?
     AND request_status = 'Approved'       -- ได้รับอนุมัติแล้วยังถือของอยู่
     AND (actual_return_date IS NULL OR actual_return_date = '')  -- ยังไม่คืนจริง
     AND return_date >= ?                  -- ยังไม่ถึงวันครบกำหนดคืน
  `,
  [student_id, today]
);

console.log("📦 Borrow limit check for student", student_id, "=>", activeBorrow);

if (activeBorrow.length > 0) {
  return res.status(400).json({
    success: false,
    message: "You have already borrowed the item!! Please return and you can borrow again.",
  });
}
    // ✅ 2. ตรวจว่าสินค้าชิ้นนี้ถูกยืมอยู่ไหม
    const [itemRows] = await pool.query(
      "SELECT status FROM sport_item WHERE item_id = ?",
      [item_id]
    );

    if (!itemRows.length) {
      return res
        .status(404)
        .json({ success: false, message: "Item not found" });
    }

    if (itemRows[0].status.toLowerCase() === "borrowed") {
      return res.status(400).json({
        success: false,
        message: "Item already borrowed",
      });
    }

    // ✅ 3. ป้องกันการยื่นคำขอ Pending ซ้ำ (ตัวใหญ่!)
    const [pendingCheck] = await pool.query(
      `SELECT COUNT(*) AS cnt
       FROM borrow_request
       WHERE student_id = ?
         AND request_status = 'Pending'`,
      [student_id]
    );

    if (pendingCheck[0].cnt > 0) {
      return res.status(400).json({
        success: false,
        message: "You have a pending request waiting for approval. You cannot borrow more items at this time",
      });
    }

    // ✅ 4. สร้างคำขอยืมใหม่
    const borrow_date = today;
    const [result] = await pool.query(
      `INSERT INTO borrow_request
        (student_id, item_id, borrow_date, return_date, request_status)
       VALUES (?, ?, ?, ?, 'Pending')`,
      [student_id, item_id, borrow_date, return_date]
    );

    res.json({
      success: true,
      request_id: result.insertId,
      message: "Borrow request created successfully",
    });
  } catch (err) {
    console.error("❌ Error creating borrow request:", err);
    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
});




// 4. GET: ดึง "Request Result" (ที่ยัง Pending) (เหมือนเดิม)
router.get("/requests/:studentId", async (req, res) => {
  try {
    const { studentId } = req.params;
    const [rows] = await pool.query(
      "SELECT * FROM request_result_view WHERE student_id = ?",
      [studentId]
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// 5. GET: ดึง "History" (ที่ Approved/Rejected แล้ว) (เหมือนเดิม)
router.get("/history/:studentId", async (req, res) => {
  try {
    const { studentId } = req.params;
    const [rows] = await pool.query(
      "SELECT * FROM history_view WHERE student_id = ?",
      [studentId]
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// Dashboard API
router.get("/", async (req, res) => {
  try {
    // --- 1️ นับจำนวนสถานะจาก sport_item ---
    const [statusRows] = await pool.query(`
      SELECT 
        SUM(CASE WHEN status = 'Available' THEN 1 ELSE 0 END) AS available,
        SUM(CASE WHEN status = 'Borrowed' THEN 1 ELSE 0 END) AS borrowed,
        SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) AS pending,
        SUM(CASE WHEN status = 'Disable' THEN 1 ELSE 0 END) AS disable
      FROM sport_item;
    `);

    // --- 2️ นับจำนวนหมวดหมู่ทั้งหมด ---
    const [categoryRows] = await pool.query(`
      SELECT COUNT(category_id) AS total_sports FROM sport_category;
    `);

    // --- 3️ นับจำนวน item ทั้งหมด ---
    const [itemRows] = await pool.query(`
      SELECT COUNT(*) AS total_items FROM sport_item;
    `);

    // --- 4️ ส่งข้อมูลกลับ ---
    res.json({
      status_summary: statusRows[0],
      total_sports: categoryRows[0].total_sports,
      total_items: itemRows[0].total_items,
    });
  } catch (err) {
    console.error("Dashboard error:", err);
    res.status(500).json({ message: "Server error" });
  }
});

export default router;