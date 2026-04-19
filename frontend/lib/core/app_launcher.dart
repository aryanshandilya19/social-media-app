import 'package:flutter/material.dart';
import '../features/navigation/main_nav_screen.dart';
import '../features/auth/login_screen.dart';
import '../core/auth_storage.dart';

class AppLauncher extends StatefulWidget {
  const AppLauncher({super.key});

  @override
  State<AppLauncher> createState() => _AppLauncherState();
}

class _AppLauncherState extends State<AppLauncher> {
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  void checkAuth() async {
    final token = await AuthStorage.getToken();

    setState(() {
      isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ⏳ LOADING STATE
    if (isLoggedIn == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 🔥 FINAL ROUTING
    if (isLoggedIn == true) {
      return const MainNavScreen(); // ✅ FIXED
    } else {
      return const LoginScreen();
    }
  }
}
