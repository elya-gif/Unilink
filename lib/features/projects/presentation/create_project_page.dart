import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/data/skill.dart';
import '../data/project_repository.dart';

// Formdaki bir rol kutusunun durumu
class _RoleDraft {
  final titleController = TextEditingController();
  int slots = 1;
  final Set<int> skillIds = {};
}

class CreateProjectPage extends ConsumerStatefulWidget {
  const CreateProjectPage({super.key});

  @override
  ConsumerState<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends ConsumerState<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _competitionId;
  bool _openToOtherUniversities = true;
  final List<_RoleDraft> _roles = [_RoleDraft()]; // en az bir rolle başla

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final role in _roles) {
      role.titleController.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final projectId = await ref.read(projectRepositoryProvider).createProject(
            ownerId: user.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            competitionId: _competitionId,
            openToOtherUniversities: _openToOtherUniversities,
            roles: [
              for (final role in _roles)
                NewRole(
                  title: role.titleController.text.trim(),
                  slots: role.slots,
                  skillIds: role.skillIds,
                ),
            ],
          );
      ref.invalidate(projectsProvider); // ana sayfadaki liste yenilensin
      // Formu geçmişten çıkarıp yerine yeni projenin detayını aç
      if (mounted) context.pushReplacement('/projects/$projectId');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İlan kaydedilemedi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final competitionsAsync = ref.watch(competitionsProvider);
    final skills = ref.watch(skillsProvider).value ?? [];
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni ilan')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Proje adı'),
                validator: (value) => (value == null || value.trim().length < 3)
                    ? 'Proje adını gir'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  hintText: 'Ne yapıyorsunuz, nasıl birini arıyorsunuz?',
                  alignLabelWithHint: true,
                ),
                validator: (value) => (value == null || value.trim().length < 20)
                    ? 'En az 20 karakterlik bir açıklama yaz'
                    : null,
              ),
              const SizedBox(height: 16),
              competitionsAsync.when(
                data: (competitions) => DropdownButtonFormField<int?>(
                  initialValue: _competitionId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Yarışma (isteğe bağlı)'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Yarışma yok')),
                    for (final competition in competitions)
                      DropdownMenuItem(value: competition.id, child: Text(competition.name)),
                  ],
                  onChanged: (id) => setState(() => _competitionId = id),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) => const Text('Yarışmalar yüklenemedi'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Diğer üniversitelere açık'),
                value: _openToOtherUniversities,
                onChanged: (value) => setState(() => _openToOtherUniversities = value),
              ),
              const SizedBox(height: 8),
              Text('Aranan roller', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final (index, role) in _roles.indexed)
                _RoleEditor(
                  role: role,
                  skills: skills,
                  // Tek rol kaldıysa silinemesin
                  onRemove: _roles.length == 1
                      ? null
                      : () => setState(() {
                            _roles.removeAt(index).titleController.dispose();
                          }),
                  onChanged: () => setState(() {}),
                ),
              TextButton.icon(
                onPressed: () => setState(() => _roles.add(_RoleDraft())),
                icon: const Icon(Icons.add),
                label: const Text('Rol ekle'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('İlanı yayınla'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleEditor extends StatelessWidget {
  const _RoleEditor({
    required this.role,
    required this.skills,
    required this.onRemove,
    required this.onChanged,
  });

  final _RoleDraft role;
  final List<Skill> skills;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
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
                  child: TextFormField(
                    controller: role.titleController,
                    decoration: const InputDecoration(
                      labelText: 'Rol',
                      hintText: 'örn. Flutter geliştirici',
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Rol adını gir' : null,
                  ),
                ),
                if (onRemove != null)
                  IconButton(onPressed: onRemove, icon: const Icon(Icons.delete_outline)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Kaç kişi?'),
                const Spacer(),
                IconButton(
                  onPressed: role.slots > 1
                      ? () {
                          role.slots--;
                          onChanged();
                        }
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('${role.slots}', style: const TextStyle(fontWeight: FontWeight.w700)),
                IconButton(
                  onPressed: role.slots < 10
                      ? () {
                          role.slots++;
                          onChanged();
                        }
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const Text('Gereken yetenekler'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final skill in skills)
                  FilterChip(
                    label: Text(skill.name),
                    visualDensity: VisualDensity.compact,
                    selected: role.skillIds.contains(skill.id),
                    onSelected: (isOn) {
                      isOn ? role.skillIds.add(skill.id) : role.skillIds.remove(skill.id);
                      onChanged();
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
