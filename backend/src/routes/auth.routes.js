import express from "express";
import authMiddleware from "../middlewares/auth.middleware.js";
import { register, login, getMe,refreshAccessToken,logout } from "../controllers/auth.controller.js";
const router = express.Router();

router.post("/register", register);
router.post("/login", login);
router.get("/me", authMiddleware, getMe);
router.post("/refresh-token", refreshAccessToken);
router.post("/logout", authMiddleware, logout);


export default router;