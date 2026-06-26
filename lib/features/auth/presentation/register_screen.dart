import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import 'login_viewmodel.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dniCtrl = TextEditingController();
  final _nombresCtrl = TextEditingController();
  final _celularCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _verPassword = false;

  @override
  void dispose() {
    _dniCtrl.dispose();
    _nombresCtrl.dispose();
    _celularCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Extraer nombres y apellidos (simplificado)
    final partes = _nombresCtrl.text.trim().split(' ');
    final nombres = partes.isNotEmpty ? partes[0] : '';
    final apellidos = partes.length > 1 ? partes.sublist(1).join(' ') : '';

    await ref.read(loginViewModelProvider.notifier).register(
      documento: _dniCtrl.text.trim(),
      nombres: nombres,
      apellidos: apellidos,
      telefono: _celularCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    final state = ref.read(loginViewModelProvider);
    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error!)),
      );
    } else {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Crear cuenta nueva'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Completa tus datos para acceder a tu Banca Móvil',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _dniCtrl,
                keyboardType: TextInputType.number,
                maxLength: 8,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Número de documento (DNI)',
                  prefixIcon: Icon(Icons.badge_outlined),
                  counterText: '',
                ),
                validator: (val) =>
                    val != null && val.length == 8 ? null : 'Documento inválido (8 dígitos)',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombresCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombres y Apellidos completos',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (val) =>
                    val != null && val.isNotEmpty ? null : 'Ingresa tus nombres',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _celularCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 9,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Número de celular',
                  prefixIcon: Icon(Icons.phone_android),
                  counterText: '',
                ),
                validator: (val) {
                  if (val == null || val.length != 9) return 'Celular inválido (9 dígitos)';
                  if (!val.startsWith('9')) return 'Debe empezar con 9';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: !_verPassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _verPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _verPassword = !_verPassword),
                  ),
                ),
                validator: (val) =>
                    val != null && val.length >= 5 ? null : 'Mínimo 5 caracteres',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPassCtrl,
                obscureText: !_verPassword,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (val) {
                  if (val != _passCtrl.text) return 'Las contraseñas no coinciden';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ref.watch(loginViewModelProvider).status == AuthStatus.loading 
                  ? const Center(child: CircularProgressIndicator()) 
                  : FilledButton(
                      onPressed: _registrar,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('REGISTRARME'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
