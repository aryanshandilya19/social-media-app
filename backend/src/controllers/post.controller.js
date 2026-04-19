import mongoose from "mongoose";
import Post from "../models/Post.js";
import { getPagination } from "../utils/pagination.js";
import User from "../models/User.js";

// 🚀 CREATE POST
export const createPost = async (req, res, next) => {
  try {
    const { content, image } = req.body;

    if (!content) {
      const err = new Error("Post content is required");
      err.statusCode = 400;
      throw err;
    }

    const post = await Post.create({
      content,
      image,
      author: req.user.id,
    });

    res.status(201).json({
      success: true,
      data: post,
    });
  } catch (error) {
    error.statusCode = error.statusCode || 500;
    next(error);
  }
};

// 🚀 GET ALL POSTS
export const getPosts = async (req, res, next) => {
  try {
    const { page, limit, skip } = getPagination(req.query);

    const posts = await Post.find()
      .populate("author", "name email avatar")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Post.countDocuments();

    res.status(200).json({
      success: true,
      meta: { total, page, limit },
      data: posts,
    });
  } catch (error) {
    error.statusCode = 500;
    next(error);
  }
};

// 🚀 DELETE POST
export const deletePost = async (req, res, next) => {
  try {
    const { postId } = req.params;

    const post = await Post.findById(postId);

    if (!post) {
      const err = new Error("Post not found");
      err.statusCode = 404;
      throw err;
    }

    if (post.author.toString() !== req.user.id) {
      const err = new Error("Not authorized");
      err.statusCode = 403;
      throw err;
    }

    await post.deleteOne();

    res.status(200).json({
      success: true,
      message: "Post deleted",
    });
  } catch (error) {
    error.statusCode = error.statusCode || 500;
    next(error);
  }
};

// 🚀 UPDATE POST
export const updatePost = async (req, res, next) => {
  try {
    const { postId } = req.params;
    const { content, image } = req.body;

    const post = await Post.findById(postId);

    if (!post) {
      const err = new Error("Post not found");
      err.statusCode = 404;
      throw err;
    }

    if (post.author.toString() !== req.user.id) {
      const err = new Error("Not authorized");
      err.statusCode = 403;
      throw err;
    }

    if (content !== undefined) post.content = content;
    if (image !== undefined) post.image = image;

    await post.save();

    res.status(200).json({
      success: true,
      data: post,
    });
  } catch (error) {
    error.statusCode = error.statusCode || 500;
    next(error);
  }
};

// 🚀 GET FEED
export const getFeed = async (req, res, next) => {
  try {
    const limit = Number(req.query.limit) || 5;
    const cursor = req.query.cursor;

    const user = await User.findById(req.user.id);

    const authors = [...(user.following || []), req.user.id];

    const query = { author: { $in: authors } };

    if (cursor) {
      query.createdAt = { $lt: new Date(cursor) };
    }

    const posts = await Post.find(query)
      .populate("author", "name avatar")
      .sort({ createdAt: -1 })
      .limit(limit);

    const nextCursor =
      posts.length > 0 ? posts[posts.length - 1].createdAt : null;

    const postsWithLikes = posts.map((post) => {
      const postObj = post.toObject();

      const likesArray = post.likes || [];

      return {
        ...postObj,
        likesCount: likesArray.length,
        isLiked: likesArray.some(
          (id) => id.toString() === req.user.id
        ),
      };
    });

    res.status(200).json({
      success: true,
      meta: {
        limit,
        nextCursor,
        hasMore: posts.length === limit,
      },
      data: postsWithLikes,
    });
  } catch (error) {
    error.statusCode = 500;
    next(error);
  }
};

// 🚀 LIKE / UNLIKE
export const toggleLike = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const postId = req.params.id;

    const post = await Post.findById(postId);

    if (!post) {
      return res.status(404).json({
        success: false,
        message: "Post not found",
      });
    }

    const likesArray = post.likes || [];

    const alreadyLiked = likesArray.some(
      (id) => id.toString() === userId
    );

    if (alreadyLiked) {
      post.likes = likesArray.filter(
        (id) => id.toString() !== userId
      );
    } else {
      post.likes.push(userId);
    }

    await post.save();

    res.status(200).json({
      success: true,
      isLiked: !alreadyLiked,
      likesCount: post.likes.length,
    });
  } catch (error) {
    next(error);
  }
};

// 🚀 GET USER POSTS (🔥 FINAL FIX)
export const getUserPosts = async (req, res, next) => {
  try {
    const { userId } = req.params;

    // 🔥 CRITICAL FIX
    const posts = await Post.find({
      author: new mongoose.Types.ObjectId(userId),
    })
      .populate("author", "name email avatar")
      .sort({ createdAt: -1 });

    console.log("🔥 USER POSTS FOUND:", posts.length);

    res.status(200).json({
      success: true,
      data: posts,
    });
  } catch (error) {
    console.log("💥 ERROR IN getUserPosts:", error);
    error.statusCode = 500;
    next(error);
  }
};