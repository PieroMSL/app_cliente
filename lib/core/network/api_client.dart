import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Cliente HTTP del backend FastAPI mobile.
///
/// Para produccion compilar con:
///   --dart-define=API_BASE_URL=https://tu-backend.onrender.com
///
/// Mantiene el token JWT en memoria y lo adjunta como Bearer en cada request.
class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8003',
  );

  final http.Client _http;
  String? _token;

  ApiClient([http.Client? client]) : _http = client ?? http.Client();

  void setToken(String? token) => _token = token;
  void clearToken() => _token = null;
  bool get hasToken => _token != null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<dynamic> get(String path) async {
    final res = await _http
        .get(_uri(path), headers: _headers)
        .timeout(const Duration(seconds: 15));
    return _procesar(res);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await _http
        .post(_uri(path), headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _procesar(res);
  }

  dynamic _procesar(http.Response res) {
    final ok = res.statusCode >= 200 && res.statusCode < 300;
    final cuerpo = res.body.isEmpty ? null : jsonDecode(utf8.decode(res.bodyBytes));
    if (ok) return cuerpo;
    final detalle = (cuerpo is Map && cuerpo['detail'] != null)
        ? cuerpo['detail'].toString()
        : 'Error ${res.statusCode}';
    throw ApiException(res.statusCode, detalle);
  }
}

/// Error de API con codigo HTTP y mensaje del backend (campo `detail`).
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}

/// Singleton de Riverpod para inyectar el cliente en repositorios.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
