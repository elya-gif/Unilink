import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
      body: Center(
        child: TextButton(
          onPressed: () => context.go('/login'),
          child: const Text('Çıkış yap (geçici)'),
        ),
      ),
    );
  }
}