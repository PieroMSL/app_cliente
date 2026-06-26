import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_clientes/features/auth/data/auth_repository.dart';
import 'package:app_clientes/features/auth/presentation/login_viewmodel.dart';
import 'package:app_clientes/features/dashboard/presentation/dashboard_screen.dart';
import 'package:app_clientes/features/solicitud/data/solicitud_repository.dart';

class MockStorage implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({required String key, required String? value, dynamic iOptions, dynamic aOptions, dynamic lOptions, dynamic webOptions, dynamic mOptions}) async {
    if (value != null) _data[key] = value;
  }

  @override
  Future<String?> read({required String key, dynamic iOptions, dynamic aOptions, dynamic lOptions, dynamic webOptions, dynamic mOptions}) async {
    return _data[key];
  }

  @override
  Future<void> delete({required String key, dynamic iOptions, dynamic aOptions, dynamic lOptions, dynamic webOptions, dynamic mOptions}) async {
    _data.remove(key);
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() async {
  print('Iniciando prueba...');
  final container = ProviderContainer(
    overrides: [
      secureStorageProvider.overrideWithValue(MockStorage() as dynamic),
    ],
  );

  print('=== INICIANDO LOGIN ===');
  await container.read(loginViewModelProvider.notifier).login('73431102', 'admin123');
  
  print('=== PETICION 1: GET /cliente/cuentas ===');
  try {
    await container.read(cuentasClienteProvider.future);
  } catch (e) {
    print('Resultado cuentas: $e');
  }

  print('=== PETICION 2: GET /cliente/solicitudes ===');
  try {
    final repo = container.read(solicitudRepositoryProvider);
    await repo.listar();
  } catch (e) {
    print('Resultado GET solicitudes: $e');
  }

  print('=== PETICION 3: POST /cliente/solicitudes ===');
  try {
    final repo = container.read(solicitudRepositoryProvider);
    await repo.crear({
      "numero_documento": "73431102",
      "nombres": "Test",
      "apellidos": "User",
      "monto_solicitado": 1000,
      "plazo_meses": 12,
      "destino_credito": "Negocio",
    });
  } catch (e) {
    print('Resultado POST solicitudes: $e');
  }
}
