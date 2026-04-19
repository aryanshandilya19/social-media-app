import 'package:flutter/material.dart';
import '../../core/auth_storage.dart';
import '../profile/profile_screen.dart';
import '../feed/feed_screen.dart';
import '../post/create_post_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthStorage.getUserId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userId = snapshot.data!;

        final screens = [
          const FeedScreen(), // 🏠 HOME
          const SizedBox(), // ➕ (handled separately)
          ProfileScreen(userId: userId), // 👤 PROFILE
        ];

        return Scaffold(
          body: screens[index],

          // 🔥 FLOATING CREATE BUTTON (BEST UX)
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePostScreen()),
              );
            },
            child: const Icon(Icons.add),
          ),

          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,

          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 🏠 HOME
                IconButton(
                  icon: Icon(
                    Icons.home,
                    color: index == 0 ? Colors.white : Colors.grey,
                  ),
                  onPressed: () => setState(() => index = 0),
                ),

                const SizedBox(width: 40), // space for FAB
                // 👤 PROFILE
                IconButton(
                  icon: Icon(
                    Icons.person,
                    color: index == 2 ? Colors.white : Colors.grey,
                  ),
                  onPressed: () => setState(() => index = 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
