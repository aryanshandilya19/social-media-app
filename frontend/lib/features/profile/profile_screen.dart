import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map user = {};
  bool isLoading = true;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      print("➡️ Fetching profile for: ${widget.userId}");

      final result = await ApiService.getUserProfile(widget.userId);

      print("✅ PROFILE RESPONSE: $result");

      setState(() {
        user = result["data"] ?? {};
        isFollowing = user["isFollowing"] ?? false;
        isLoading = false;
      });
    } catch (e) {
      print("❌ PROFILE ERROR: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> toggleFollow() async {
    final result = isFollowing
        ? await ApiService.unfollowUser(widget.userId)
        : await ApiService.followUser(widget.userId);

    if (result["success"] == true) {
      setState(() {
        isFollowing = !isFollowing;

        if (isFollowing) {
          user["followersCount"]++;
        } else {
          user["followersCount"]--;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(radius: 40),

                const SizedBox(height: 20),

                Text(
                  user["name"] ?? "User",
                  style: const TextStyle(fontSize: 20),
                ),

                const SizedBox(height: 10),

                Text("${user["followersCount"] ?? 0} Followers"),

                Text("${user["followingCount"] ?? 0} Following"),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: toggleFollow,
                  child: Text(isFollowing ? "Unfollow" : "Follow"),
                ),
              ],
            ),
    );
  }
}
