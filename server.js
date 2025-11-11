//server.js
import express from "express";
import cors from "cors";
import authRoutes from "./backend/routes/auth.js";
import sportRoutes from "./backend/routes/sport.js";
import dashboardRoutes from "./backend/routes/sport.js";

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

app.use("/api/auth", authRoutes);
app.use("/api/sport", sportRoutes);
app.use("/api/dashboard", dashboardRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
