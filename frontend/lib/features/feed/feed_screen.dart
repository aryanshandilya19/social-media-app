import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../post/create_post_screen.dart';
import '../comment/comment_screen.dart';
import '../profile/profile_screen.dart';
import '../user/discover_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List posts = [];
  bool isLoading = false;
  bool hasMore = true;
  String? nextCursor;

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadFeed();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore) {
        loadFeed();
      }
    });
  }

  Future<void> loadFeed() async {
    if (!hasMore) return;

    setState(() => isLoading = true);

    final result = await ApiService.getFeed(cursor: nextCursor);

    final newPosts = result["data"] ?? [];

    setState(() {
      posts.addAll(newPosts);
      nextCursor = result["meta"]?["nextCursor"];
      hasMore = result["meta"]?["hasMore"] ?? false;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed"),
        actions: [
          IconButton(
            icon: const Icon(Icons.explore),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DiscoverScreen()),
              );
            },
          ),
          SizedBox(width: 10),
          IconButton(
            onPressed: () async {
              final created = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePostScreen()),
              );

              if (created == true) {
                setState(() {
                  posts = [];
                  nextCursor = null;
                  hasMore = true;
                });

                await loadFeed();
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: posts.isEmpty && isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: scrollController,
              itemCount: posts.length + 1,
              itemBuilder: (context, index) {
                if (index == posts.length) {
                  if (!hasMore) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text("No more posts")),
                    );
                  }

                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final post = posts[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(radius: 18),
                            const SizedBox(width: 10),

                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProfileScreen(
                                      userId: post["author"]["_id"],
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                post["author"]["name"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final postId = post["_id"];

                                final result = await ApiService.deletePost(
                                  postId,
                                );

                                if (result["success"] == true) {
                                  setState(() {
                                    posts.removeAt(index);
                                  });
                                }
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Text(
                          post["content"] ?? "",
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                post["isLiked"] == true
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: post["isLiked"] == true
                                    ? Colors.red
                                    : Colors.white,
                              ),
                              onPressed: () async {
                                final postId = post["_id"];

                                print("CLICKED LIKE: $postId");

                                final result = await ApiService.toggleLike(
                                  postId,
                                );

                                print("LIKE RESPONSE: $result");

                                if (result["success"] == true) {
                                  setState(() {
                                    post["isLiked"] = result["isLiked"];
                                    post["likesCount"] = result["likesCount"];
                                  });
                                }
                              },
                            ),

                            Text("${post["likesCount"] ?? 0} likes"),
                            IconButton(
                              icon: const Icon(Icons.comment),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CommentScreen(postId: post["_id"]),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
