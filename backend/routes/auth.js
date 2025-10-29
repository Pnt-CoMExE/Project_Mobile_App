import express from "express";
import pool from "../db.js";
import bcrypt from "bcrypt";

const router = express.Router();

// Register - role forced to 1 (student), no fullname
router.post("/register", async (req, res) => {
  // รับ 'username' และ 'password' จาก body ของ Flutter
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).json({ success: false, message: "Missing fields" });
  }

  try {
    // [แก้ไข] ใช้ u_id และ u_username
    const [rows] = await pool.query("SELECT u_id FROM user WHERE u_username = ?", [
      username,
    ]);
    if (rows.length > 0) {
      return res.json({ success: false, message: "Username already exists" });
    }
    const hashed = await bcrypt.hash(password, 10);
    
    // [แก้ไข] ใช้ u_username, u_password, u_role
    const [result] = await pool.query(
      "INSERT INTO user (u_username, u_password, u_role) VALUES (?, ?, ?)",
      [username, hashed, 1] // 1 = student
    );
    
    const u_id = result.insertId;
    // [แก้ไข] ส่ง u_id, u_username, u_role กลับไป
    res.json({ success: true, user: { u_id: u_id, u_username: username, u_role: 1 } });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// Login - no fullname
router.post("/login", async (req, res) => {
  // รับ 'username' และ 'password' จาก body ของ Flutter
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).json({ success: false, message: "Missing fields" });
  }
  try {
    // [แก้ไข] SELECT u_id, u_username, u_password, u_role และ WHERE u_username
    const [rows] = await pool.query(
      "SELECT u_id, u_username, u_password, u_role FROM user WHERE u_username = ?",
      [username]
    );
    if (rows.length === 0) {
      return res.json({ success: false, message: "Invalid credentials" });
    }
    const user = rows[0]; // user object ตอนนี้คือ { u_id: ..., u_username: ..., u_password: ..., u_role: ... }
    
    // [แก้ไข] เทียบ password กับ user.u_password
    const match = await bcrypt.compare(password, user.u_password);
    if (!match) {
      return res.json({ success: false, message: "Invalid credentials" });
    }
    
    // [แก้ไข] ใช้ user.u_username สร้าง token
    const token = Buffer.from(user.u_username + ":" + Date.now()).toString("hex");

    // [แก้ไข] ส่ง key/value ให้ตรง (u_id, u_username, u_role)
    res.json({
      success: true,
      user: {
        u_id: user.u_id,
        u_username: user.u_username,
        u_role: user.u_role, // <-- นี่จะเป็นตัวเลข 1, 2, หรือ 3
        token,
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

export default router;