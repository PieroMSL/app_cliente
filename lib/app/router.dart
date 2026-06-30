import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/login_viewmodel.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/estado_solicitudes/presentation/estado_screen.dart';
import '../features/solicitud/presentation/borradores_screen.dart';
import '../features/solicitud/presentation/historial_screen.dart';
import '../features/solicitud/presentation/simulador_screen.dart';
import '../features/solicitud/presentation/solicitud_screen.dart';
import '../features/splash/presentation/splash_screen.dart';

/// Navegacion declarativa con rutas nombradas (GoRouter).
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (loc == '/splash') return null; // el splash decide su navegacion
      final autenticado =
          ref.read(loginViewModelProvider).status == AuthStatus.authenticated;
      final enLoginORegister = loc == '/login' || loc == '/register';
      if (!autenticado && !enLoginORegister) return '/login';
      if (autenticado && enLoginORegister) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/estado', builder: (_, __) => const EstadoScreen()),
      GoRoute(
        path: '/solicitud',
        builder: (_, state) =>
            SolicitudScreen(args: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(
        path: '/borradores',
        builder: (_, __) => const BorradoresScreen(),
      ),
      GoRoute(path: '/simulador', builder: (_, __) => const SimuladorScreen()),
      GoRoute(path: '/historial', builder: (_, __) => const HistorialScreen()),
    ],
  );
});
