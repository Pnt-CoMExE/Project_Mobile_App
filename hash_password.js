// This script generates a bcrypt hash for a given password.
// Run this file from your terminal: node hash_password.js

import bcrypt from 'bcrypt';

async function hashPassword() {
  // --- ใส่รหัสผ่านที่คุณต้องการ hash ตรงนี้ ---
  const password = '1234aa';
  // ------------------------------------------

  const saltRounds = 10; // Must match the saltRounds in auth.js

  try {
    const hash = await bcrypt.hash(password, saltRounds);

    console.log("Password to Hash:", password);
    console.log("---");
    console.log("✅ BCrypt Hash (Copy this entire line):");
    console.log(hash);
    console.log("---");

  } catch (err) {
    console.error("Error hashing password:", err);
  }
}

hashPassword();
