import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/data/auth_repository.dart';
import '../data/profile_repository.dart';
import '../data/skill.dart';

class SkillsPage extends ConsumerStatefulWidget {
  const SkillsPage({super.key});

  @override
  ConsumerState<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends ConsumerState<SkillsPage> {
  // null = kullanıcı henüz dokunmadı, kayıtlı seçimleri göster
  Set<int>? _selected;
  bool _isLoading = false;

  Future<void> _save(Set<int> selected) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(profileRepositoryProvider).saveSkills(user.id, selected);
      ref.invalidate(mySkillIdsProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yetenekler kaydedilemedi. Tekrar dene.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skillsAsync = ref.watch(skillsProvider);
    final mySkillIdsAsync = ref.watch(mySkillIdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Yeteneklerim')),
      body: SafeArea(
        child: skillsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              const Center(child: Text('Yetenekler yüklenemedi')),
          data: (skills) {
            final selected = _selected ?? mySkillIdsAsync.value ?? {};
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                for (final entry in _groupByCategory(skills).entries) ...[
                  Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final skill in entry.value)
                        FilterChip(
                          label: Text(skill.name),
                          selected: selected.contains(skill.id),
                          onSelected: (isOn) => setState(() {
                            _selected = {...selected};
                            isOn
                                ? _selected!.add(skill.id)
                                : _selected!.remove(skill.id);
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                FilledButton(
                  onPressed: _isLoading ? null : () => _save(selected),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Kaydet'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // {'Yazılım': [Flutter, Python], 'Tasarım': [...]} şeklinde gruplar
  Map<String, List<Skill>> _groupByCategory(List<Skill> skills) {
    final groups = <String, List<Skill>>{};
    for (final skill in skills) {
      groups.putIfAbsent(skill.category, () => []).add(skill);
    }
    return groups;
  }
}
