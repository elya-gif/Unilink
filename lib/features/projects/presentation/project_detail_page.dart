import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../data/project.dart';
import '../data/project_repository.dart';

class ProjectDetailPage extends ConsumerWidget {
  const ProjectDetailPage({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectProvider(projectId));

    return Scaffold(
      appBar: AppBar(title: const Text('Proje')),
      body: projectAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Proje yüklenemedi: $error')),
        data: (project) => _ProjectDetail(project: project),
      ),
    );
  }
}

class _ProjectDetail extends StatelessWidget {
  const _ProjectDetail({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = AppColors.navy.withValues(alpha: 0.7);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (project.competitionName != null)
                Text(
                  project.competitionName!.toUpperCase(),
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.burgundy,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                project.title,
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    avatar: Icon(
                      project.isRecruiting ? Icons.circle : Icons.circle_outlined,
                      size: 10,
                      color: project.isRecruiting ? AppColors.success : muted,
                    ),
                    label: Text(project.isRecruiting ? 'Ekip arıyor' : 'Ekip tamam'),
                  ),
                  Chip(
                    label: Text(project.openToOtherUniversities
                        ? 'Tüm üniversitelere açık'
                        : 'Sadece kendi üniversitesi'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(project.description, style: textTheme.bodyLarge),
              const SizedBox(height: 24),
              Text('Proje sahibi', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              _OwnerTile(ownerId: project.ownerId),
              const SizedBox(height: 24),
              Text('Aranan roller', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final role in project.roles) _RoleCard(role: role),
            ],
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: project.isRecruiting
                ? () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Başvuru yakında geliyor')),
                    )
                : null,
            child: const Text('Başvur'),
          ),
        ),
      ],
    );
  }
}

class _OwnerTile extends ConsumerWidget {
  const _OwnerTile({required this.ownerId});

  final String ownerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owner = ref.watch(projectOwnerProvider(ownerId)).value;
    final subtitle = [owner?.universityName, owner?.departmentName]
        .whereType<String>() // null olanları at
        .join(' · ');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundImage: owner?.avatarUrl != null ? NetworkImage(owner!.avatarUrl!) : null,
        child: owner?.avatarUrl == null ? const Icon(Icons.person) : null,
      ),
      title: Text(owner?.fullName ?? '...'),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role});

  final ProjectRole role;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.navy.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    role.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${role.slots} kişi',
                  style: const TextStyle(color: AppColors.burgundy, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            if (role.description != null) ...[
              const SizedBox(height: 4),
              Text(role.description!),
            ],
            if (role.skillNames.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final skill in role.skillNames)
                    Chip(label: Text(skill), visualDensity: VisualDensity.compact),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
