import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'package:intl/intl.dart';

class TechnicianPage extends StatefulWidget {
  const TechnicianPage({super.key});

  @override
  State<TechnicianPage> createState() => _TechnicianPageState();
}

class _TechnicianPageState extends State<TechnicianPage> {
  final supabase = Supabase.instance.client;

  List requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  // ================= LOAD REQUESTS =================
  Future<void> loadRequests() async {
    try {
      setState(() => isLoading = true);

      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      // Get technician info
      final tech = await supabase
          .from('technician')
          .select()
          .eq('email', user.email!)
          .single();

      final technicianId = tech['technician_id'];

      // Get machines assigned
      final mapping = await supabase
          .from('technician_machine')
          .select('machine_id')
          .eq('technician_id', technicianId);

      final machineIds = mapping.map((m) => m['machine_id']).toList();

      if (machineIds.isEmpty) {
        setState(() {
          requests = [];
          isLoading = false;
        });
        return;
      }

      // Get pending requests for these machines
      final data = await supabase
          .from('technician_requests')
          .select()
          .inFilter('machine_id', machineIds)
          .order('created_at', ascending: false);

      setState(() {
        requests = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error loading requests: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await supabase.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // ================= RESOLVE REQUEST =================
  Future<void> resolveRequest(int requestId) async {
    try {
      // Delete request from technician_requests table
      await supabase
          .from('technician_requests')
          .delete()
          .eq('request_id', requestId);

      // Refresh dashboard
      loadRequests();

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Request resolved ✅")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error resolving: $e")));
    }
  }

  // ================= FORMAT DATE =================
  String formatDate(String rawDate) {
    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("Technician Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle, size: 60, color: Colors.green),
                      SizedBox(height: 10),
                      Text(
                        "No pending requests 🎉",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final req = requests[index];

                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // HEADER
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Machine #${req['machine_id']}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const Chip(
                                    label: Text(
                                      "PENDING",
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // ISSUE
                              Text(
                                req['issue'] ?? "No issue provided",
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 10),
                              // DATE
                              Text(
                                "Reported: ${formatDate(req['created_at'])}",
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 12),
                              // RESOLVE BUTTON
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () =>
                                        resolveRequest(int.parse(req['request_id'].toString())),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text("Resolved"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}