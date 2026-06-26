import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/login_viewmodel.dart';
import 'creditos_cliente_screen.dart';

final cuentasClienteProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return await api.get('/cliente/cuentas') as List<dynamic>;
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cliente = ref.watch(loginViewModelProvider).cliente;

    final bodyWidgets = [
      _InicioView(cliente: cliente),
      const Center(child: Text("Ahorros (Próximamente)")),
      const CreditosClienteScreen(),
      const Center(child: Text("Perfil (Próximamente)")),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Banca Móvil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              ref.read(loginViewModelProvider.notifier).logout();
              context.go('/login');
            },
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
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Ahorros'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'Créditos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _InicioView extends ConsumerWidget {
  final dynamic cliente;
  const _InicioView({required this.cliente});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = cliente?.nombres.split(' ').first.toUpperCase() ?? 'CLIENTE';
    final lastName = cliente?.apellidos.split(' ').first.toUpperCase() ?? '';
    final cuentasAsync = ref.watch(cuentasClienteProvider);
    
    final saldo = cuentasAsync.maybeWhen(
      data: (cuentas) => cuentas.isNotEmpty ? cuentas.first['saldo_capital'] : 0.0,
      orElse: () => 0.0,
    );
    final saldoStr = saldo?.toStringAsFixed(2) ?? "0.00";
    final nroCuenta = cuentasAsync.maybeWhen(
      data: (cuentas) => cuentas.isNotEmpty ? cuentas.first['cod_cuenta_ahorro'] : "---",
      orElse: () => "Cargando...",
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header rosado/primario
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, $name $lastName',
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
                Text(
                  'S/. $saldoStr',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          // Operaciones Rapidas
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Operaciones rápidas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _QuickAction(icon: Icons.send, label: 'Enviar\ndinero', onTap: () {}),
                    _QuickAction(icon: Icons.receipt_long, label: 'Pagar\nservicio', onTap: () {}),
                    _QuickAction(icon: Icons.phone_android, label: 'Recargar\ncelular', onTap: () {}),
                    _QuickAction(icon: Icons.qr_code_scanner, label: 'Escanear\nQR', onTap: () {}),
                  ],
                ),
                const SizedBox(height: 32),

                // Tus cuentas
                const Text(
                  'Tus cuentas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.credit_card, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cuenta Ahorro Principal',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              nroCuenta,
                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'S/. $saldoStr',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Movimientos recientes
                const Text(
                  'Movimientos recientes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _MovimientoTile(
                  icon: Icons.arrow_upward,
                  title: 'Envío a 967453178',
                  date: '2026-06-19',
                  amount: '- S/. 10.00',
                  isPositive: false,
                ),
                const Divider(),
                _MovimientoTile(
                  icon: Icons.arrow_upward,
                  title: 'Pago Sedapal',
                  date: '2026-06-19',
                  amount: '- S/. 15.00',
                  isPositive: false,
                ),
              ],
            ),
          ),
        ],
      ),
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
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _MovimientoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String amount;
  final bool isPositive;

  const _MovimientoTile({
    required this.icon,
    required this.title,
    required this.date,
    required this.amount,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isPositive ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(date, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
