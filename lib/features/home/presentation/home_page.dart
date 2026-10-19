import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../projects/data/project_repository.dart';
import '../../projects/presentation/project_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;
    final projectsAsync = ref.watch(projectsProvider);
    final firstName = profile?.fullName?.split(' ').first ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unilink'),
        actions: [
          // Profil fotoğrafına dokununca açılan menü
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.push('/onboarding');
                case 'skills':
                  context.push('/skills');
                case 'logout':
                  ref.read(authRepositoryProvider).signOut();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'profile', child: Text('Profili düzenle')),
              PopupMenuItem(value: 'skills', child: Text('Yeteneklerim')),
              PopupMenuItem(value: 'logout', child: Text('Çıkış yap')),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: profile?.avatarUrl != null
                    ? NetworkImage(profile!.avatarUrl!)
                    : null,
                child: profile?.avatarUrl == null
                    ? const Icon(Icons.person, size: 20)
                    : null,
              ),
            ),
          ),
        ],
      ),
      // Aşağı çekince listeyi yenile
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(projectsProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Merhaba $firstName 👋',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ekip arayan projeler',
              style: TextStyle(color: AppColors.navy.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            ...projectsAsync.when(
              data: (projects) => projects.isEmpty
                  ? [const _EmptyState()]
                  : [
                      for (final project in projects) ...[
                        ProjectCard(project: project),
                        const SizedBox(height: 12),
                      ],
                    ],
              loading: () => [
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (error, stack) => [
                Text('Projeler yüklenemedi: $error'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.groups_outlined, size: 64, color: AppColors.burgundy.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          const Text('Henüz proje ilanı yok'),
          const SizedBox(height: 4),
          Text(
            'İlk ekibi sen kur!',
            style: TextStyle(color: AppColors.navy.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}
