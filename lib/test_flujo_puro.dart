import 'dart:convert';
import 'package:http/http.dart' as http;
import 'core/network/api_client.dart';
import 'features/auth/data/auth_remote_datasource.dart';

void main() async {
  print('=== INICIANDO SCRIPT DART PURO ===');
  final api = ApiClient();
  final remote = AuthRemoteDataSource(api);

  print('--- EJECUTANDO LOGIN ---');
  try {
    final res = await remote.login(documento: '73431102', password: 'admin');
    print('Login Exitoso. Token: \...');
  } catch (e) {
    print('Login Fallido: \');
  }

  print('--- EJECUTANDO GET CUENTAS ---');
  try {
    final cuentas = await api.get('/cliente/cuentas');
    print('Cuentas obtenidas: \');
  } catch (e) {
    print('Cuentas fallo: \');
  }

  print('--- EJECUTANDO GET SOLICITUDES ---');
  try {
    final solicitudes = await api.get('/cliente/solicitudes');
    print('Solicitudes obtenidas: \');
  } catch (e) {
    print('Solicitudes fallo: \');
  }

  print('--- EJECUTANDO POST SOLICITUDES ---');
  try {
    final res = await api.post('/cliente/solicitudes', {
      "numero_documento": "73431102",
      "monto_solicitado": 1000,
      "plazo_meses": 12
    });
    print('Solicitud creada: \');
  } catch (e) {
    print('Solicitud fallo: \');
  }
}
