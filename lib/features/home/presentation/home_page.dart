import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/data/auth_repository.dart';
import '../../profile/data/profile_repository.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch: profil değişince (yüklendi, hata, yenilendi) sayfa yeniden çizilir
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AsyncValue'nun üç hali: veri geldi / yükleniyor / hata
            profileAsync.when(
              data: (profile) => Column(
                children: [
                  Text('Hoş geldin, ${profile?.fullName ?? 'isimsiz kullanıcı'}'),
                  Text('Kullanıcı adı: ${profile?.userName ?? '-'}'),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Profil yüklenemedi: $error'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.push('/onboarding'),
              child: const Text('Profili düzenle'),
            ),
            TextButton(
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              child: const Text('Çıkış yap'),
            ),
          ],
        ),
      ),
    );
  }
}
