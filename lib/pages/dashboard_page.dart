import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final supabase = Supabase.instance.client;

  // ---------- Add Product ----------
  final productNameController = TextEditingController();
  final productPriceController = TextEditingController();
  final List<String> productCategories = [
    'Beverages',
    'Snacks',
    'Dairy',
    'Bakery',
    'Personal Care',
    'Stationery',
    'Others'
  ];
  String selectedCategory = 'Beverages';
  bool isAddingProduct = false;

  Future<void> addProduct() async {
    if (productNameController.text.isEmpty || productPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all fields ❗")));
      return;
    }

    setState(() => isAddingProduct = true);

    try {
      await supabase.from('PRODUCT').insert({
        'product_name': productNameController.text.trim(),
        'category': selectedCategory,
        'price': double.parse(productPriceController.text.trim()),
        'supplier_id': 1, // static for now
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Product Added ✅")));

      productNameController.clear();
      productPriceController.clear();
      setState(() => selectedCategory = productCategories[0]);
      loadInventory();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isAddingProduct = false);
    }
  }

  // ---------- Add Machine ----------
  final machineLocationController = TextEditingController();
  bool isAddingMachine = false;

  Future<void> addMachine() async {
    if (machineLocationController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter location ❗")));
      return;
    }

    setState(() => isAddingMachine = true);

    try {
      await supabase.from('VENDING_MACHINE').insert({
        'location': machineLocationController.text.trim(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Machine Added ✅")));
      machineLocationController.clear();
      loadInventory();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isAddingMachine = false);
    }
  }

  // ---------- Inventory ----------
  List inventoryItems = [];
  bool isLoadingInventory = false;

  Future<void> loadInventory() async {
    setState(() => isLoadingInventory = true);

    try {
      final data = await supabase.from('machine_inventory').select(
          'machine_id,quantity_available,product(product_id,product_name,price)');
      setState(() => inventoryItems = data);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoadingInventory = false);
    }
  }

  // ---------- Sales Report ----------
  List salesItems = [];
  bool isLoadingSales = false;

  Future<void> loadSalesReport() async {
    setState(() => isLoadingSales = true);

    try {
      final data = await supabase.from('machine_transaction').select(
          'transaction_id,machine_id,product_id,amount_paid,payment_method,created_at');
      setState(() => salesItems = data);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoadingSales = false);
    }
  }

  @override
  void initState() {
    super.initState();
    loadInventory();
    loadSalesReport();
  }

  InputDecoration fieldStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Dashboard"),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Add Product"),
              Tab(text: "Add Machine"),
              Tab(text: "Inventory"),
              Tab(text: "Sales"),
            ],
          ),
        ),
        body: TabBarView(
          children: [

            // ---------- Add Product Tab ----------
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: productNameController,
                    decoration: fieldStyle("Product Name", Icons.drive_file_rename_outline),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: fieldStyle("Category", Icons.category),
                    items: productCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedCategory = val!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: productPriceController,
                    keyboardType: TextInputType.number,
                    decoration: fieldStyle("Price (₹)", Icons.attach_money),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isAddingProduct ? null : addProduct,
                    child: isAddingProduct
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Add Product"),
                  ),
                ],
              ),
            ),

            // ---------- Add Machine Tab ----------
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: machineLocationController,
                    decoration: fieldStyle("Machine Location", Icons.location_on),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isAddingMachine ? null : addMachine,
                    child: isAddingMachine
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Add Machine"),
                  ),
                ],
              ),
            ),

            // ---------- Inventory Tab ----------
            isLoadingInventory
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: inventoryItems.length,
                    itemBuilder: (context, index) {
                      final item = inventoryItems[index];
                      final product = item['product'];
                      return Card(
                        child: ListTile(
                          title: Text(product['product_name']),
                          subtitle: Text(
                              "Machine: ${item['machine_id']} | Stock: ${item['quantity_available']} | Price: ₹${product['price']}"),
                        ),
                      );
                    },
                  ),

            // ---------- Sales Tab ----------
            isLoadingSales
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: salesItems.length,
                    itemBuilder: (context, index) {
                      final sale = salesItems[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                              "Machine: ${sale['machine_id']} | Product: ${sale['product_id']}"),
                          subtitle: Text(
                              "Paid: ₹${sale['amount_paid']} | Method: ${sale['payment_method']} | ${sale['created_at']}"),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}