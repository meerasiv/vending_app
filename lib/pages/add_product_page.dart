import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerProductPage extends StatefulWidget {
  final int machineId;

  const CustomerProductPage({super.key, required this.machineId});

  @override
  State<CustomerProductPage> createState() => _CustomerProductPageState();
}

class _CustomerProductPageState extends State<CustomerProductPage> {
  final supabase = Supabase.instance.client;
  List products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future loadProducts() async {
    final data = await supabase
        .from('machine_inventory')
        .select('quantity_available,product(*)')
        .eq('machine_id', widget.machineId);

    setState(() {
      products = data;
    });
  }

  Future buyProduct(int productId, double price) async {
    await supabase.from('machine_transaction').insert({
      'machine_id': widget.machineId,
      'product_id': productId,
      'amount_paid': price,
      'payment_method': 'UPI'
    });

    final data = await supabase
        .from('machine_inventory')
        .select()
        .eq('machine_id', widget.machineId)
        .eq('product_id', productId)
        .single();

    int currentQty = data['quantity_available'];

    await supabase
        .from('machine_inventory')
        .update({'quantity_available': currentQty - 1})
        .eq('machine_id', widget.machineId)
        .eq('product_id', productId);

    loadProducts();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Purchase Successful")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Product"),
        centerTitle: true,
      ),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8), // tighter padding
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.8, // flatter and shorter
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final item = products[index];
                  final product = item['product'];
                  final stock = item['quantity_available'];

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10), // reduced padding
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Icon(
                            Icons.local_drink,
                            size: 30,
                            color: Colors.blue,
                          ),
                          Text(
                            product['product_name'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2), // tighter spacing
                          Text(
                            "₹${product['price']}",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Stock: $stock",
                            style: TextStyle(
                              fontSize: 13,
                              color: stock > 0 ? Colors.grey : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: double.infinity,
                            height: 32, // smaller button
                            child: ElevatedButton(
                              onPressed: stock > 0
                                  ? () {
                                      buyProduct(
                                        product['product_id'],
                                        product['price'].toDouble(),
                                      );
                                    }
                                  : null,
                              child: const Text(
                                "Buy",
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
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