import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RestockMachinePage extends StatefulWidget {
  const RestockMachinePage({Key? key}) : super(key: key);

  @override
  State<RestockMachinePage> createState() => _RestockMachinePageState();
}

class _RestockMachinePageState extends State<RestockMachinePage> {
  final supabase = Supabase.instance.client;

  List machines = [];
  List products = [];
  List lowStockMachines = [];

  int? selectedMachine;
  int? selectedProduct;

  final TextEditingController quantityController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadMachines();
    loadProducts();
    loadLowStockMachines();
  }

  // ================= LOAD MACHINES =================
  Future<void> loadMachines() async {
    try {
      final data = await supabase.from('vending_machine').select();
      setState(() => machines = data);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error loading machines: $e")));
    }
  }

  // ================= LOAD PRODUCTS =================
  Future<void> loadProducts() async {
    try {
      final data = await supabase.from('product').select();
      setState(() => products = data);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error loading products: $e")));
    }
  }

  // ================= LOAD LOW STOCK =================
  Future<void> loadLowStockMachines() async {
    try {
      setState(() => isLoading = true);

      final data = await supabase.from('machine_inventory').select(
          'inventory_id, machine_id, product_id, quantity_available, min_quantity, vending_machine(location), product(product_name)');

      // ✅ FILTER IN FLUTTER
      final filtered = data.where((item) {
        final qty = item['quantity_available'] ?? 0;
        final min = item['min_quantity'] ?? 5;
        return qty < min;
      }).toList();

      setState(() => lowStockMachines = filtered);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error loading low stock: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= RESTOCK =================
  Future<void> restockMachine() async {
    if (selectedMachine == null ||
        selectedProduct == null ||
        quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      final qty = int.parse(quantityController.text);

      final existing = await supabase
          .from('machine_inventory')
          .select()
          .eq('machine_id', selectedMachine!)
          .eq('product_id', selectedProduct!)
          .maybeSingle();

      if (existing != null) {
        // UPDATE
        await supabase.from('machine_inventory').update({
          'quantity_available': existing['quantity_available'] + qty,
          'last_restocked': DateTime.now().toIso8601String(),
        }).eq('inventory_id', existing['inventory_id']);
      } else {
        // INSERT
        await supabase.from('machine_inventory').insert({
          'machine_id': selectedMachine,
          'product_id': selectedProduct,
          'quantity_available': qty,
          'min_quantity': 5,
          'last_restocked': DateTime.now().toIso8601String(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Machine Restocked Successfully")),
      );

      quantityController.clear();

      await loadLowStockMachines(); // refresh
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }


  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restock Machine"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔴 LOW STOCK SECTION
                    if (lowStockMachines.isNotEmpty) ...[
                      const Text(
                        "Machines Needing Restock",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      ...lowStockMachines.map((m) {
                        final qty = m['quantity_available'] ?? 0;

                        return Card(
                          color: qty == 0
                              ? Colors.red.shade100
                              : Colors.blue.shade200,
                          child: ListTile(
                            title: Text(
                                "Machine ${m['machine_id']} - ${m['vending_machine']['location']}"),
                            subtitle: Text(
                                "Product: ${m['product']['product_name']} | Qty: $qty (Min: ${m['min_quantity']})"),
                            onTap: () {
                              // 🔥 AUTO SELECT
                              setState(() {
                                selectedMachine = m['machine_id'];
                                selectedProduct = m['product_id'];
                              });
                            },
                          ),
                        );
                      }),

                      const SizedBox(height: 10),

                     

                      const SizedBox(height: 25),
                    ],

                    /// MACHINE DROPDOWN
                    const Text("Select Machine"),
                    DropdownButton<int>(
                      isExpanded: true,
                      value: selectedMachine == null ? null : selectedMachine,
                      hint: const Text("Choose Machine"),
                      items: machines.map<DropdownMenuItem<int>>((machine) {
                        return DropdownMenuItem<int>(
                          value: machine['machine_id'] as int,
                          child: Text(
                              "Machine ${machine['machine_id']} - ${machine['location']}"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedMachine = value);
                      },
                      onTap: loadMachines,
                    ),

                    const SizedBox(height: 20),

                    /// PRODUCT DROPDOWN
                    const Text("Select Product"),
                    DropdownButton<int>(
                      isExpanded: true,
                      value: selectedProduct == null ? null : selectedProduct,
                      hint: const Text("Choose Product"),
                      items: products.map<DropdownMenuItem<int>>((product) {
                        return DropdownMenuItem<int>(
                          value: product['product_id'] as int,
                          child: Text(product['product_name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedProduct = value);
                      },
                      onTap: loadProducts,
                    ),

                    const SizedBox(height: 20),

                    /// QUANTITY
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Enter Quantity",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// BUTTON
                    Center(
                      child: ElevatedButton(
                        onPressed: restockMachine,
                        child: const Text("Restock Machine"),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
