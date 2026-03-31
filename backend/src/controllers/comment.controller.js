import Comment from "../models/Comment.js";
import Post from "../models/Post.js";

export const addComment = async (req, res, next) => {
  try {
   const { content, parentComment } = req.body;
    const { postId } = req.params;

    // 1️⃣ Validate input
    if (!content) {
      const err = new Error("Comment content required");
      err.statusCode = 400;
      throw err;
    }

    // 2️⃣ Create comment
    const comment = await Comment.create({
  content,
  author: req.user.id,
  post: postId,
  parentComment: parentComment || null,
});

    // 3️⃣ Increment comment counter safely
    await Post.findByIdAndUpdate(postId, {
      $inc: { commentsCount: 1 },
    });

    // 4️⃣ Send response
   const populatedComment = await comment.populate("author", "name avatar");

res.status(201).json({
  success: true,
  data: populatedComment,
});
  } catch (error) {
    error.statusCode = error.statusCode || 500;
    next(error);
  }
};
export const getComments = async (req, res, next) => {
  try {
    const { postId } = req.params;

    const comments = await Comment.find({ post: postId, parentComment: null })
  .populate("author", "name avatar")
  .sort({ createdAt: -1 });


    res.status(200).json({
      success: true,
      data: comments,
    });
  } catch (error) {
    error.statusCode = 500;
    next(error);
  }
};
export const deleteComment = async (req, res, next) => {
  try {
    const { commentId } = req.params;

    const comment = await Comment.findById(commentId);

    if (!comment) {
      const err = new Error("Comment not found");
      err.statusCode = 404;
      throw err;
    }

    // ✅ Ownership validation
    if (comment.author.toString() !== req.user.id) {
      const err = new Error("Not authorized to delete this comment");
      err.statusCode = 403;
      throw err;
    }

    await Post.findByIdAndUpdate(comment.post, {
      $inc: { commentsCount: -1 },
    });

    await comment.deleteOne();

    res.status(200).json({
      success: true,
      message: "Comment deleted successfully",
    });
  } catch (error) {
    error.statusCode = error.statusCode || 500;
    next(error);
  }
};
export const getReplies = async (req, res, next) => {
  try {
    const { commentId } = req.params;

    const replies = await Comment.find({ parentComment: commentId })
      .populate("author", "name avatar")
      .sort({ createdAt: 1 });

    res.status(200).json({
      success: true,
      data: replies,
    });
  } catch (error) {
    error.statusCode = 500;
    next(error);
  }
};
