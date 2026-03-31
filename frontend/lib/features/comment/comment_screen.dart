import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CommentScreen extends StatefulWidget {
  final String postId;

  const CommentScreen({super.key, required this.postId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  List comments = [];
  bool isLoading = true;

  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<void> loadComments() async {
    final result = await ApiService.getComments(widget.postId);

    setState(() {
      comments = result["data"] ?? [];
      isLoading = false;
    });
  }

  Future<void> addComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    final result = await ApiService.addComment(
      postId: widget.postId,
      content: text,
    );

    if (result["success"] == true) {
      setState(() {
        comments.insert(0, {
          "content": result["data"]["content"],
          "author": {"name": "You"},
        });
        commentController.clear();
      });
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comments")),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : comments.isEmpty
                ? const Center(child: Text("No comments yet"))
                : ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];

                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(
                          comment["author"] != null &&
                                  comment["author"]["name"] != null
                              ? comment["author"]["name"]
                              : "User",
                        ),
                        subtitle: Text(comment["content"] ?? ""),

                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final commentId = comment["_id"];

                            final result = await ApiService.deleteComment(
                              commentId,
                            );

                            if (result["success"] == true) {
                              setState(() {
                                comments.removeAt(index);
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: "Write a comment...",
                    ),
                  ),
                ),

                IconButton(icon: const Icon(Icons.send), onPressed: addComment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
