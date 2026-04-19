import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/auth_storage.dart';

class ApiService {
  // 🔥 IMPORTANT: YOUR LIVE BACKEND
  static const String baseUrl = "https://social-backend-zn0w.onrender.com";

  // 🔥 COMMON HEADERS
  static Future<Map<String, String>> _headers() async {
    final token = await AuthStorage.getToken();

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // 🔐 LOGIN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }

  // 🔐 REGISTER
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }

  // 📰 FEED
  static Future<Map<String, dynamic>> getFeed({String? cursor}) async {
    final uri = cursor == null
        ? Uri.parse("$baseUrl/api/posts/feed")
        : Uri.parse("$baseUrl/api/posts/feed?cursor=$cursor");

    final response = await http.get(uri, headers: await _headers());

    return jsonDecode(response.body);
  }

  // 📝 CREATE POST
  static Future<Map<String, dynamic>> createPost({
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/posts"),
      headers: await _headers(),
      body: jsonEncode({"content": content}),
    );

    return jsonDecode(response.body);
  }

  // ❤️ LIKE
  static Future<Map<String, dynamic>> toggleLike(String postId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/posts/$postId/like"),
      headers: await _headers(),
    );

    return jsonDecode(response.body);
  }

  // 💬 COMMENTS
  static Future<Map<String, dynamic>> getComments(String postId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/comments/$postId"),
      headers: await _headers(),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addComment({
    required String postId,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/comments/$postId"),
      headers: await _headers(),
      body: jsonEncode({"content": content}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteComment(String commentId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/api/comments/$commentId"),
      headers: await _headers(),
    );

    return jsonDecode(response.body);
  }

  // 🗑 DELETE POST
  static Future<Map<String, dynamic>> deletePost(String postId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/api/posts/$postId"),
      headers: await _headers(),
    );

    return jsonDecode(response.body);
  }

  // 👤 PROFILE
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/users/$userId"),
      headers: await _headers(),
    );

    return jsonDecode(response.body);
  }

  // 🔥 FOLLOW USER
  static Future<Map<String, dynamic>> followUser(String userId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/users/$userId/follow"),
      headers: await _headers(),
    );

    return jsonDecode(response.body);
  }

  // 🔥 UNFOLLOW USER
  static Future<Map<String, dynamic>> unfollowUser(String userId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/users/$userId/unfollow"),
      headers: await _headers(),
    );

    return jsonDecode(response.body);
  }

  // 👥 USERS LIST
  static Future<List> getAllUsers() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/users"),
      headers: await _headers(),
    );

    final data = jsonDecode(response.body);
    return data["data"] ?? [];
  }

  // 📝 ALL POSTS (for profile filtering)
  static Future<Map<String, dynamic>> getPosts() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/posts"),
      headers: await _headers(),
    );

    return jsonDecode(response.body);
  }

  // 🔥 USER POSTS
  static Future<Map<String, dynamic>> getUserPosts(String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/posts/user/$userId"),
      headers: await _headers(),
    );

    return jsonDecode(response.body);
  }
}
