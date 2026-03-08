// frontend/lib/screens/applications/my_applications_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({Key? key}) : super(key: key);

  @override
  _MyApplicationsScreenState createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  List<dynamic> applications = [];
  bool isLoading = true;
  final TextEditingController _trackController = TextEditingController();
  bool isTracking = false;

  @override
  void initState() {
    super.initState();
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5001/api/applications/user/1'))
          .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        setState(() {
          applications = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Fetch error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> trackSpecificApplication() async {
    if (_trackController.text.trim().isEmpty) return;
    
    setState(() => isTracking = true);
    FocusScope.of(context).unfocus();

    try {
      final String idToTrack = _trackController.text.trim();
      final response = await http.get(Uri.parse('http://127.0.0.1:5001/api/applications/track/$idToTrack'))
          .timeout(const Duration(seconds: 10));

      setState(() => isTracking = false);

      if (response.statusCode == 200) {
        final appData = jsonDecode(response.body);
        _showTrackDialog(appData);
        _trackController.clear();
      } else {
        _showErrorDialog();
      }
    } catch (e) {
      setState(() => isTracking = false);
      _showErrorDialog();
    }
  }

  void _showTrackDialog(Map<String, dynamic> appData) {
    final isPending = appData['status'].toString().toLowerCase() == 'pending';
    final rawDate = appData['created_at']?.toString() ?? '';
    final safeDate = rawDate.length >= 10 ? rawDate.substring(0, 10) : 'Recent';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Application Status", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Service: ${appData['service_type'].toString().replaceAll('_', ' ').toUpperCase()}"),
            const SizedBox(height: 8),
            Text("Tracking ID: ${appData['id']}"),
            const SizedBox(height: 8),
            Text("Date: $safeDate"),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isPending ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "STATUS: ${appData['status'].toString().toUpperCase()}",
                style: TextStyle(
                  color: isPending ? Colors.orange[800] : Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Not Found"),
        content: const Text("We could not find an application with that Tracking ID."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("My Applications", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A3C6E), 
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: fetchApplications)
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _trackController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter Tracking ID...",
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF1A3C6E)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: isTracking ? null : trackSpecificApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3C6E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isTracking 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Track"),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A3C6E)))
              : applications.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text("No applications found.", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: fetchApplications,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: applications.length,
                      itemBuilder: (context, index) {
                        final app = applications[index];
                        final isPending = app['status'].toString().toLowerCase() == 'pending';
                        final rawDate = app['created_at']?.toString() ?? '';
                        final safeDate = rawDate.length >= 10 ? rawDate.substring(0, 10) : 'Recent';
                        
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              app['service_type'].toString().replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text("Tracking ID: ${app['id']}\nDate: $safeDate"),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isPending ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                app['status'].toString().toUpperCase(),
                                style: TextStyle(
                                  color: isPending ? Colors.orange[800] : Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}