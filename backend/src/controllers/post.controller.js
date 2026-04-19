import Post from "../models/Post.js";
import { getPagination } from "../utils/pagination.js";
import User from "../models/User.js";

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
export const getPosts = async (req, res, next) => {
  try {
    const { page, limit, skip } = getPagination(req.query);

    const posts = await Post.find()
      .populate("author", "name email avatar")
      .sort({ createdAt: -1 }) // latest first
      .skip(skip)
      .limit(limit);

    const total = await Post.countDocuments();

    res.status(200).json({
      success: true,
      meta: {
        total,
        page,
        limit,
      },
      data: posts,
    });
  } catch (error) {
    error.statusCode = 500;
    next(error);
  }
};
export const deletePost = async (req, res, next) => {
  try {
    const { postId } = req.params;

    const post = await Post.findById(postId);

    if (!post) {
      const err = new Error("Post not found");
      err.statusCode = 404;
      throw err;
    }

    // ✅ Ownership validation
    if (post.author.toString() !== req.user.id) {
      const err = new Error("Not authorized to delete this post");
      err.statusCode = 403;
      throw err;
    }

    await post.deleteOne();

    res.status(200).json({
      success: true,
      message: "Post deleted successfully",
    });
  } catch (error) {
    error.statusCode = error.statusCode || 500;
    next(error);
  }
};
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

    // ✅ Ownership check
    if (post.author.toString() !== req.user.id) {
      const err = new Error("Not authorized to update this post");
      err.statusCode = 403;
      throw err;
    }

    // ✅ Partial update logic
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
export const getFeed = async (req, res, next) => {
  try {
    const limit = Number(req.query.limit) || 5;
    const cursor = req.query.cursor;

    // 1️⃣ Get current user
    const user = await User.findById(req.user.id);

    // 2️⃣ Include own posts + following users
    const authors = [...user.following, req.user.id];

    const query = {
      author: { $in: authors },
    };

    // 3️⃣ Apply cursor (for pagination)
    if (cursor) {
      query.createdAt = { $lt: new Date(cursor) };
    }

    // 4️⃣ Fetch posts
    const posts = await Post.find(query)
      .populate("author", "name avatar")
      .sort({ createdAt: -1 })
      .limit(limit);

    // 5️⃣ Next cursor
    const nextCursor =
      posts.length > 0 ? posts[posts.length - 1].createdAt : null;

     const postsWithLikes = posts.map((post) => {
  const postObj = post.toObject();

  const likesArray = post.likes || []; // 🔥 FIX

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

    const alreadyLiked = post.likes.includes(userId);

    if (alreadyLiked) {
      // 🔴 Unlike
      post.likes = post.likes.filter(
        (id) => id.toString() !== userId
      );
    } else {
      // ❤️ Like
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
export const getUserPosts = async (req, res, next) => {
  try {
    const { userId } = req.params;

    const posts = await Post.find({ author: userId })
      .populate("author", "name email avatar")
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: posts,
    });
  } catch (error) {
    error.statusCode = 500;
    next(error);
  }
};