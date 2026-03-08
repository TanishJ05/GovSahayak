import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static const String baseUrl = "http://127.0.0.1:5001/api/chat";

  // This variable stores the language chosen in the Profile Screen
  static String currentLanguage = "Auto-detect"; 

  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "message": message,
          "user_id": 1, 
          "language": currentLanguage // <-- This sends it to the backend!
        }),
      ).timeout(const Duration(seconds: 10)); 

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["reply"] ?? "I couldn't process that. Please try again.";
      } else {
        return "The server returned an error (${response.statusCode}). Please try again later.";
      }
    } catch (e) {
      print("Chat Error: $e");
      return "Network error. Please check your connection and ensure the backend is running.";
    }
  }
}