import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAlertPage extends StatefulWidget {
  const AdminAlertPage({super.key});

  @override
  State<AdminAlertPage> createState() => _AdminAlertPageState();
}

class _AdminAlertPageState extends State<AdminAlertPage> {

  final supabase = Supabase.instance.client;

  List machines = [];
  int? selectedMachineId;

  final issueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadMachines();
  }

  // ================= LOAD MACHINES =================
  Future<void> loadMachines() async {

    final data = await supabase
        .from('vending_machine')
        .select();

    setState(() {
      machines = data;
    });
  }

  // ================= ALERT TECHNICIAN =================
  Future<void> alertTechnician() async {

    if (selectedMachineId == null || issueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    await supabase.from('technician_requests').insert({
      'machine_id': selectedMachineId,
      'issue': issueController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Technician Alert Sent 🚨"),
        backgroundColor: Colors.green,
      ),
    );

    issueController.clear();

    setState(() {
      selectedMachineId = null;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.blue[50],

      appBar: AppBar(
        title: const Text("Alert Technician"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// MACHINE DROPDOWN
                DropdownButtonFormField<int>(
                  value: selectedMachineId,

                  decoration: InputDecoration(
                    labelText: "Select Machine",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  items: machines.map<DropdownMenuItem<int>>((m) {
                    return DropdownMenuItem(
                      value: m['machine_id'],
                      child: Text(
                          "Machine ${m['machine_id']} - ${m['location']}"),
                    );
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedMachineId = value;
                    });
                  },
                ),

                const SizedBox(height: 15),

                /// ISSUE FIELD
                TextField(
                  controller: issueController,
                  maxLines: 3,

                  decoration: InputDecoration(
                    labelText: "Describe Issue",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// BUTTON
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: alertTechnician,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: const Text(
                      "Alert Technician",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}