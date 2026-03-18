import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'customer_product_page.dart';
import 'login_page.dart';

class CustomerMachinePage extends StatefulWidget {
  const CustomerMachinePage({super.key});

  @override
  State<CustomerMachinePage> createState() => _CustomerMachinePageState();
}

class _CustomerMachinePageState extends State<CustomerMachinePage> {
  final supabase = Supabase.instance.client;
  List machines = [];

  @override
  void initState() {
    super.initState();
    loadMachines();
  }

  Future loadMachines() async {
    final data = await supabase.from('vending_machine').select();
    setState(() {
      machines = data;
    });
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Machine"),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout)
        ],
      ),
      body: machines.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(6),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,      // 3 per row
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 1.8,  // wider & flat
                ),
                itemCount: machines.length,
                itemBuilder: (context, index) {
                  final machine = machines[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerProductPage(
                            machineId: machine['machine_id'],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 8), // tight but slightly bigger
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.local_drink,
                              size: 24, // slightly bigger
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Machine ${machine['machine_id']}",
                              style: const TextStyle(
                                fontSize: 14, // back to normal
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    machine['location'],
                                    style: const TextStyle(
                                      fontSize: 12, // normal size
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}