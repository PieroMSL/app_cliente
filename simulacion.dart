import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/core/network/api_client.dart';
import 'lib/features/auth/data/auth_remote_datasource.dart';

void main() async {
  final api = ApiClient();
  final auth = AuthRemoteDataSource(api);

  print('=== 1. LOGIN ===');
  try {
    final result = await auth.login(documento: '73431102', password: 'admin');
    print('Login OK, Token: ${result.token.substring(0, 20)}...');
  } catch (e) {
    print('Login falló: $e');
    return;
  }

  print('\n=== 2. CUENTAS ===');
  try {
    final cuentas = await api.get('/cliente/cuentas');
    print('Cuentas OK: $cuentas');
  } catch (e) {
    print('Cuentas falló: $e');
  }

  print('\n=== 3. SOLICITUDES ===');
  try {
    final sol = await api.get('/cliente/solicitudes');
    print('Solicitudes OK: $sol');
  } catch (e) {
    print('Solicitudes falló: $e');
  }
}
