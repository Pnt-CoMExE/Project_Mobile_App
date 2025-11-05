import express from "express";
import pool from "../db.js";
import bcrypt from "bcrypt";

const router = express.Router();

// Register - role forced to 1 (student), no fullname
router.post("/register", async (req, res) => {
  // [FIX] เปลี่ยน 'username' และ 'password' ให้เป็น 'u_username' และ 'u_password'
  const { u_username, u_password } = req.body;
  if (!u_username || !u_password) {
    return res.status(400).json({ success: false, message: "Missing fields" });
  }

  try {
    const [rows] = await pool.query("SELECT u_id FROM user WHERE u_username = ?", [
      u_username, // [FIX] ใช้ u_username
    ]);
    if (rows.length > 0) {
      return res.json({ success: false, message: "Username already exists" });
    }
    const hashed = await bcrypt.hash(u_password, 10); // [FIX] ใช้ u_password
    
    const [result] = await pool.query(
      "INSERT INTO user (u_username, u_password, u_role) VALUES (?, ?, ?)",
      [u_username, hashed, 1] // [FIX] ใช้ u_username
    );
    
    const u_id = result.insertId;
    res.json({ success: true, user: { u_id: u_id, u_username: u_username, u_role: 1 } });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// Login - no fullname
router.post("/login", async (req, res) => {
  // [FIX] เปลี่ยน 'username' และ 'password' ให้เป็น 'u_username' และ 'u_password'
  const { u_username, u_password } = req.body;
  if (!u_username || !u_password) {
    return res.status(400).json({ success: false, message: "Missing fields" });
  }
  try {
    const [rows] = await pool.query(
      "SELECT u_id, u_username, u_password, u_role FROM user WHERE u_username = ?",
      [u_username] // [FIX] ใช้ u_username
    );
    if (rows.length === 0) {
      return res.json({ success: false, message: "Invalid credentials" });
    }
    const user = rows[0];
    
    // [FIX] ใช้ u_password ในการ compare
    const match = await bcrypt.compare(u_password, user.u_password);
    if (!match) {
      return res.json({ success: false, message: "Invalid credentials" });
    }
    
    const token = Buffer.from(user.u_username + ":" + Date.now()).toString("hex");

    res.json({
      success: true,
      user: {
        u_id: user.u_id,
        u_username: user.u_username,
        u_role: user.u_role,
        token,
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

export default router;