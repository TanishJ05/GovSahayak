// frontend/lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import '../login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Select Language",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: const Text("Auto-detect"),
                onTap: () => _updateLanguage("Auto-detect"),
              ),
              ListTile(
                title: const Text("English"),
                onTap: () => _updateLanguage("English"),
              ),
              ListTile(
                title: const Text("Hindi"),
                onTap: () => _updateLanguage("Hindi"),
              ),
              ListTile(
                title: const Text("Marathi"),
                onTap: () => _updateLanguage("Marathi"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateLanguage(String lang) {
    setState(() {
      ChatService.currentLanguage = lang; 
    });
    Navigator.pop(context); 
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Language set to $lang")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile & Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A3C6E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF1A3C6E),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text("Demo Citizen", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 30),
          const Text("Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language, color: Color(0xFF1A3C6E)),
            title: const Text("Language"),
            subtitle: Text(ChatService.currentLanguage), 
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showLanguagePicker, 
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: Color(0xFF1A3C6E)),
            title: const Text("Notifications"),
            subtitle: const Text("Push notifications enabled"),
            trailing: Switch(value: true, onChanged: (val) {}),
          ),
          const Divider(),
          // The Missing Log Out Button!
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Log Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              // Reset the language back to default on logout
              ChatService.currentLanguage = "Auto-detect";
              
              // Clear the navigation history and go back to Login
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}