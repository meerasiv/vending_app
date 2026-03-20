import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {

  final supabase = Supabase.instance.client;

  List transactions = [];
  Map<int, List> groupedSales = {};
  double totalSales = 0;

  Future<void> loadSales() async {

    final data = await supabase
        .from('machine_transaction')
        .select()
        .order('machine_id'); // ✅ SORTED

    Map<int, List> tempGroup = {};
    double tempTotal = 0;

    for (var sale in data) {

      int machineId = sale['machine_id'];
      double amount = (sale['amount_paid'] ?? 0).toDouble();

      tempTotal += amount;

      if (!tempGroup.containsKey(machineId)) {
        tempGroup[machineId] = [];
      }

      tempGroup[machineId]!.add(sale);
    }

    setState(() {
      transactions = data;
      groupedSales = tempGroup;
      totalSales = tempTotal;
    });
  }

  @override
  void initState() {
    super.initState();
    loadSales();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Sales Report"),
        centerTitle: true,
      ),

      body: transactions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),

              child: Column(
                children: [

                  /// 🔥 TOTAL SALES CARD
                  Card(
                    color: Colors.green.shade50,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          const Text(
                            "Total Sales",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            "₹${totalSales.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// 🔥 MACHINE-WISE LIST
                  Expanded(
                    child: ListView(
                      children: groupedSales.entries.map((entry) {

                        int machineId = entry.key;
                        List sales = entry.value;

                        double machineTotal = sales.fold(
                          0,
                          (sum, item) => sum + (item['amount_paid'] ?? 0),
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// MACHINE HEADER
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                "Machine $machineId  (₹${machineTotal.toStringAsFixed(2)})",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            /// TRANSACTIONS
                            ...sales.map((sale) {
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 10),

                                child: ListTile(
                                  leading: const Icon(Icons.receipt_long, color: Colors.blue),
                                  title: Text("Product ID: ${sale['product_id']}"),
                                  trailing: Text(
                                    "₹${sale['amount_paid']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),

                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
