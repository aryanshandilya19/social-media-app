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

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final id = await AuthStorage.getUserId();

      final profile = await ApiService.getUserProfile(widget.userId);
      final userPosts = await ApiService.getUserPosts(widget.userId);

      setState(() {
        currentUserId = id;
        user = profile["data"];
        posts = userPosts["data"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?["name"] ?? ""),
              accountEmail: Text(user?["email"] ?? ""),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => logout(context),
            ),
          ],
        ),
      ),
      appBar: AppBar(title: Text(user?["name"] ?? "Profile")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Followers: ${user?["followersCount"]}"),
          Text("Following: ${user?["followingCount"]}"),
          if (currentUserId != widget.userId)
            ElevatedButton(
              onPressed: toggleFollow,
              child: Text(user?["isFollowing"] == true ? "Unfollow" : "Follow"),
            ),
          const SizedBox(height: 20),
          ...posts.map((p) => Text(p["content"] ?? "")).toList(),
        ],
      ),
    );
  }
}
