import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:s11_app_flutter_fventas/core/network/api_client.dart';

void main() {
  test('adjunta el JWT como Bearer sin exponer credenciales', () async {
    late http.Request request;
    final client = MockClient((received) async {
      request = received;
      return http.Response(
        jsonEncode({'cuentas': <Object>[]}),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final api = ApiClient(client)..setToken('jwt-de-prueba');

    final response = await api.get('/cliente/cuentas');

    expect(request.url.toString(), '${ApiClient.baseUrl}/cliente/cuentas');
    expect(request.headers['Authorization'], 'Bearer jwt-de-prueba');
    expect(response, {'cuentas': <Object>[]});
  });

  test('traduce el detalle de error de FastAPI a ApiException', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({'detail': 'Credenciales invalidas'}),
        401,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );
    final api = ApiClient(client);

    expect(
      () => api.post('/cliente/login', const {}),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.message, 'message', 'Credenciales invalidas'),
      ),
    );
  });
}
