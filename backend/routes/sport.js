import express from "express";
import pool from "../db.js";
// [TODO] เพิ่ม middleware ตรวจสอบ token ถ้ามี

const router = express.Router();

// 1. GET: ดึง Category ทั้งหมดสำหรับหน้า Home (เหมือนเดิม)
router.get("/categories", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT * FROM category_status_view");
    res.json({ success: true, data: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// 2. GET: ดึง Item ทั้งหมดใน Category ที่เลือก (เหมือนเดิม)
router.get("/items/:categoryId", async (req, res) => {
  try {
    const { categoryId } = req.params;
    const [rows] = await pool.query(
      "SELECT * FROM sport_item WHERE category_id = ?",
      [categoryId]
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// 3. POST: สร้างคำขอยืมใหม่ (Borrow Request)
router.post("/borrow/request", async (req, res) => {
  const { student_id, item_id, return_date } = req.body;

  if (!student_id || !item_id || !return_date) {
    return res.status(400).json({ success: false, message: "Missing fields" });
  }

  try {
    // --- [FIX] START: ตรวจสอบการยืมซ้ำซ้อน ---------------------
    
    // 1. หาวันที่ปัจจุบัน (YYYY-MM-DD)
    const today = new Date().toISOString().split('T')[0];

    // 2. ค้นหาว่า student คนนี้ มีคำขอ (ไม่ว่าจะสถานะใด) ในวันนี้แล้วหรือยัง
    const [existingRequests] = await pool.query(
      "SELECT COUNT(*) AS count FROM borrow_request WHERE student_id = ? AND borrow_date = ?",
      [student_id, today]
    );

    // 3. ถ้ามี (count > 0) ให้ส่ง Error กลับไป
    if (existingRequests[0].count > 0) {
      return res.status(409).json({ // 409 Conflict
        success: false, 
        message: "You can only make one borrow request per day." // ⬅️ ข้อความนี้จะเด้งในแอป
      });
    }
    // --- [FIX] END ------------------------------------------


    // 4. ถ้าไม่ซ้ำ (count == 0) ให้ดำเนินการ INSERT ตามปกติ
    const borrow_date = today; // ใช้วันที่ปัจจุบันที่หาไว้แล้ว

    const [result] = await pool.query(
      "INSERT INTO borrow_request (student_id, item_id, borrow_date, return_date, request_status) VALUES (?, ?, ?, ?, ?)",
      [student_id, item_id, borrow_date, return_date, 'Pending']
      // Trigger ใน .sql จะเปลี่ยนสถานะ item เป็น 'Pending' ให้เอง
    );
    
    res.json({ success: true, request_id: result.insertId });

  } catch (err) {
    console.error(err);
    if (err.code === 'ER_NO_REFERENCED_ROW_2') {
         return res.status(404).json({ success: false, message: "Invalid item or student ID" });
    }
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// 4. GET: ดึง "Request Result" (ที่ยัง Pending) ตามรหัสนักเรียน (เหมือนเดิม)
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

// 5. GET: ดึง "History" (ที่ Approved/Rejected แล้ว) ตามรหัสนักเรียน (เหมือนเดิม)
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

export default router;