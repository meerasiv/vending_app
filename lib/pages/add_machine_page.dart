import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddMachinePage extends StatefulWidget {
  const AddMachinePage({super.key});

  @override
  State<AddMachinePage> createState() => _AddMachinePageState();
}

class _AddMachinePageState extends State<AddMachinePage> {
  final supabase = Supabase.instance.client;

  final List<String> locations = [
    'Thiruvananthapuram',
    'Kollam',
    'Pathanamthitta',
    'Alappuzha'
    'Kottayam',
    'Idukki',
    'Ernakulam',
    'Thrissur',
    'Palakkad',
    'Malappuram',
    'Kozhikode',
    'Wayanad',
    'Kannur',
    'Kasaragod'
  ];
  String selectedLocation = 'Thiruvananthapuram';

  final List<String> statuses = ['Active', 'Inactive'];
  String selectedStatus = 'Active';

  bool isLoading = false;

  Future<void> addMachine() async {
    try {
      setState(() => isLoading = true);

      final response = await supabase
          .from('vending_machine')
          .insert({
            'location': selectedLocation,
            'status': selectedStatus.toLowerCase(),
          })
          .select()
          .single();

      final machineId = response['machine_id'];

      if (selectedStatus == 'Inactive') {
        await supabase.from('technician_requests').insert({
          'machine_id': machineId,
          'issue': 'Machine created as inactive',
          'status': 'Pending',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Machine Added Successfully ✅")),
      );

      setState(() {
        selectedLocation = locations[0];
        selectedStatus = statuses[0];
      });

      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("Add New Machine"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// 🎨 Card container for dropdowns
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  children: [
                    /// 📍 LOCATION
                    DropdownButtonFormField(
                      value: selectedLocation,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.location_on, color: Colors.blue),
                        labelText: "Select Location",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: locations
                          .map((loc) => DropdownMenuItem(
                                value: loc,
                                child: Text(loc),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedLocation = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    /// ⚙ STATUS
                    DropdownButtonFormField(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.toggle_on, color: Colors.blue),
                        labelText: "Select Status",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: statuses
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// ➕ ADD MACHINE BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : addMachine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                ),
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: Text(
                  isLoading ? "Adding..." : "Add Machine",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}