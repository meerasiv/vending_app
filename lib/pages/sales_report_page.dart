import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {

  List transactions = [];
  final supabase = Supabase.instance.client;

  Future<void> loadSales() async {

    final data = await supabase
        .from('machine_transaction')
        .select();

    setState(() {
      transactions = data;
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

              child: ListView.builder(

                itemCount: transactions.length,

                itemBuilder: (context, index) {

                  final sale = transactions[index];

                  return Card(

                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Padding(

                      padding: const EdgeInsets.all(14),

                      child: Row(

                        children: [

                          /// Icon section
                          Container(

                            padding: const EdgeInsets.all(10),

                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),

                            child: const Icon(
                              Icons.receipt_long,
                              color: Colors.blue,
                            ),
                          ),

                          const SizedBox(width: 15),

                          /// Sale info
                          Expanded(
                            child: Column(

                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [

                                Text(
                                  "Machine ${sale['machine_id']}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  "Product ID: ${sale['product_id']}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),

                              ],
                            ),
                          ),

                          /// Price section
                          Text(
                            "₹${sale['amount_paid']}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
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