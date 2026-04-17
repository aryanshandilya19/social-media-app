import express from "express";
import authMiddleware from "../middlewares/auth.middleware.js";
import {
  createPost,
  getPosts,
  deletePost,
  updatePost,
  getFeed,
  toggleLike,
  getUserPosts
} from "../controllers/post.controller.js";

const router = express.Router();

router.post("/", authMiddleware, createPost);
router.get("/", authMiddleware, getPosts);
router.get("/feed", authMiddleware, getFeed);
router.delete("/:postId", authMiddleware, deletePost);
router.put("/:postId", authMiddleware, updatePost);
router.get("/user/:userId", authMiddleware, getUserPosts);

// ✅ LIKE ROUTE
router.post("/:id/like", authMiddleware, toggleLike);

export default router;
