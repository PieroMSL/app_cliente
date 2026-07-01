import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/solicitud_model.dart';

/// Repositorio del modulo Solicitud (M5).
class SolicitudRepository {
  final ApiClient _api;
  SolicitudRepository(this._api);

  Future<SolicitudCreada> crear(Map<String, dynamic> datos) async {
    final data = await _api.post('/cliente/solicitudes', datos);
    return SolicitudCreada.fromJson(data as Map<String, dynamic>);
  }

  Future<List<SolicitudResumen>> listar() async {
    final data = await _api.get('/cliente/solicitudes');
    return (data as List)
        .map((e) => SolicitudResumen.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final solicitudRepositoryProvider = Provider<SolicitudRepository>((ref) {
  return SolicitudRepository(ref.watch(apiClientProvider));
});
