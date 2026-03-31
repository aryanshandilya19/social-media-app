import mongoose from "mongoose";

const postSchema = new mongoose.Schema(
  {
    content: {
      type: String,
      required: true,
      trim: true,
      maxlength: 500,
    },
    image: {
      type: String,
      default: "",
    },
    author: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    likes: {
  type: [mongoose.Schema.Types.ObjectId],
  ref: "User",
  default: [],
},
    commentsCount: {
  type: Number,
  default: 0,
},

  },
  { timestamps: true }
);

const Post = mongoose.model("Post", postSchema);
export default Post;
