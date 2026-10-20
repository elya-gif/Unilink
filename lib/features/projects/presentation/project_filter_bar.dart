import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/data/profile_repository.dart';
import '../data/project_filter.dart';
import '../data/project_repository.dart';

class ProjectFilterBar extends ConsumerWidget {
  const ProjectFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(projectFilterProvider);
    final notifier = ref.read(projectFilterProvider.notifier);
    final competitions = ref.watch(competitionsProvider).value ?? [];
    final skills = ref.watch(skillsProvider).value ?? [];

    // Seçili filtrenin adını bul (yoksa null)
    final competitionName = competitions
        .where((c) => c.id == filter.competitionId)
        .map((c) => c.name)
        .firstOrNull;
    final skillName =
        skills.where((s) => s.id == filter.skillId).map((s) => s.name).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Proje ara',
            prefixIcon: Icon(Icons.search),
          ),
          // Her harfte değil, klavyede "Ara"ya basınca filtrele
          onSubmitted: notifier.setSearch,
        ),
        const SizedBox(height: 8),
        // Yatay kaydırılabilir etiket satırı
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('Ekip arayanlar'),
                selected: filter.onlyRecruiting,
                onSelected: (_) => notifier.toggleOnlyRecruiting(),
              ),
              const SizedBox(width: 8),
              _PickerChip(
                label: competitionName ?? 'Yarışma',
                selected: competitionName != null,
                onTap: () => _pick(
                  context,
                  title: 'Yarışma seç',
                  options: {for (final c in competitions) c.id: c.name},
                  onSelected: notifier.setCompetition,
                ),
              ),
              const SizedBox(width: 8),
              _PickerChip(
                label: skillName ?? 'Yetenek',
                selected: skillName != null,
                onTap: () => _pick(
                  context,
                  title: 'Yetenek seç',
                  options: {for (final s in skills) s.id: s.name},
                  onSelected: notifier.setSkill,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Alttan açılan seçim listesi. "Tümü" seçilirse filtre kalkar (null).
  void _pick(
    BuildContext context, {
    required String title,
    required Map<int, String> options,
    required void Function(int?) onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(title: Text(title, style: Theme.of(context).textTheme.titleMedium)),
            ListTile(
              title: const Text('Tümü'),
              onTap: () {
                onSelected(null);
                Navigator.pop(sheetContext);
              },
            ),
            for (final entry in options.entries)
              ListTile(
                title: Text(entry.value),
                onTap: () {
                  onSelected(entry.key);
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PickerChip extends StatelessWidget {
  const _PickerChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text(label), const Icon(Icons.arrow_drop_down, size: 18)],
      ),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
    );
  }
}
