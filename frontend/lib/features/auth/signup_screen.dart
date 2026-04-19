import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) return;

    setState(() => isLoading = true);

    final result = await ApiService.register(
      name: name,
      email: email,
      password: password,
    );

    setState(() => isLoading = false);

    if (result["success"] == true) {
      Navigator.pop(context); // Back to login
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signup")),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                TextField(decoration: const InputDecoration(labelText: "Name")),

                const SizedBox(height: 16),

                TextField(
                  decoration: const InputDecoration(labelText: "Email"),
                ),

                const SizedBox(height: 16),

                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text("Sign Up"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
