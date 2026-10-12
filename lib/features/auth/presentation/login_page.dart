import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Unilink', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            FilledButton(
              // context.go: verilen adrese gider
              onPressed: () => context.go('/'),
              child: const Text('Giriş yap (geçici)'),
            ),
          ],
        ),
      ),
    );
  }
}