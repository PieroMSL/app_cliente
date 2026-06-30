// ignore_for_file: avoid_print

import 'core/network/api_client.dart';
import 'features/auth/data/auth_remote_datasource.dart';

Future<void> main() async {
  const documento = String.fromEnvironment('TEST_CLIENTE_DOCUMENTO');
  const password = String.fromEnvironment('TEST_CLIENTE_PASSWORD');

  if (documento.isEmpty || password.isEmpty) {
    throw StateError(
      'Define TEST_CLIENTE_DOCUMENTO y TEST_CLIENTE_PASSWORD para ejecutar '
      'el diagnostico.',
    );
  }

  print('=== INICIANDO SCRIPT DART PURO ===');
  final api = ApiClient();
  final remote = AuthRemoteDataSource(api);

  print('--- EJECUTANDO LOGIN ---');
  try {
    await remote.login(documento: documento, password: password);
    print('Login exitoso.');
  } catch (e) {
    print('Login fallido: $e');
    return;
  }

  print('--- EJECUTANDO GET CUENTAS ---');
  try {
    final cuentas = await api.get('/cliente/cuentas');
    print('Cuentas obtenidas: $cuentas');
  } catch (e) {
    print('Consulta de cuentas fallida: $e');
  }

  print('--- EJECUTANDO GET SOLICITUDES ---');
  try {
    final solicitudes = await api.get('/cliente/solicitudes');
    print('Solicitudes obtenidas: $solicitudes');
  } catch (e) {
    print('Consulta de solicitudes fallida: $e');
  }
}
