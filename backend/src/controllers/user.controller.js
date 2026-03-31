import User from "../models/User.js";
import { getPagination } from "../utils/pagination.js";


// 🔥 GET MY PROFILE
export const getProfile = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id).select(
      "-password -refreshToken"
    );

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    error.statusCode = 500;
    next(error);
  }
};


// 🔥 UPDATE PROFILE
export const updateProfile = async (req, res, next) => {
  try {
    const { name, avatar } = req.body;

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { name, avatar },
      { new: true }
    ).select("-password -refreshToken");

    res.status(200).json({
      success: true,
      message: "Profile updated",
      data: user,
    });
  } catch (error) {
    error.statusCode = 500;
    next(error);
  }
};


// 🔥 GET ALL USERS (DISCOVER)
export const getUsers = async (req, res, next) => {
  try {
    const { page, limit, skip } = getPagination(req.query);

    const sortField = req.query.sort || "createdAt";
    const sortOrder = req.query.order === "asc" ? 1 : -1;

    const filter = {};
    if (req.query.name) {
      filter.name = { $regex: req.query.name, $options: "i" };
    }

    const users = await User.find(filter)
      .select("-password -refreshToken")
      .sort({ [sortField]: sortOrder })
      .skip(skip)
      .limit(limit);

    const total = await User.countDocuments(filter);

    res.status(200).json({
      success: true,
      meta: {
        total,
        page,
        limit,
      },
      data: users,
    });
  } catch (error) {
    error.statusCode = 500;
    next(error);
  }
};


// 🔥 FOLLOW USER
export const followUser = async (req, res, next) => {
  try {
    const { userId } = req.params;

    if (req.user.id === userId) {
      return res.status(400).json({
        success: false,
        message: "You cannot follow yourself",
      });
    }

    const targetUser = await User.findById(userId).select("_id");

    if (!targetUser) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    const updatedCurrentUser = await User.findOneAndUpdate(
      {
        _id: req.user.id,
        following: { $ne: userId },
      },
      {
        $addToSet: { following: userId },
        $inc: { followingCount: 1 },
      },
      { new: true }
    );

    if (!updatedCurrentUser) {
      return res.status(200).json({
        success: true,
        message: "User already followed",
      });
    }

    await User.updateOne(
      {
        _id: userId,
        followers: { $ne: req.user.id },
      },
      {
        $addToSet: { followers: req.user.id },
        $inc: { followersCount: 1 },
      }
    );

    res.status(200).json({
      success: true,
      message: "User followed successfully",
    });
  } catch (error) {
    error.statusCode = 500;
    next(error);
  }
};


// 🔥 UNFOLLOW USER
export const unfollowUser = async (req, res, next) => {
  try {
    const { userId } = req.params;

    const targetUser = await User.findById(userId).select("_id");

    if (!targetUser) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    const updatedCurrentUser = await User.findOneAndUpdate(
      {
        _id: req.user.id,
        following: userId,
      },
      {
        $pull: { following: userId },
        $inc: { followingCount: -1 },
      },
      { new: true }
    );

    if (!updatedCurrentUser) {
      return res.status(200).json({
        success: true,
        message: "User not followed",
      });
    }

    await User.updateOne(
      {
        _id: userId,
        followers: req.user.id,
      },
      {
        $pull: { followers: req.user.id },
        $inc: { followersCount: -1 },
      }
    );

    res.status(200).json({
      success: true,
      message: "User unfollowed successfully",
    });
  } catch (error) {
    error.statusCode = 500;
    next(error);
  }
};


// 🔥 GET USER PROFILE (FOR UI)
export const getUserProfile = async (req, res, next) => {
  try {
    const userId = req.params.id;

    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    const followers = user.followers || [];
    const following = user.following || [];

    res.status(200).json({
      success: true,
      data: {
        _id: user._id,
        name: user.name,
        followersCount: followers.length,
        followingCount: following.length,
        isFollowing: followers.some(
          (followerId) => followerId.toString() === req.user.id
        ),
      },
    });

  } catch (error) {
    next(error);
  }
};