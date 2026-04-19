import 'package:flutter/material.dart';
import 'package:social_app_flutter/features/navigation/main_nav_screen.dart';
import '../../services/api_service.dart';
import '../../core/auth_storage.dart';
//import '../home/home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await ApiService.login(email: email, password: password);

      // ✅ FIXED LOGIC (based on your backend response)
      if (result["token"] != null) {
        await AuthStorage.saveTokens(
          token: result["token"],
          refreshToken: result["refreshToken"],
        );

        // 🔥 CRITICAL FIX
        await AuthStorage.saveUserId(result["user"]["id"]);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Login failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔥 TITLE
                const Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                // 📧 EMAIL
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),

                const SizedBox(height: 16),

                // 🔒 PASSWORD
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                ),

                const SizedBox(height: 24),

                // 🔥 LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text("Login"),
                  ),
                ),

                const SizedBox(height: 12),

                // 🔁 SWITCH TO SIGNUP
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                  child: const Text("Create new account"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
