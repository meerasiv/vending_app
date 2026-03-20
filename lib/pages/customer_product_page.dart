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

  // Load products for this machine
  Future loadProducts() async {
    setState(() => isLoading = true);
    try {
      final data = await supabase
          .from('machine_inventory')
          .select('quantity_available, product(*)')
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

  // Purchase a product and update machine_income
  Future buyProduct(int productId, double price) async {
    try {
      // 1️⃣ Insert transaction
      await supabase.from('machine_transaction').insert({
        'machine_id': widget.machineId,
        'product_id': productId,
        'amount_paid': price,
        'payment_method': 'UPI',
        'change_returned': 0, // default
      });

      // 2️⃣ Reduce stock
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

      // 3️⃣ Update machine_income for today
      final todayDate = DateTime.now().toIso8601String().split('T')[0];
      final todayIncome = await supabase
          .from('machine_income')
          .select()
          .eq('machine_id', widget.machineId)
          .eq('income_date', todayDate)
          .maybeSingle();

      if (todayIncome == null) {
        // No entry for today → insert new
        await supabase.from('machine_income').insert({
          'machine_id': widget.machineId,
          'total_sales_amount': price,
          'total_transactions': 1,
          'income_date': todayDate,
          'maintenance_cost': 0, // default 0
          'net_income': price,
        });
      } else {
        // Entry exists → update totals
        double currentSales =
            (todayIncome['total_sales_amount'] ?? 0).toDouble();
        int currentTransactions =
            (todayIncome['total_transactions'] ?? 0).toInt();
        double maintenance =
            (todayIncome['maintenance_cost'] ?? 0).toDouble();
        double newSales = currentSales + price;
        int newTransactions = currentTransactions + 1;
        double netIncome = newSales - maintenance;

        await supabase.from('machine_income').update({
          'total_sales_amount': newSales,
          'total_transactions': newTransactions,
          'net_income': netIncome,
        }).eq('income_id', todayIncome['income_id']);
      }

      // 4️⃣ Reload products
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
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 items per row
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final item = products[index];
                      final product = item['product'];
                      final stock = item['quantity_available'];

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        shadowColor: Colors.grey.withOpacity(0.3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12)),
                                ),
                                child: const Icon(
                                  Icons.local_drink,
                                  size: 50,
                                  color: Colors.blue,
                                ),
                                alignment: Alignment.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      product['product_name'],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "₹${product['price']}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: stock > 0
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 36,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: stock > 0
                                              ? Colors.blue
                                              : Colors.grey.shade400,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        onPressed: stock > 0
                                            ? () {
                                                buyProduct(
                                                    product['product_id'],
                                                    product['price']
                                                        .toDouble());
                                              }
                                            : null,
                                        child: Text(
                                          stock > 0 ? "Buy" : "Out of Stock",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
