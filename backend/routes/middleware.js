import jwt from "jsonwebtoken";
import pool from "../db.js";

const JWT_SECRET = process.env.JWT_SECRET || "dev_secret_key";
const TIMEOUT_MIN = 15;

export const authMiddleware = async (req, res, next) => {
  try {
    const raw = req.headers.authorization || "";
    const token = raw.startsWith("Bearer ") ? raw.slice(7) : null;

    if (!token) return res.status(401).json({ success: false, message: "Missing token" });

    let payload;
    try {
      payload = jwt.verify(token, JWT_SECRET);
    } catch {
      return res.status(401).json({ success: false, message: "Invalid token" });
    }

    const [rows] = await pool.query(
      "SELECT id, last_activity FROM user_sessions WHERE token = ? AND is_active = 1",
      [token]
    );
    if (!rows.length)
      return res.status(401).json({ success: false, message: "Session expired" });

    const session = rows[0];
    const last = new Date(session.last_activity).getTime();
    const now = Date.now();
    const diff = (now - last) / (1000 * 60);

    if (diff > TIMEOUT_MIN) {
      await pool.query("UPDATE user_sessions SET is_active = 0 WHERE id = ?", [session.id]);
      return res
        .status(401)
        .json({ success: false, message: "Session timeout, please login again" });
    }

    // refresh activity
    await pool.query("UPDATE user_sessions SET last_activity = NOW() WHERE id = ?", [session.id]);

    req.user = payload;
    next();
  } catch (err) {
    console.error("Auth middleware error:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
};
