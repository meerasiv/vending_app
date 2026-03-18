import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'inventory_page.dart';
import 'restock_machine_page.dart';
import 'login_page.dart';

class DistributorDashboard extends StatelessWidget {
  const DistributorDashboard({super.key});

  Future<void> logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Distributor Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            /// Welcome banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),

              child: const Text(
                "Welcome Distributor 👋",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// Dashboard cards
            Expanded(
              child: Column(

                children: [

                  Row(
                    children: [

                      Expanded(
                        child: dashboardCard(
                          context,
                          "View Inventory",
                          Icons.inventory_2,
                          Colors.blue,
                          const InventoryPage(),
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: dashboardCard(
                          context,
                          "Restock Machine",
                          Icons.local_shipping,
                          Colors.green,
                          const RestockMachinePage(),
                        ),
                      ),

                    ],
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget dashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget page,
  ) {

    return InkWell(

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },

      borderRadius: BorderRadius.circular(20),

      child: Card(

        elevation: 4,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),

        child: Container(

          height: 150,

          padding: const EdgeInsets.all(20),

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Icon(
                icon,
                size: 50,
                color: color,
              ),

              const SizedBox(height: 12),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}