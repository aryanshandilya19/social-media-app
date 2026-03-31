import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController contentController = TextEditingController();
  bool isLoading = false;

  Future<void> createPost() async {
    final content = contentController.text.trim();
    if (content.isEmpty) return;

    setState(() => isLoading = true);

    final result = await ApiService.createPost(content: content);

    setState(() => isLoading = false);

    if (result["success"] == true) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post created successfully")),
      ); // notify feed
    }
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "What's on your mind?",
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : createPost,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Post"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
