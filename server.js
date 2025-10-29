import express from "express";
import cors from "cors";
import authRoutes from "./backend/routes/auth.js";

const app = express();
app.use(cors());
app.use(express.json());

app.use("/api/auth", authRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
