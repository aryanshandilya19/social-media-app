import express from "express";
import authMiddleware from "../middlewares/auth.middleware.js";
import { addComment, getComments, deleteComment, getReplies } from "../controllers/comment.controller.js";


const router = express.Router();

// Add comment
router.post("/:postId", authMiddleware, addComment);

// Get comments for a post
router.get("/:postId", authMiddleware, getComments);
// Delete comment
router.delete("/:commentId", authMiddleware, deleteComment);
router.get("/replies/:commentId", authMiddleware, getReplies);



export default router;
