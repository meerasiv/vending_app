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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future loadProducts() async {
    setState(() => isLoading = true);
    try {
      final data = await supabase
          .from('machine_inventory')
          .select('quantity_available,product(*)')
          .eq('machine_id', widget.machineId);

      setState(() {
        products = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future buyProduct(int productId, double price) async {
    try {
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
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Product"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text("No products available"))
              : Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,       // 3 items per row, like machines
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      childAspectRatio: 1.8,  // wide & flat cards
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final item = products[index];
                      final product = item['product'];
                      final stock = item['quantity_available'];

                      return SizedBox(
                        // fixed height box
                        height: 120,
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.local_drink,
                                  size: 24,
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product['product_name'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "₹${product['price']}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: stock > 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                SizedBox(
                                  width: double.infinity,
                                  height: 28,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6)),
                                    ),
                                    onPressed: stock > 0
                                        ? () {
                                            buyProduct(
                                                product['product_id'],
                                                product['price'].toDouble());
                                          }
                                        : null,
                                    child: Text(
                                      stock > 0 ? "Buy" : "Out of Stock",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
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