import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../core/auth_storage.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  List posts = [];

  bool isLoading = true;
  String? currentUserId;
  bool isMyProfile = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // 🚀 LOAD PROFILE
  Future<void> loadProfile() async {
    try {
      final id = await AuthStorage.getUserId();

      final profile = await ApiService.getUserProfile(widget.userId);
      final userPosts = await ApiService.getUserPosts(widget.userId);

      setState(() {
        currentUserId = id;
        isMyProfile = id == widget.userId;

        user = profile["data"];

        // 🔥 SAFE FIX (handles both data/posts)
        posts = (userPosts["data"] ?? userPosts["posts"] ?? []);

        print("🔥 POSTS: $posts"); // DEBUG

        isLoading = false;
      });
    } catch (e) {
      print("💥 ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  // 🚀 FOLLOW / UNFOLLOW
  Future<void> toggleFollow() async {
    final isFollowing = user?["isFollowing"] ?? false;

    if (isFollowing) {
      await ApiService.unfollowUser(widget.userId);
    } else {
      await ApiService.followUser(widget.userId);
    }

    setState(() {
      user!["isFollowing"] = !isFollowing;
      user!["followersCount"] += isFollowing ? -1 : 1;
    });
  }

  // 🚀 LOGOUT WITH CONFIRMATION
  Future<void> logout(BuildContext context) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text("Logout", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthStorage.clear();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // 🚀 DRAWER (ONLY FOR YOUR PROFILE)
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.black),
            accountName: Text(user?["name"] ?? ""),
            accountEmail: Text(user?["email"] ?? ""),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () => logout(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      // ✅ DRAWER ONLY FOR OWN PROFILE
      drawer: isMyProfile ? _buildDrawer(context) : null,

      appBar: AppBar(title: Text(user?["name"] ?? "Profile")),

      body: RefreshIndicator(
        onRefresh: loadProfile,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 👤 USER INFO
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    user?["name"] ?? "",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Followers: ${user?["followersCount"] ?? 0}"),
                      const SizedBox(width: 20),
                      Text("Following: ${user?["followingCount"] ?? 0}"),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // 🔥 CONDITIONAL BUTTON
                  if (isMyProfile)
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text("Edit Profile"),
                    )
                  else
                    ElevatedButton(
                      onPressed: toggleFollow,
                      child: Text(
                        user?["isFollowing"] == true ? "Unfollow" : "Follow",
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),

            // 📝 POSTS
            if (posts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("No posts yet 🚀"),
                ),
              ),

            ...posts.map((post) {
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(post["content"] ?? ""),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
