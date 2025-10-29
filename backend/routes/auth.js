import express from "express";
import pool from "../db.js";
import bcrypt from "bcrypt";

const router = express.Router();

// Register - role forced to 'student'
router.post("/register", async (req, res) => {
  const { username, password, fullname } = req.body;
  if (!username || !password || !fullname) {
    return res.status(400).json({ success: false, message: "Missing fields" });
  }
  try {
    const [rows] = await pool.query("SELECT id FROM users WHERE username = ?", [username]);
    if (rows.length > 0) {
      return res.json({ success: false, message: "Username already exists" });
    }
    const hashed = await bcrypt.hash(password, 10);
    const [result] = await pool.query(
      "INSERT INTO users (username, password, fullname, role) VALUES (?, ?, ?, ?)",
      [username, hashed, fullname, "student"]
    );
    const id = result.insertId;
    res.json({ success: true, user: { id, username, role: "student" } });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// Login
router.post("/login", async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).json({ success: false, message: "Missing fields" });
  }
  try {
    const [rows] = await pool.query("SELECT id, username, password, role FROM users WHERE username = ?", [username]);
    if (rows.length === 0) {
      return res.json({ success: false, message: "Invalid credentials" });
    }
    const user = rows[0];
    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      return res.json({ success: false, message: "Invalid credentials" });
    }
    // simple token generation (for demo only)
    const token = Buffer.from(user.username + ":" + Date.now()).toString("hex");
    res.json({ success: true, user: { id: user.id, username: user.username, role: user.role, token } });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

export default router;
