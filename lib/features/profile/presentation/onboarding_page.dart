import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/auth_repository.dart';
import '../data/lookup_item.dart';
import '../data/profile_repository.dart';
import 'avatar_picker.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _userNameController = TextEditingController();

  int? _universityId;
  int? _departmentId;
  int? _classYear;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Profilde daha önce doldurulmuş alanlar varsa formu onlarla başlat
    final profile = ref.read(currentProfileProvider).value;
    _fullNameController.text = profile?.fullName ?? '';
    _userNameController.text = profile?.userName ?? '';
    _universityId = profile?.universityId;
    _departmentId = profile?.departmentId;
    _classYear = profile?.classYear;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(profileRepositoryProvider).updateProfile(
            userId: user.id,
            fullName: _fullNameController.text.trim(),
            userName: _userNameController.text.trim().toLowerCase(),
            universityId: _universityId!,
            departmentId: _departmentId!,
            classYear: _classYear!,
          );
      // Profili yeniden çek ve bitmesini bekle; yoksa router eski (eksik)
      // profili görüp bizi tekrar onboarding'e gönderir
      ref.invalidate(currentProfileProvider);
      await ref.read(currentProfileProvider.future);
      if (mounted) context.go('/');
    } on PostgrestException catch (e) {
      _showError(_translateError(e));
    } catch (e) {
      _showError('Beklenmeyen bir hata oluştu. Tekrar dene.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _translateError(PostgrestException e) {
    // 23505 = PostgreSQL "unique kuralı ihlali": bu değer başka satırda var
    if (e.code == '23505') {
      return 'Bu kullanıcı adı alınmış, başka bir tane dene.';
    }
    return 'Profil kaydedilemedi: ${e.message}';
  }

  void _showError(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final universitiesAsync = ref.watch(universitiesProvider);
    final departmentsAsync = ref.watch(departmentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profilini tamamla')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AvatarPicker(),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _fullNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Ad soyad',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return 'Adını ve soyadını gir';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _userNameController,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Kullanıcı adı',
                    hintText: 'ornek_kullanici',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final text = value?.trim().toLowerCase() ?? '';
                    if (!RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(text)) {
                      return '3-20 karakter; sadece harf, rakam ve _';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _LookupDropdown(
                  label: 'Üniversite',
                  itemsAsync: universitiesAsync,
                  value: _universityId,
                  onChanged: (id) => setState(() => _universityId = id),
                ),
                const SizedBox(height: 16),
                _LookupDropdown(
                  label: 'Bölüm',
                  itemsAsync: departmentsAsync,
                  value: _departmentId,
                  onChanged: (id) => setState(() => _departmentId = id),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _classYear,
                  decoration: const InputDecoration(
                    labelText: 'Sınıf',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (var year = 1; year <= 6; year++)
                      DropdownMenuItem(value: year, child: Text('$year. sınıf')),
                  ],
                  onChanged: (year) => setState(() => _classYear = year),
                  validator: (value) => value == null ? 'Sınıfını seç' : null,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Kaydet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Üniversite ve bölüm için aynı açılır liste: veri gelene kadar yükleniyor,
// hata olursa mesaj, gelince seçenekler.
class _LookupDropdown extends StatelessWidget {
  const _LookupDropdown({
    required this.label,
    required this.itemsAsync,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final AsyncValue<List<LookupItem>> itemsAsync;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return itemsAsync.when(
      data: (items) => DropdownButtonFormField<int>(
        initialValue: value,
        isExpanded: true, // uzun üniversite adları taşmasın
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: [
          for (final item in items)
            DropdownMenuItem(value: item.id, child: Text(item.name)),
        ],
        onChanged: onChanged,
        validator: (value) => value == null ? '$label seç' : null,
      ),
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => Text('$label listesi yüklenemedi'),
    );
  }
}
