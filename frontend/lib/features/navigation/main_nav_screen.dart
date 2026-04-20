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
  int profileRefreshNonce = 0;

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
          const FeedScreen(),
          const SizedBox(),
          ProfileScreen(
            key: ValueKey('profile_$profileRefreshNonce'),
            userId: userId,
          ),
        ];

        return Scaffold(
          body: screens[index],

          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final created = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePostScreen()),
              );

              if (created == true && index == 2) {
                setState(() {
                  profileRefreshNonce++;
                });
              }
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
                IconButton(
                  icon: Icon(
                    Icons.home,
                    color: index == 0 ? Colors.white : Colors.grey,
                  ),
                  onPressed: () => setState(() => index = 0),
                ),
                const SizedBox(width: 40),
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
