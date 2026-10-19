import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordAgainController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordAgainController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authRepositoryProvider).signUp(
            email: _emailController.text.trim().toLowerCase(),
            password: _passwordController.text,
          );
    } on AuthException catch (e) {
      _showError(_translateError(e.message));
    } catch (e) {
      _showError('Beklenmeyen bir hata oluştu. Tekrar dene.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _translateError(String message) {
    if (message.contains('Database error saving new user')) {
      return 'Sadece .edu.tr uzantılı üniversite mailiyle kayıt olunabilir.';
    }
    if (message.contains('already registered')) {
      return 'Bu mail adresiyle zaten bir hesap var.';
    }
    if (message.contains('Password should be')) {
      return 'Şifre çok zayıf, daha uzun bir şifre seç.';
    }
    return 'Kayıt olunamadı: $message';
  }

  void _showError(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Üniversite maili',
                    hintText: 'ad.soyad@ogr.universite.edu.tr',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Mail adresini gir';
                    }
                    if (!value.contains('@')) {
                      return 'Geçerli bir mail adresi gir';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // şifreyi noktalarla gizle
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return 'Şifre en az 8 karakter olmalı';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordAgainController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Şifre (tekrar)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Şifreler eşleşmiyor';
                    }
                    return null;
                  },
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
                      : const Text('Kayıt ol'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Zaten hesabın var mı? Giriş yap'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}