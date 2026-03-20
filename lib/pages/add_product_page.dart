import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final supabase = Supabase.instance.client;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String? selectedCategory;

  final List<String> categories = [
    'Snacks',
    'Drinks',
    'Chocolates',
    'Biscuits'
  ];

  bool isLoading = false;

  // ================= ADD / UPDATE PRODUCT =================
  Future<void> addProduct() async {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim());

    if (name.isEmpty || price == null || selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields correctly")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🔍 Check if product already exists
      final existing = await supabase
          .from('product')
          .select()
          .eq('product_name', name)
          .maybeSingle();

      if (existing != null) {
        // 🔄 UPDATE existing product
        await supabase
            .from('product')
            .update({
              'category': selectedCategory,
              'price': price,
            })
            .eq('product_name', name);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product updated successfully ✅")),
        );
      } else {
        // ➕ INSERT new product
        await supabase.from('product').insert({
          'product_name': name,
          'category': selectedCategory,
          'price': price,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product added successfully ✅")),
        );
      }

      // 🔄 Clear inputs
      nameController.clear();
      priceController.clear();
      setState(() => selectedCategory = null);

    } catch (e) {
      print("FULL ERROR: $e"); // 🔍 debug in terminal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add / Update Product"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🏷 Product Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Product Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // 📂 Category Dropdown
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedCategory = value);
              },
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // 💰 Price
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // 🚀 Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save Product",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }
}
