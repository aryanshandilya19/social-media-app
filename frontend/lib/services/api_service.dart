import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/auth_storage.dart';

class ApiService {
  static const String baseUrl = "http://localhost:5000";

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

  // ✅ THIS MUST BE INSIDE ApiService CLASS
  static Future<Map<String, dynamic>> getFeed({String? cursor}) async {
    final token = await AuthStorage.getToken();

    final uri = cursor == null
        ? Uri.parse("$baseUrl/api/posts/feed")
        : Uri.parse("$baseUrl/api/posts/feed?cursor=$cursor");

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createPost({
    required String content,
  }) async {
    final token = await AuthStorage.getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/api/posts"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"content": content}),
    );

    return jsonDecode(response.body);
  }

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

  static Future<Map<String, dynamic>> toggleLike(String postId) async {
    final token = await AuthStorage.getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/api/posts/$postId/like"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getComments(String postId) async {
    final token = await AuthStorage.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/api/comments/$postId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addComment({
    required String postId,
    required String content,
  }) async {
    final token = await AuthStorage.getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/api/comments/$postId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"content": content}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deletePost(String postId) async {
    final token = await AuthStorage.getToken();

    final response = await http.delete(
      Uri.parse("$baseUrl/api/posts/$postId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteComment(String commentId) async {
    final token = await AuthStorage.getToken();

    final response = await http.delete(
      Uri.parse("$baseUrl/api/comments/$commentId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final token = await AuthStorage.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/api/users/$userId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> followUser(String userId) async {
    final token = await AuthStorage.getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/api/users/$userId/follow"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> unfollowUser(String userId) async {
    final token = await AuthStorage.getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/api/users/$userId/unfollow"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

  static Future<List> getAllUsers() async {
    final token = await AuthStorage.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/api/users"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);
    return data["data"] ?? [];
  }
}
