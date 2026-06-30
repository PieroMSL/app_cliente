import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/login_viewmodel.dart';
import 'creditos_cliente_screen.dart';

final cuentasClienteProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final data = await ref.watch(apiClientProvider).get('/cliente/cuentas');
      return (data as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    });

final movimientosClienteProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final data = await ref
          .watch(apiClientProvider)
          .get('/cliente/movimientos?limit=10');
      return (data as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    });

final notificacionesClienteProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final data = await ref
          .watch(apiClientProvider)
          .get('/cliente/notificaciones');
      return (data as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    });

final perfilClienteProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  final data = await ref.watch(apiClientProvider).get('/cliente/perfil');
  return Map<String, dynamic>.from(data as Map);
});

class DashboardScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const DashboardScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _currentIndex = widget.initialIndex;
    }
  }

  Future<void> _logout() async {
    await ref.read(loginViewModelProvider.notifier).logout();
    if (mounted) context.go('/login');
  }

  void _mostrarNotificaciones() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _NotificacionesSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cliente = ref.watch(loginViewModelProvider).cliente;
    final bodyWidgets = [
      _InicioView(
        cliente: cliente,
      ),
      const _CuentasView(),
      const CreditosClienteScreen(),
      _PerfilView(onLogout: _logout),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Banca Movil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer(
            builder: (_, ref, __) {
              final cantidad = ref
                  .watch(notificacionesClienteProvider)
                  .maybeWhen(
                    data: (items) =>
                        items.where((n) => n['leida'] != true).length,
                    orElse: () => 0,
                  );
              return Badge(
                isLabelVisible: cantidad > 0,
                label: Text('$cantidad'),
                child: IconButton(
                  tooltip: 'Notificaciones',
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: _mostrarNotificaciones,
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Cerrar sesion',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: bodyWidgets[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Cuentas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Creditos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _InicioView extends ConsumerWidget {
  final dynamic cliente;

  const _InicioView({required this.cliente});

  Future<void> _refrescar(WidgetRef ref) async {
    ref.invalidate(cuentasClienteProvider);
    ref.invalidate(movimientosClienteProvider);
    ref.invalidate(notificacionesClienteProvider);
    await ref.read(cuentasClienteProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nombres = (cliente?.nombres as String? ?? '').trim().split(' ');
    final name = nombres.firstOrNull?.toUpperCase() ?? 'CLIENTE';
    final cuentasAsync = ref.watch(cuentasClienteProvider);
    final movimientosAsync = ref.watch(movimientosClienteProvider);

    final saldo = cuentasAsync.maybeWhen(
      data: (cuentas) => cuentas.fold<double>(
        0,
        (total, cuenta) =>
            total + ((cuenta['saldo_capital'] as num?)?.toDouble() ?? 0),
      ),
      orElse: () => 0,
    );

    return RefreshIndicator(
      onRefresh: () => _refrescar(ref),
      child: ListView(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, $name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Saldo total disponible',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                cuentasAsync.when(
                  loading: () => const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  error: (_, __) => const Text(
                    'No disponible',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  data: (_) => Text(
                    'S/ ${saldo.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Accesos rapidos'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  children: [
                    _QuickAction(
                      icon: Icons.request_page_outlined,
                      label: 'Solicitar\ncredito',
                      onTap: () => context.push('/solicitud'),
                    ),
                    _QuickAction(
                      icon: Icons.calculate_outlined,
                      label: 'Simular\ncredito',
                      onTap: () => context.push('/simulador'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const _SectionTitle('Tus cuentas'),
                const SizedBox(height: 12),
                cuentasAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) =>
                      const _InlineError('No se pudieron cargar tus cuentas.'),
                  data: (cuentas) => cuentas.isEmpty
                      ? const _EmptyState(
                          icon: Icons.savings_outlined,
                          message: 'Aun no tienes cuentas asociadas.',
                        )
                      : Column(
                          children: cuentas
                              .map((cuenta) => _CuentaCard(cuenta: cuenta))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 28),
                const _SectionTitle('Movimientos recientes'),
                const SizedBox(height: 12),
                movimientosAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const _InlineError(
                    'No se pudieron cargar los movimientos.',
                  ),
                  data: (movimientos) => movimientos.isEmpty
                      ? const _EmptyState(
                          icon: Icons.receipt_long_outlined,
                          message: 'No tienes movimientos recientes.',
                        )
                      : Column(
                          children: movimientos
                              .map(
                                (movimiento) =>
                                    _MovimientoTile(movimiento: movimiento),
                              )
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CuentasView extends ConsumerWidget {
  const _CuentasView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cuentas = ref.watch(cuentasClienteProvider);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(cuentasClienteProvider);
        await ref.read(cuentasClienteProvider.future);
      },
      child: cuentas.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ListView(
          children: const [
            SizedBox(height: 160),
            _InlineError('No se pudieron cargar tus cuentas.'),
          ],
        ),
        data: (items) => items.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 160),
                  _EmptyState(
                    icon: Icons.savings_outlined,
                    message: 'Aun no tienes cuentas asociadas.',
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const _SectionTitle('Mis cuentas'),
                  const SizedBox(height: 12),
                  ...items.map((cuenta) => _CuentaCard(cuenta: cuenta)),
                ],
              ),
      ),
    );
  }
}

class _PerfilView extends ConsumerWidget {
  final Future<void> Function() onLogout;

  const _PerfilView({required this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfil = ref.watch(perfilClienteProvider);
    return perfil.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) =>
          const Center(child: _InlineError('No se pudo cargar tu perfil.')),
      data: (data) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            '${data['nombres'] ?? ''} ${data['apellidos'] ?? ''}'.trim(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _DatoPerfil(
            icon: Icons.badge_outlined,
            label: 'Documento',
            value: '${data['numero_documento'] ?? '-'}',
          ),
          _DatoPerfil(
            icon: Icons.phone_outlined,
            label: 'Telefono',
            value: '${data['telefono'] ?? 'No registrado'}',
          ),
          _DatoPerfil(
            icon: Icons.email_outlined,
            label: 'Correo',
            value: '${data['email'] ?? 'No registrado'}',
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesion'),
          ),
        ],
      ),
    );
  }
}

class _NotificacionesSheet extends ConsumerWidget {
  const _NotificacionesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificaciones = ref.watch(notificacionesClienteProvider);
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.65,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Notificaciones',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: notificaciones.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(
                  child: _InlineError(
                    'No se pudieron cargar las notificaciones.',
                  ),
                ),
                data: (items) => items.isEmpty
                    ? const _EmptyState(
                        icon: Icons.notifications_none,
                        message: 'No tienes notificaciones.',
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final item = items[index];
                          return ListTile(
                            leading: Icon(
                              item['leida'] == true
                                  ? Icons.notifications_none
                                  : Icons.notifications_active,
                              color: AppColors.primary,
                            ),
                            title: Text('${item['titulo'] ?? 'Notificacion'}'),
                            subtitle: Text('${item['cuerpo'] ?? ''}'),
                            trailing: Text(
                              _fechaCorta(item['created_at']),
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CuentaCard extends StatelessWidget {
  final Map<String, dynamic> cuenta;

  const _CuentaCard({required this.cuenta});

  @override
  Widget build(BuildContext context) {
    final saldo = (cuenta['saldo_capital'] as num?)?.toDouble() ?? 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.savings_outlined, color: Colors.white),
        ),
        title: Text('${cuenta['tipo_cuenta'] ?? 'Cuenta de ahorro'}'),
        subtitle: Text(
          '${cuenta['cod_cuenta_ahorro'] ?? '-'} · '
          '${cuenta['estado'] ?? 'Sin estado'}',
        ),
        trailing: Text(
          'S/ ${saldo.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _MovimientoTile extends StatelessWidget {
  final Map<String, dynamic> movimiento;

  const _MovimientoTile({required this.movimiento});

  @override
  Widget build(BuildContext context) {
    final tipo = '${movimiento['tipo'] ?? ''}'.toUpperCase();
    final esIngreso = tipo == 'CRE' || tipo == 'ABONO' || tipo == 'INGRESO';
    final monto = (movimiento['monto'] as num?)?.toDouble() ?? 0;
    final color = esIngreso ? AppColors.success : AppColors.danger;
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(
              esIngreso ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
            ),
          ),
          title: Text('${movimiento['concepto'] ?? 'Movimiento'}'),
          subtitle: Text(_fechaCorta(movimiento['fecha_operacion'])),
          trailing: Text(
            '${esIngreso ? '+' : '-'} S/ ${monto.abs().toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatoPerfil extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DatoPerfil({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(icon, size: 38, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.danger),
      ),
    );
  }
}

String _fechaCorta(dynamic value) {
  final date = DateTime.tryParse('$value')?.toLocal();
  if (date == null) return '';
  String dos(int n) => n.toString().padLeft(2, '0');
  return '${dos(date.day)}/${dos(date.month)}/${date.year}';
}
