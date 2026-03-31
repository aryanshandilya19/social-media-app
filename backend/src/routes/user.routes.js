import express from "express";
import authMiddleware from "../middlewares/auth.middleware.js";
import {
  getProfile,
  updateProfile,
  followUser,
  unfollowUser,
  getUserProfile,
  getUsers,
} from "../controllers/user.controller.js";

const router = express.Router();

router.get("/profile", authMiddleware, getProfile);
router.put("/profile", authMiddleware, updateProfile);
router.get("/", authMiddleware, getUsers);

// ✅ FIXED ROUTES
router.post("/:userId/follow", authMiddleware, followUser);
router.post("/:userId/unfollow", authMiddleware, unfollowUser);

router.get("/:id", authMiddleware, getUserProfile);

export default router;