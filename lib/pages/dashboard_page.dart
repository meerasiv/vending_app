import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'add_machine_page.dart';
import 'add_product_page.dart';
import 'inventory_page.dart';
import 'sales_report_page.dart';
import 'login_page.dart';
import 'admin_alert_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<void> logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9), // Light Grey-Blue
      appBar: AppBar(
        title: const Text(
          "MANAGEMENT SYSTEM",
          style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A237E), // Deep Navy
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => logout(context),
            icon: const Icon(Icons.power_settings_new, color: Colors.white, size: 18),
            label: const Text("LOGOUT", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 20),
            
            /// ROW 1
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: actionCard(
                      context,
                      "MACHINES",
                      "Register new unit",
                      const Color(0xFF2196F3), // Blue
                      const AddMachinePage(),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: actionCard(
                      context,
                      "PRODUCTS",
                      "Update catalog",
                     const Color(0xFF2196F3),
                       AddProductPage(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// ROW 2
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: actionCard(
                      context,
                      "INVENTORY",
                      "Stock levels",
                      const Color(0xFF2196F3), // Blue
                      const InventoryPage(),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: actionCard(
                      context,
                      "REPORTS",
                      "Sales analytics",
                     const Color(0xFF2196F3), // Blue
                      const SalesReportPage(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            /// TECHNICAL ALERT BUTTON
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAlertPage())),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.red.shade700, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("⚠️ ", style: TextStyle(fontSize: 20)), // Emoji fallback
                    Text(
                      "DISPATCH TECHNICIAN",
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget actionCard(
    BuildContext context,
    String title,
    String subtitle,
    Color accentColor,
    Widget page,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
          child: Stack(
            children: [
              // Colored Accent Bar on the side
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 6,
                child: Container(color: accentColor),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Visual "Go" Indicator (Simple container)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "OPEN →",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
