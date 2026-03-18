import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final supabase = Supabase.instance.client;

  List machines = [];
  List inventory = [];
  bool isLoadingMachines = true;
  bool isLoadingInventory = true;

  int? selectedMachineId;
  String selectedMachineLocation = "";

  @override
  void initState() {
    super.initState();
    loadMachines();
  }

  /// Load all machines sorted by machine_id
  Future<void> loadMachines() async {
    try {
      final data = await supabase
          .from('vending_machine')
          .select()
          .order('machine_id', ascending: true);

      setState(() {
        machines = data;
        isLoadingMachines = false;
        if (machines.isNotEmpty) {
          selectedMachineId = machines[0]['machine_id'];
          selectedMachineLocation = machines[0]['location'];
          loadInventory(selectedMachineId!);
        }
      });
    } catch (e) {
      setState(() => isLoadingMachines = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading machines: $e")),
      );
    }
  }

  /// Load inventory for selected machine
  Future<void> loadInventory(int machineId) async {
    setState(() => isLoadingInventory = true);
    try {
      final data = await supabase.from('machine_inventory').select('''
        quantity_available,
        product(product_name, price)
      ''').eq('machine_id', machineId);

      setState(() {
        inventory = data;
        isLoadingInventory = false;
      });
    } catch (e) {
      setState(() => isLoadingInventory = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading inventory: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Machine Inventory"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            /// ✅ Machine selector dropdown
            isLoadingMachines
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<int>(
                    value: selectedMachineId,
                    decoration: InputDecoration(
                      labelText: "Select Machine",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: machines
                        .map((m) => DropdownMenuItem<int>(
                              value: m['machine_id'],
                              child: Text(
                                  "Machine #${m['machine_id']} (${m['location']})"),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMachineId = value;
                        final machine =
                            machines.firstWhere((m) => m['machine_id'] == value);
                        selectedMachineLocation = machine['location'];
                        loadInventory(value!);
                      });
                    },
                  ),
            const SizedBox(height: 12),

            /// ✅ Inventory Grid
            Expanded(
              child: isLoadingInventory
                  ? const Center(child: CircularProgressIndicator())
                  : inventory.isEmpty
                      ? const Center(child: Text("No products available"))
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: inventory.length,
                          itemBuilder: (context, index) {
                            final item = inventory[index];
                            final product = item['product'];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['product_name'],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "Stock: ${item['quantity_available']}",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      "₹${product['price']}",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}