import '../../../core/network/api_client.dart';
import '../domain/cliente_model.dart';

/// Resultado del login: token + cliente.
class LoginResult {
  final String token;
  final ClienteModel cliente;
  const LoginResult(this.token, this.cliente);
}

/// Fuente remota de autenticacion contra el backend FastAPI (POST /auth/login).
class AuthRemoteDataSource {
  final ApiClient _api;
  AuthRemoteDataSource(this._api);

  Future<LoginResult> login({
    required String documento,
    required String password,
  }) async {
    final data = await _api.post('/cliente/login', {
      'numero_documento': documento,
      'password': password,
    });
    final token = data['access_token'] as String;
    final cliente = ClienteModel.fromJson(data['cliente'] as Map<String, dynamic>);
    _api.setToken(token);
    return LoginResult(token, cliente);
  }

  Future<LoginResult> register({
    required String documento,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String password,
  }) async {
    final data = await _api.post('/cliente/register', {
      'numero_documento': documento,
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'password': password,
    });
    final token = data['access_token'] as String;
    final cliente = ClienteModel.fromJson(data['cliente'] as Map<String, dynamic>);
    _api.setToken(token);
    return LoginResult(token, cliente);
  }
}
