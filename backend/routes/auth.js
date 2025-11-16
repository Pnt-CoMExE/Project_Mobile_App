import express from "express";
import pool from "../db.js";
import bcrypt from "bcrypt";

const router = express.Router();

// =====================================================
// ✅ Student Register
// =====================================================
router.post("/register", async (req, res) => {
  const { u_username, u_password } = req.body;
  if (!u_username || !u_password) {
    return res.status(400).json({ success: false, message: "Missing fields" });
  }

  try {
    const [rows] = await pool.query(
      "SELECT u_id FROM user WHERE u_username = ?",
      [u_username]
    );

    if (rows.length > 0) {
      return res.json({ success: false, message: "Username already exists" });
    }

    const hashed = await bcrypt.hash(u_password, 10);

    const [result] = await pool.query(
      "INSERT INTO user (u_username, u_password, u_role) VALUES (?, ?, ?)",
      [u_username, hashed, 1]
    );

    const u_id = result.insertId;

    res.json({
      success: true,
      user: { u_id, u_username, u_role: 1 },
    });
  } catch (err) {
    console.error("❌ /register error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});


// =====================================================
// ✅ Student Login (ไม่มี )
// =====================================================
router.post("/login", async (req, res) => {
  const { u_username, u_password } = req.body;

  if (!u_username || !u_password) {
    return res
      .status(400)
      .json({ success: false, message: "Missing fields" });
  }

  try {
    const [rows] = await pool.query(
      "SELECT u_id, u_username, u_password, u_role FROM user WHERE u_username = ?",
      [u_username]
    );

    if (rows.length === 0) {
      return res.json({ success: false, message: "Invalid credentials" });
    }

    const user = rows[0];

    const match = await bcrypt.compare(u_password, user.u_password);
    if (!match) {
      return res.json({ success: false, message: "Invalid credentials" });
    }

    // ✅ ไม่มี JWT แล้ว ส่งข้อมูล user ตรง ๆ
    res.json({
      success: true,
      user: {
        u_id: user.u_id,
        u_username: user.u_username,
        u_role: user.u_role,
      },
    });
  } catch (err) {
    console.error("❌ /login error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});


// =====================================================
// ✅ Lender Login (ไม่มี )
// =====================================================
router.post("/login-lender", async (req, res) => {
  const { lender_username, lender_password } = req.body;

  if (!lender_username || !lender_password) {
    return res
      .status(400)
      .json({ success: false, message: "Missing fields" });
  }

  try {
    const [rows] = await pool.query(
      "SELECT lender_id, lender_username, lender_password, lender_name FROM lender WHERE lender_username = ?",
      [lender_username]
    );

    if (rows.length === 0) {
      return res.json({ success: false, message: "User not found" });
    }

    const lender = rows[0];

    const match = await bcrypt.compare(
      lender_password,
      lender.lender_password
    );
    if (!match) {
      return res.json({ success: false, message: "Invalid password" });
    }

    // ✅ ส่งข้อมูล lender ตรง ๆ
    res.json({
      success: true,
      message: "Login success",
      lender_id: lender.lender_id,
      lender_name: lender.lender_name,
    });
  } catch (err) {
    console.error("❌ /login-lender error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

export default router;
