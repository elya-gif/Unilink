import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hoş geldin, ${user?.email ?? ''}'),
            const SizedBox(height: 16),
            TextButton(
              // Çıkış yapınca router bizi otomatik login'e götürür
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              child: const Text('Çıkış yap'),
            ),
          ],
        ),
      ),
    );
  }
}