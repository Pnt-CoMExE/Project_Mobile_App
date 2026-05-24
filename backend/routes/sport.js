// sport.js
import express from "express";
import pool from "../db.js";

const router = express.Router();


// 1. GET: ดึง Category (หน้า Home) สำหรับ Student
router.get("/categories", async (req, res) => {
  try {
    // await autoExpirePendingRequests();
    const { studentId } = req.query; // รับ studentId จาก app
    if (!studentId) {
      return res
        .status(400)
        .json({ success: false, message: "Missing studentId" });
    }

    // ใช้ SQL JOIN เพื่อตรวจสอบสถานะ Pending ของ "ฉัน"
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
    console.error("❌ /categories error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});


// 2. GET: ดึง Item ใน Category (หน้ารายละเอียด) สำหรับ Student
router.get("/items/:categoryId", async (req, res) => {
  try {
    // await autoExpirePendingRequests();
    const { categoryId } = req.params;
    const { studentId } = req.query; // รับ studentId จาก app
    if (!studentId) {
      return res
        .status(400)
        .json({ success: false, message: "Missing studentId" });
    }

    // ใช้ SQL JOIN และ CASE ปรับ status ของ Pending โดยผู้อื่นเป็น Disable
    const [rows] = await pool.query(
      `SELECT 
        si.item_id, 
        si.category_id, 
        si.item_name, 
        si.item_image, 
        CASE 
          WHEN si.status = 'Pending' AND br.student_id = ? THEN 'Pending'
          WHEN si.status = 'Pending' AND br.student_id != ? THEN 'Disable'
          ELSE si.status
        END AS status
      FROM sport_item si
      LEFT JOIN borrow_request br ON si.item_id = br.item_id AND br.request_status = 'Pending'
      WHERE si.category_id = ?`,
      [studentId, studentId, categoryId]
    );

    res.json({ success: true, data: rows });
  } catch (err) {
    console.error("❌ /items error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});


// 3. POST: สร้างคำขอยืมใหม่ (Borrow Request) สำหรับ Student
router.post("/borrow/request", async (req, res) => {
  const { student_id, item_id, return_date } = req.body;

  if (!student_id || !item_id || !return_date) {
    return res
      .status(400)
      .json({ success: false, message: "Missing fields" });
  }

  try {
    const today = new Date().toISOString().split("T")[0];

    // ✅ 1. เช็คว่ามีของที่ยังถืออยู่ (Approved แล้วยังไม่คืน + ยังไม่เกินกำหนด) หรือเปล่า
    const [activeBorrow] = await pool.query(
      `SELECT request_id, item_id, request_status, return_date, actual_return_date
       FROM borrow_request
       WHERE student_id = ?
         AND request_status = 'Approved'
         AND (actual_return_date IS NULL OR actual_return_date = '')
         AND return_date >= ?`,
      [student_id, today]
    );

    console.log(
      "📦 Borrow limit check for student",
      student_id,
      "=>",
      activeBorrow
    );

    if (activeBorrow.length > 0) {
      return res.status(400).json({
        success: false,
        message:
          "You already have an active borrowed item. Please return it first before borrowing another.",
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

    // ✅ 3. ป้องกันการยื่นคำขอ Pending ซ้ำ (มี Pending ค้างอยู่แล้วห้ามสร้างใหม่)
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
        message:
          "You have a pending request waiting for approval. You cannot borrow more items at this time",
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


// 4. GET: ดึง "Request Result" (คำขอที่ยัง Pending) สำหรับ Student
router.get("/requests/:studentId", async (req, res) => {
  try {
    // await autoExpirePendingRequests();
    const { studentId } = req.params;
    const [rows] = await pool.query(
      "SELECT * FROM request_result_view WHERE student_id = ?",
      [studentId]
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    console.error("❌ /requests error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// helper: auto-expire Pending requests ที่ค้างข้ามวัน
// async function autoExpirePendingRequests() {
//   try {
//     await pool.query(
//       `UPDATE borrow_request
//        SET request_status = 'Rejected',
//            request_description = CASE
//              WHEN (request_description IS NULL OR request_description = '')
//                THEN 'Auto-cancelled: no action in time'
//              ELSE request_description
//            END
//        WHERE request_status = 'Pending'
//          AND borrow_date < CURDATE();`
//     );
//   } catch (err) {
//     console.error("❌ autoExpirePendingRequests error:", err);
//   }
// }

// 5. GET: ดึง "History" (Approved/Rejected) สำหรับ Student
router.get("/history/:studentId", async (req, res) => {
  try {
    const { studentId } = req.params;
    const [rows] = await pool.query(
      "SELECT * FROM history_view WHERE student_id = ?",
      [studentId]
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    console.error("❌ /history (student) error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});


// 6. GET: ดึงคำขอที่รออนุมัติ (Pending) ทั้งหมดสำหรับ Lender
router.get("/lender/pending-requests", async (req, res) => {
  try {
    const [rows] = await pool.query(
      `
      SELECT 
        br.request_id,
        u.u_id AS student_id,
        u.u_username AS username,
        si.item_id,
        si.item_name,
        sc.category_name,
        si.item_image,
        br.borrow_date,
        br.return_date,
        br.request_status
      FROM borrow_request br
      JOIN user u ON br.student_id = u.u_id
      JOIN sport_item si ON br.item_id = si.item_id
      JOIN sport_category sc ON si.category_id = sc.category_id
      WHERE br.request_status = 'Pending'
      ORDER BY br.request_id DESC
      `
    );

    res.json({ success: true, data: rows });
  } catch (err) {
    console.error("❌ /lender/pending-requests error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// 7. POST: Lender อัปเดตสถานะคำขอ (Approve / Reject)
router.post("/lender/update_status", async (req, res) => {
  const { request_id, status, lender_id, reason } = req.body;

  if (!request_id || !status || !lender_id) {
    return res
      .status(400)
      .json({ success: false, message: "Missing required fields" });
  }

  try {
    // ✅ อัปเดตสถานะคำขอในตาราง borrow_request
    await pool.query(
      `UPDATE borrow_request 
       SET request_status = ?, lender_id = ?, request_description = ?
       WHERE request_id = ?`,
      [status, lender_id, reason || null, request_id]
    );

    // ✅ อัปเดตสถานะของ sport_item ให้สอดคล้อง (เหมือน Trigger)
    if (status === "Approved") {
      await pool.query(
        `UPDATE sport_item si 
         JOIN borrow_request br ON si.item_id = br.item_id 
         SET si.status = 'Borrowed' 
         WHERE br.request_id = ?`,
        [request_id]
      );
    } else if (status === "Rejected") {
      await pool.query(
        `UPDATE sport_item si 
         JOIN borrow_request br ON si.item_id = br.item_id 
         SET si.status = 'Available' 
         WHERE br.request_id = ?`,
        [request_id]
      );
    }

    res.json({ success: true, message: `Request ${status} successfully` });
  } catch (err) {
    console.error("❌ Error updating request:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});


// 8. GET: ดึงประวัติของ Lender (Approved / Rejected)
router.get("/lender/history/:lenderId", async (req, res) => {
  try {
    const { lenderId } = req.params;

    const [rows] = await pool.query(
      `
      SELECT 
        br.request_id,
        u.u_username AS username,
        si.item_name,
        sc.category_name,
        si.item_image,
        br.borrow_date,
        br.return_date,
        br.request_status,
        br.request_description AS reason
      FROM borrow_request br
      JOIN user u ON br.student_id = u.u_id
      JOIN sport_item si ON br.item_id = si.item_id
      JOIN sport_category sc ON si.category_id = sc.category_id
      WHERE br.lender_id = ?
        AND br.request_status IN ('Approved', 'Rejected')
      ORDER BY br.request_id DESC
      `,
      [lenderId]
    );

    res.json({ success: true, data: rows });
  } catch (err) {
    console.error("❌ Error fetching lender history:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});


// 9. Dashboard API (staff / admin ดูสรุป)
router.get("/", async (req, res) => {
  try {
    // 1. นับจำนวนสถานะจาก sport_item
    const [statusRows] = await pool.query(`
      SELECT 
        SUM(CASE WHEN status = 'Available' THEN 1 ELSE 0 END) AS available,
        SUM(CASE WHEN status = 'Borrowed' THEN 1 ELSE 0 END) AS borrowed,
        SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) AS pending,
        SUM(CASE WHEN status = 'Disable' THEN 1 ELSE 0 END) AS disable
      FROM sport_item;
    `);

    // 2. นับจำนวนหมวดหมู่ทั้งหมด
    const [categoryRows] = await pool.query(`
      SELECT COUNT(category_id) AS total_sports FROM sport_category;
    `);

    // 3. นับจำนวน item ทั้งหมด
    const [itemRows] = await pool.query(`
      SELECT COUNT(*) AS total_items FROM sport_item;
    `);

    // 4. ส่งข้อมูลกลับ
    res.json({
      status_summary: statusRows[0],
      total_sports: categoryRows[0].total_sports,
      total_items: itemRows[0].total_items,
    });
  } catch (err) {
    console.error("❌ Dashboard error:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// 10. GET: รายการอุปกรณ์ที่ "กำลังถูกยืม" สำหรับหน้า Return (Approved + ยังไม่คืน)
router.get("/return/list", async (req, res) => {
  try {
    const [rows] = await pool.query(
      `
      SELECT 
        br.request_id,
        br.item_id,
        si.item_name,
        sc.category_name,
        si.item_image,
        u.u_username AS username,
        br.borrow_date,
        br.return_date
      FROM borrow_request br
      JOIN sport_item si ON br.item_id = si.item_id
      JOIN sport_category sc ON si.category_id = sc.category_id
      JOIN user u ON br.student_id = u.u_id
      WHERE br.request_status = 'Approved'
        AND br.actual_return_date IS NULL
      ORDER BY br.borrow_date DESC
      `
    );

    res.json({ success: true, data: rows });
  } catch (err) {
    console.error("❌ /return/list error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});


// 11. POST: Staff กดคืนของ → บันทึก actual_return_date + staff_id
router.post("/return/confirm", async (req, res) => {
  const { request_id, staff_id } = req.body;

  if (!request_id || !staff_id) {
    return res
      .status(400)
      .json({ success: false, message: "Missing request_id or staff_id" });
  }

  try {
    // ✅ ตรวจสอบว่ามี request นี้และยังไม่คืน
    const [rows] = await pool.query(
      `SELECT request_id, request_status, actual_return_date
       FROM borrow_request
       WHERE request_id = ?`,
      [request_id]
    );

    if (!rows.length) {
      return res
        .status(404)
        .json({ success: false, message: "Request not found" });
    }

    const reqRow = rows[0];

    if (reqRow.request_status !== "Approved") {
      return res.status(400).json({
        success: false,
        message: "Only approved requests can be returned",
      });
    }

    if (reqRow.actual_return_date) {
      return res.status(400).json({
        success: false,
        message: "This item has already been returned",
      });
    }

    // ✅ อัปเดตวันคืนจริง + staff_id (คนที่กด RETURN)
    await pool.query(
      `UPDATE borrow_request
       SET actual_return_date = CURDATE(),
           staff_id = ?
       WHERE request_id = ?`,
      [staff_id, request_id]
    );

    // จากนี้ Trigger ใน DB จะ:
    // - ตั้งค่า return_status (On time / Overdue)
    // - เปลี่ยน sport_item.status = 'Available'

    res.json({ success: true, message: "Return recorded successfully" });
  } catch (err) {
    console.error("❌ /return/confirm error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// 12. GET: ประวัติการคืนของเฉพาะ staff คนหนึ่ง (ใช้ใน StaffHistory)
router.get("/history/staff/:staffId", async (req, res) => {
  try {
    const { staffId } = req.params;

    const [rows] = await pool.query(
      `
      SELECT 
        br.request_id,
        br.item_id,
        sc.category_name,         -- ⭐ ชื่อหมวดหมู่
        si.item_name,
        si.item_image,
        br.borrow_date,
        br.actual_return_date,
        stu.u_username AS username,      -- ชื่อนักศึกษา
        lend.u_username AS lender_name,  -- คนอนุมัติ
        stf.u_username AS staff_name     -- Staff ที่รับคืน
      FROM borrow_request br
      JOIN sport_item si ON br.item_id = si.item_id
      JOIN sport_category sc ON si.category_id = sc.category_id   -- ⭐ ต้องมี JOIN นี้
      JOIN user stu ON br.student_id = stu.u_id
      LEFT JOIN user lend ON br.lender_id = lend.u_id
      LEFT JOIN user stf ON br.staff_id = stf.u_id
      WHERE br.actual_return_date IS NOT NULL
        AND br.staff_id = ?
      ORDER BY br.request_id DESC
      `,
      [staffId]
    );

    res.json({ success: true, data: rows });
  } catch (err) {
    console.error("❌ /history/staff error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// ======================================
//  STAFF: GET All Categories (with count)
// ======================================
router.get("/staff/categories", async (req, res) => {
  try {
    const [rows] = await pool.query(
      `
      SELECT 
        sc.category_id,
        sc.category_name,
        sc.category_image,
        COUNT(si.item_id) AS total_items,
        SUM(CASE WHEN si.status = 'Available' THEN 1 ELSE 0 END) AS available_count,
        SUM(CASE WHEN si.status = 'Borrowed' THEN 1 ELSE 0 END) AS borrowed_count,
        SUM(CASE WHEN si.status = 'Pending' THEN 1 ELSE 0 END) AS pending_count,
        SUM(CASE WHEN si.status = 'Disable' THEN 1 ELSE 0 END) AS disable_count,
        CASE
            WHEN SUM(CASE WHEN si.status = 'Available' THEN 1 ELSE 0 END) > 0 
                THEN 'Available'
            WHEN SUM(CASE WHEN si.status = 'Disable' THEN 1 ELSE 0 END) = COUNT(si.item_id)
                THEN 'Disable'
            WHEN SUM(CASE WHEN si.status = 'Pending' THEN 1 ELSE 0 END) > 0
                THEN 'Pending'
            WHEN SUM(CASE WHEN si.status = 'Borrowed' THEN 1 ELSE 0 END) > 0
                THEN 'Borrowed'
            ELSE 'Available'
        END AS category_status
      FROM sport_category sc
      LEFT JOIN sport_item si ON sc.category_id = si.category_id
      GROUP BY sc.category_id, sc.category_name, sc.category_image
      ORDER BY sc.category_id ASC
      `
    );

    res.json({ success: true, data: rows });
  } catch (err) {
    console.error("❌ /staff/categories error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});


// ======================================
//  STAFF: Add New Category
// ======================================
router.post("/staff/category", async (req, res) => {
  try {
    const { category_name, category_image } = req.body;

    if (!category_name || !category_image) {
      return res.status(400).json({
        success: false,
        message: "Missing category_name or category_image",
      });
    }

    // Check duplicate name
    const [dup] = await pool.query(
      "SELECT * FROM sport_category WHERE category_name = ?",
      [category_name]
    );

    if (dup.length > 0) {
      return res.status(400).json({
        success: false,
        message: "This sport category already exists",
      });
    }

    const [result] = await pool.query(
      `
      INSERT INTO sport_category (category_name, category_image)
      VALUES (?, ?)
      `,
      [category_name, category_image]
    );

    res.json({
      success: true,
      category_id: result.insertId,
      message: "Category added successfully",
    });
  } catch (err) {
    console.error("❌ /staff/category error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});


// ======================================
//  STAFF: Edit Category (Name + Image)
// ======================================
router.put("/staff/category/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { category_name, category_image } = req.body;

    if (!category_name || !category_image) {
      return res.status(400).json({
        success: false,
        message: "Missing category_name or category_image",
      });
    }

    await pool.query(
      `
      UPDATE sport_category
      SET category_name = ?, category_image = ?
      WHERE category_id = ?
      `,
      [category_name, category_image, id]
    );

    res.json({ success: true, message: "Category updated successfully" });
  } catch (err) {
    console.error("❌ /staff/category/:id error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});


// ======================================
//  STAFF: Change Category Status
//  Available → Disable (all items)
// ======================================
router.put("/staff/category/:id/status", async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!["Available", "Disable"].includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Status must be Available or Disable",
      });
    }

    // Update all items in category
    await pool.query(
      `
      UPDATE sport_item
      SET status = ?
      WHERE category_id = ?
      `,
      [status, id]
    );

    res.json({
      success: true,
      message: `Category status updated to ${status}`,
    });
  } catch (err) {
    console.error("❌ /staff/category/:id/status error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// ======================================
// STAFF: GET Items In Category
// ======================================
router.get("/staff/items/:categoryId", async (req, res) => {
  try {
    const { categoryId } = req.params;

    const [rows] = await pool.query(
      `
      SELECT 
        item_id,
        category_id,
        item_name,
        item_image,
        status
      FROM sport_item
      WHERE category_id = ?
      ORDER BY item_id ASC
      `,
      [categoryId]
    );

    res.json({ success: true, data: rows });
  } catch (err) {
    console.error("❌ /staff/items/:categoryId error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});


// ======================================
// STAFF: Add New Item
// ======================================
router.post("/staff/item", async (req, res) => {
  try {
    const { category_id, item_name, item_image } = req.body;

    if (!category_id || !item_name || !item_image) {
      return res.status(400).json({
        success: false,
        message: "Missing fields",
      });
    }

    // ✔ generate item_id อัตโนมัติ
    const [[{ new_id }]] = await pool.query(
      `SELECT generate_item_id(?) AS new_id`,
      [category_id]
    );

    // ✔ Insert item
    await pool.query(
      `
      INSERT INTO sport_item (item_id, category_id, item_name, item_image, status)
      VALUES (?, ?, ?, ?, 'Available')
      `,
      [new_id, category_id, item_name, item_image]
    );

    res.json({
      success: true,
      item_id: new_id,
      message: "Item added successfully",
    });

  } catch (err) {
    console.error("❌ /staff/item error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});


// ======================================
// STAFF: Edit Item (Name + Image)
// ======================================
router.put("/staff/item/:itemId", async (req, res) => {
  try {
    const { itemId } = req.params;
    const { item_name, item_image } = req.body;

    if (!item_name || !item_image) {
      return res.status(400).json({
        success: false,
        message: "Missing item_name or item_image",
      });
    }

    await pool.query(
      `
      UPDATE sport_item
      SET item_name = ?, item_image = ?
      WHERE item_id = ?
      `,
      [item_name, item_image, itemId]
    );

    res.json({
      success: true,
      message: "Item updated successfully",
    });
  } catch (err) {
    console.error("❌ /staff/item/:itemId error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});


// ======================================
// STAFF: Change Item Status (Enable/Disable)
// ======================================
router.put("/staff/item/:itemId/status", async (req, res) => {
  try {
    const { itemId } = req.params;
    const { status } = req.body;

    if (!["Available", "Disable"].includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Status must be Available or Disable",
      });
    }

    await pool.query(
      `
      UPDATE sport_item
      SET status = ?
      WHERE item_id = ?
      `,
      [status, itemId]
    );

    res.json({
      success: true,
      message: `Status changed to ${status}`,
    });

  } catch (err) {
    console.error("❌ /staff/item/:itemId/status error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

export default router;