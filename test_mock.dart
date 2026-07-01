// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl =
      'https://mobile-backend-core-andino-fastapi-vp9g.onrender.com';
  final http.Client _http;
  String? _token;

  ApiClient([http.Client? client]) : _http = client ?? http.Client();

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<dynamic> get(String path) async {
    print('--- ENVIANDO PETICION FLUTTER: GET $path ---');
    print('Token almacenado en ApiClient: $_token');
    print('Headers que se van a enviar: $_headers');
    final res = await _http.get(_uri(path), headers: _headers);
    return jsonDecode(res.body);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    print('--- ENVIANDO PETICION FLUTTER: POST $path ---');
    print('Token almacenado en ApiClient: $_token');
    print('Headers que se van a enviar: $_headers');
    final res = await _http.post(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }
}

void main() async {
  final api = ApiClient();

  print('\n=== PETICION LOGIN ===');
  api.setToken("ey_FALSO_TOKEN_JWT_12345");
  print('-> setToken ejecutado con exito.');

  print('\n=== PETICION 1: GET /cliente/cuentas ===');
  await api.get('/cliente/cuentas');

  print('\n=== PETICION 2: GET /cliente/solicitudes ===');
  await api.get('/cliente/solicitudes');

  print('\n=== PETICION 3: POST /cliente/solicitudes ===');
  await api.post('/cliente/solicitudes', {
    "numero_documento": "73431102",
    "monto_solicitado": 1000,
    "plazo_meses": 12,
    "destino_credito": "Negocio",
  });
}
