import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dashboard_page.dart';
import 'distributor_dashboard.dart';
import 'customer_machine_page.dart';
import 'technician_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final supabase = Supabase.instance.client;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  String selectedRole = 'customer'; // default customer
  bool isLogin = true;
  bool isLoading = false;

  // ================= SIGN UP =================
  Future<void> signUp() async {
    setState(() => isLoading = true);

    try {
      await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'role': selectedRole, // always 'customer'
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );

      setState(() => isLogin = true); // switch to login automatically
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  // ================= SIGN IN =================
  Future<void> signIn() async {
    setState(() => isLoading = true);

    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = response.user;
      if (user == null) throw Exception("Login failed");

      // Step 1: check technician table first
      final tech = await supabase
          .from('technician')
          .select()
          .eq('email', user.email!)
          .maybeSingle();

      if (tech != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TechnicianPage()),
        );
        return;
      }

      // Step 2: fallback to metadata role
      final role = user.userMetadata?['role'] ?? 'customer';

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else if (role == 'distributor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DistributorDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomerMachinePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  // ================= UI STYLE =================
  InputDecoration fieldStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue),
      filled: true,
      fillColor: Colors.blue[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff2196F3), Color(0xff64B5F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // --- App Icon Logo ---
                      Icon(
                        Icons.storefront,
                        size: 70,
                        color: Colors.blue,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        isLogin ? "Welcome Back" : "Create Account",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (!isLogin)
                        TextField(
                          controller: nameController,
                          decoration: fieldStyle("Name", Icons.person),
                        ),

                      if (!isLogin) const SizedBox(height: 10),

                      if (!isLogin)
                        TextField(
                          controller: phoneController,
                          decoration: fieldStyle("Phone", Icons.phone),
                        ),

                      if (!isLogin) const SizedBox(height: 10),

                      TextField(
                        controller: emailController,
                        decoration: fieldStyle("Email", Icons.email),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: fieldStyle("Password", Icons.lock),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (isLogin) {
                                    signIn();
                                  } else {
                                    signUp();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  isLogin ? "Login" : "Create Account",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLogin = !isLogin;
                          });
                        },
                        child: Text(
                          isLogin
                              ? "Don't have an account? Sign Up"
                              : "Already have an account? Login",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}