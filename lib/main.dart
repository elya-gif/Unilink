import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SkillsTestPage());
  }
}

class SkillsTestPage extends StatelessWidget {
  const SkillsTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final skillsFuture = Supabase.instance.client.from('skills').select();

    return Scaffold(
      appBar: AppBar(title: const Text('Supabase Bağlantı Testi')),
      body: FutureBuilder(
        future: skillsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          final skills = snapshot.data!;
          return ListView.builder(
            itemCount: skills.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(skills[i]['name']),
              subtitle: Text(skills[i]['category'] ?? ''),
            ),
          );
        },
      ),
    );
  }
}