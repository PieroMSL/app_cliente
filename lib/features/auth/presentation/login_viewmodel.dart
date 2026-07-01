import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/auth_repository.dart';
import '../domain/cliente_model.dart';

enum AuthStatus { idle, loading, authenticated, error }

/// Estado inmutable de la pantalla de login.
class AuthState {
  final AuthStatus status;
  final ClienteModel? cliente;
  final String? error;
  final int intentosFallidos;
  final DateTime? bloqueadoHasta;

  const AuthState({
    this.status = AuthStatus.idle,
    this.cliente,
    this.error,
    this.intentosFallidos = 0,
    this.bloqueadoHasta,
  });

  bool get estaBloqueado =>
      bloqueadoHasta != null && DateTime.now().isBefore(bloqueadoHasta!);

  Duration get tiempoRestante => bloqueadoHasta == null
      ? Duration.zero
      : bloqueadoHasta!.difference(DateTime.now());

  AuthState copyWith({
    AuthStatus? status,
    ClienteModel? cliente,
    String? error,
    int? intentosFallidos,
    DateTime? bloqueadoHasta,
  }) {
    return AuthState(
      status: status ?? this.status,
      cliente: cliente ?? this.cliente,
      error: error ?? this.error,
      intentosFallidos: intentosFallidos ?? this.intentosFallidos,
      bloqueadoHasta: bloqueadoHasta ?? this.bloqueadoHasta,
    );
  }
}

/// ViewModel de autenticacion (M0).
class LoginViewModel extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  LoginViewModel(this._repo) : super(const AuthState());

  static const int _maxIntentos = 5;
  static const Duration _bloqueo = Duration(seconds: 10);

  /// Restaura sesion vigente al iniciar la app (RF-03).
  Future<void> restaurarSesion() async {
    final cliente = await _repo.sesionActual();
    if (cliente != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        cliente: cliente,
        error: null,
      );
    }
  }

  /// Carga el estado de bloqueo persistido (RF-04). El bloqueo sigue vigente
  /// aunque se haya cerrado y reabierto la app.
  Future<void> cargarEstadoBloqueo() async {
    final (intentos, hasta) = await _repo.leerEstadoBloqueo();
    final ahora = DateTime.now();
    final vigente = hasta != null && ahora.isBefore(hasta);
    var hastaFinal = vigente ? hasta : null;
    // Si el bloqueo guardado supera el maximo actual, se recorta (util al
    // reducir _bloqueo para pruebas: un bloqueo viejo de 30 min se acorta).
    if (hastaFinal != null && hastaFinal.difference(ahora) > _bloqueo) {
      hastaFinal = ahora.add(_bloqueo);
      await _repo.guardarEstadoBloqueo(intentos: intentos, hasta: hastaFinal);
    }
    state = state.copyWith(
      intentosFallidos: vigente ? intentos : 0,
      bloqueadoHasta: hastaFinal,
    );
    if (!vigente && (intentos != 0 || hasta != null)) {
      await _repo.guardarEstadoBloqueo(intentos: 0, hasta: null);
    }
  }

  Future<void> login(String documento, String password) async {
    if (state.estaBloqueado) return;

    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final cliente = await _repo.login(
        documento: documento,
        password: password,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        cliente: cliente,
        error: null,
        intentosFallidos: 0,
        bloqueadoHasta: null,
      );
      await _repo.guardarEstadoBloqueo(intentos: 0, hasta: null);
    } on ApiException catch (e) {
      if (e.statusCode == 423) {
        state = state.copyWith(
          status: AuthStatus.error,
          error: 'La cuenta esta bloqueada. Intenta nuevamente mas tarde.',
        );
        return;
      }
      if (e.statusCode != 401) {
        state = state.copyWith(status: AuthStatus.error, error: e.message);
        return;
      }
      final intentos = state.intentosFallidos + 1;
      final bloquear = intentos >= _maxIntentos;
      final hasta = bloquear
          ? DateTime.now().add(_bloqueo)
          : state.bloqueadoHasta;
      state = state.copyWith(
        status: AuthStatus.error,
        error: bloquear
            ? null
            : 'Credenciales invalidas (intento $intentos de $_maxIntentos)',
        intentosFallidos: intentos,
        bloqueadoHasta: hasta,
      );
      await _repo.guardarEstadoBloqueo(intentos: intentos, hasta: hasta);
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'No se pudo conectar con Banco Andino. Intenta nuevamente.',
      );
    }
  }

  Future<void> register({
    required String documento,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final cliente = await _repo.register(
        documento: documento,
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
        password: password,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        cliente: cliente,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }
}

final loginViewModelProvider = StateNotifierProvider<LoginViewModel, AuthState>(
  (ref) {
    return LoginViewModel(ref.watch(authRepositoryProvider));
  },
);
