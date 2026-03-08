// frontend/lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import '../login/login_screen.dart';
import '../../services/chat_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Select Language", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...['Auto-detect', 'English', 'Hindi', 'Marathi'].map((String lang) {
                return ListTile(
                  title: Text(lang),
                  trailing: ChatService.currentLanguage == lang 
                      ? const Icon(Icons.check_circle, color: Color(0xFF2E7D32)) 
                      : null,
                  onTap: () {
                    setState(() {
                      ChatService.currentLanguage = lang;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Language set to $lang")));
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
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
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 20),
          const Center(
            child: CircleAvatar(radius: 50, backgroundColor: Color(0xFF2E7D32), child: Icon(Icons.person, size: 50, color: Colors.white)),
          ),
          const SizedBox(height: 16),
          const Center(child: Text("Demo Citizen", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          const Center(child: Text("demo@senate.gov", style: TextStyle(fontSize: 16, color: Colors.grey))),
          const SizedBox(height: 30),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("Preferences", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A3C6E))),
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Color(0xFF1A3C6E)),
            title: const Text("Language"),
            subtitle: Text(ChatService.currentLanguage),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showLanguagePicker,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
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