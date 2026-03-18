import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dlttuhhrauoefuhvpsax.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRsdHR1aGhyYXVvZWZ1aHZwc2F4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIzMzE3NjgsImV4cCI6MjA4NzkwNzc2OH0.jl_US-juotBW4meOLY4MtpsaxfjAYzkkDgys0OxfXWM',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
     home: LoginPage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(title: const Text("Vending Machines")),
      body: FutureBuilder(
        future: supabase.from('vending_machine').select(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading data"));
          }

          final machines = snapshot.data as List;

          if (machines.isEmpty) {
            return const Center(child: Text("No machines found"));
          }

          return ListView.builder(
            itemCount: machines.length,
            itemBuilder: (context, index) {
              final machine = machines[index];

              return ListTile(
                title: Text(machine['location'] ?? ''),
                subtitle: Text(machine['status'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}