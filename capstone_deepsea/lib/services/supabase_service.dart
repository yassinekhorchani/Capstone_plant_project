import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SupabaseService {
  // Replace these with your Supabase credentials
  static const String supabaseUrl = 'https://byjggezkzradwjxzoitf.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ5amdnZXprenJhZHdqeHpvaXRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4MzM2NTYsImV4cCI6MjA3OTQwOTY1Nn0.H-F1Q5QDuUyLdf9RmZmzfdFyc-46Zch6hSTbgJfMJDk';
  static const String bucketName = 'plant-images';

  // Upload image to Supabase Storage
  Future<String?> uploadImage(File imageFile, String userId) async {
    try {
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imageFile.path.split('.').last;
      final fileName = '${userId}_$timestamp.$extension';
      final filePath = 'detections/$fileName';

      // Read file bytes
      final bytes = await imageFile.readAsBytes();

      // Upload to Supabase Storage
      final response = await http.post(
        Uri.parse('$supabaseUrl/storage/v1/object/$bucketName/$filePath'),
        headers: {
          'Authorization': 'Bearer $supabaseAnonKey',
          'apikey': supabaseAnonKey,
          'Content-Type': 'image/$extension',
        },
        body: bytes,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Get public URL
        final publicUrl = '$supabaseUrl/storage/v1/object/public/$bucketName/$filePath';
        print('✅ Image uploaded to Supabase: $publicUrl');
        return publicUrl;
      } else {
        print('❌ Upload failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error uploading image: $e');
      return null;
    }
  }

  // Delete image from Supabase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final filePathIndex = pathSegments.indexOf(bucketName) + 1;
      final filePath = pathSegments.sublist(filePathIndex).join('/');

      final response = await http.delete(
        Uri.parse('$supabaseUrl/storage/v1/object/$bucketName/$filePath'),
        headers: {
          'Authorization': 'Bearer $supabaseAnonKey',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Image deleted from Supabase');
        return true;
      } else {
        print('❌ Delete failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting image: $e');
      return false;
    }
  }

  // Get image URLs for a user
  Future<List<String>> getUserImages(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/storage/v1/object/list/$bucketName'),
        headers: {
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prefix': 'detections/',
          'limit': 100,
          'offset': 0,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> files = jsonDecode(response.body);
        final userFiles = files.where((file) {
          final name = file['name'] as String;
          return name.startsWith(userId);
        }).toList();

        return userFiles.map((file) {
          final fileName = file['name'] as String;
          return '$supabaseUrl/storage/v1/object/public/$bucketName/detections/$fileName';
        }).toList();
      } else {
        print('❌ Failed to list images: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error listing images: $e');
      return [];
    }
  }
}
