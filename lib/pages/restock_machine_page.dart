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

  int? selectedMachine;
  int? selectedProduct;

  final TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadMachines();
    loadProducts();
  }

  // Load machines
  Future<void> loadMachines() async {

    final data = await supabase
        .from('vending_machine')
        .select();

    setState(() {
      machines = data;
    });
  }

  // Load products
  Future<void> loadProducts() async {

    final data = await supabase
        .from('product')
        .select();

    setState(() {
      products = data;
    });
  }

  // Insert inventory
  Future<void> restockMachine() async {

    if (selectedMachine == null ||
        selectedProduct == null ||
        quantityController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );

      return;
    }

    await supabase.from('machine_inventory').insert({
      'machine_id': selectedMachine,
      'product_id': selectedProduct,
      'quantity_available': int.parse(quantityController.text),
      'last_restocked': DateTime.now().toString()
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Machine Restocked Successfully")),
    );

    quantityController.clear();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Restock Machine"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Select Machine",
              style: TextStyle(fontSize: 16),
            ),

            DropdownButton<int>(
              value: selectedMachine,
              hint: const Text("Choose Machine"),

              items: machines.map<DropdownMenuItem<int>>((machine) {

                return DropdownMenuItem<int>(
                  value: machine['machine_id'],
                  child: Text(machine['location']),
                );

              }).toList(),

              onChanged: (value) {
                setState(() {
                  selectedMachine = value;
                });
              },
            ),

            const SizedBox(height: 25),

            const Text(
              "Select Product",
              style: TextStyle(fontSize: 16),
            ),

            DropdownButton<int>(
              value: selectedProduct,
              hint: const Text("Choose Product"),

              items: products.map<DropdownMenuItem<int>>((product) {

                return DropdownMenuItem<int>(
                  value: product['product_id'],
                  child: Text(product['product_name']),
                );

              }).toList(),

              onChanged: (value) {
                setState(() {
                  selectedProduct = value;
                });
              },
            ),

            const SizedBox(height: 25),

            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter Quantity",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: restockMachine,
                child: const Text("Restock Machine"),
              ),
            )

          ],
        ),
      ),
    );
  }
}
