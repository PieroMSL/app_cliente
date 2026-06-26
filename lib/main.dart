import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/notificaciones/notificacion_service.dart';
import 'features/auth/presentation/login_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await NotificacionService.init();
  } catch (_) {/* notificaciones opcionales */}

  final container = ProviderContainer();
  // Restaura sesion persistente (token + asesor) antes de pintar (RF-03).
  await container.read(loginViewModelProvider.notifier).restaurarSesion();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const App(),
    ),
  );
}
