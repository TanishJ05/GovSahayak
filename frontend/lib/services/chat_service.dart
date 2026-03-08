// frontend/lib/services/chat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  // Use 127.0.0.1 for Chrome Web testing. (Use 10.0.2.2 if you switch to Android Emulator later).
  static const String baseUrl = "http://127.0.0.1:5001/api/chat";
  
  // Store the user's selected language globally
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
          "user_id": 1, // Hardcoded for MVP hackathon
          "language": currentLanguage 
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