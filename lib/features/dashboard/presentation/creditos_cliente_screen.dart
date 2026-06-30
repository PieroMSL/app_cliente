import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/utils/formatters.dart';
import '../../solicitud/domain/solicitud_model.dart';
import '../../solicitud/presentation/solicitud_viewmodel.dart';

final creditosClienteProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final data = await ref.watch(apiClientProvider).get('/cliente/creditos');
  return (data as List)
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();
});

class CreditosClienteScreen extends ConsumerWidget {
  const CreditosClienteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: AppColors.primary,
            child: const TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  icon: Icon(Icons.credit_card),
                  text: 'Créditos Activos',
                ),
                Tab(
                  icon: Icon(Icons.history_toggle_off),
                  text: 'Solicitudes y Estados',
                ),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _CreditosActivosTab(),
                _SolicitudesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditosActivosTab extends ConsumerWidget {
  const _CreditosActivosTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creditosAsync = ref.watch(creditosClienteProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(creditosClienteProvider),
      child: creditosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 100),
            _InlineError(message: 'No se pudieron cargar tus créditos.'),
          ],
        ),
        data: (creditos) {
          if (creditos.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 100),
                _EmptyState(
                  icon: Icons.credit_card_off_outlined,
                  message: 'Aún no tienes créditos vigentes.\n¡Impulsa tu negocio solicitando uno nuevo!',
                ),
              ],
            );
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: creditos.length,
            itemBuilder: (context, index) {
              final credito = creditos[index];
              final saldo = (credito['saldo_total'] as num?)?.toDouble() ?? 0;
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    '${credito['producto'] ?? 'Crédito Personal'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Expediente: ${credito['cod_cuenta_credito'] ?? '-'} · '
                      '${credito['estado'] ?? 'Sin estado'}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                  trailing: Text(
                    Formatters.soles(saldo),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SolicitudesTab extends ConsumerWidget {
  const _SolicitudesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solicitudesAsync = ref.watch(solicitudesHistorialProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(solicitudesHistorialProvider),
      child: solicitudesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 100),
            _InlineError(message: 'Error al cargar solicitudes: $e'),
          ],
        ),
        data: (solicitudes) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppColors.brandGradient,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'Solicita un nuevo crédito',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Simula tus cuotas de forma instantánea y completa nuestra solicitud digital en pocos pasos.',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.calculate_outlined),
                              label: const Text('Simular'),
                              onPressed: () => context.push('/simulador'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.assignment_outlined),
                              label: const Text('Solicitar'),
                              onPressed: () => context.push('/solicitud'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (solicitudes.isNotEmpty) ...[
                const Text(
                  'Resumen de solicitudes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _kpiIndicator('Enviadas', solicitudes.where((s) => s.estado == 'enviado').length, AppColors.info),
                    _kpiIndicator('En Comité', solicitudes.where((s) => s.estado == 'recibido_comite' || s.estado == 'en_evaluacion').length, AppColors.warning),
                    _kpiIndicator('Aprobadas', solicitudes.where((s) => s.estado == 'aprobado' || s.estado == 'condicionado').length, AppColors.success),
                    _kpiIndicator('Desembolsadas', solicitudes.where((s) => s.estado == 'desembolsado').length, AppColors.primary),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              const Text(
                'Historial y seguimiento',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              solicitudes.isEmpty
                  ? const _EmptyState(
                      icon: Icons.history_toggle_off_outlined,
                      message: 'Aún no tienes solicitudes de crédito registradas.',
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: solicitudes.length,
                      itemBuilder: (context, index) {
                        final s = solicitudes[index];
                        final color = _colorEstado(s.estado);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor: color.withValues(alpha: 0.1),
                              child: Icon(
                                s.estado == 'aprobado' || s.estado == 'desembolsado'
                                    ? Icons.check_circle_outline
                                    : (s.estado == 'rechazado'
                                        ? Icons.cancel_outlined
                                        : Icons.pending_actions),
                                color: color,
                              ),
                            ),
                            title: Text(
                              'Monto: ${Formatters.soles(s.montoSolicitado)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Expediente: ${s.numeroExpediente}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                s.estado.toUpperCase(),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () => showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => _DetalleSheet(s: s),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget _kpiIndicator(String label, int valor, Color color) {
    return Expanded(
      child: Card(
        elevation: 0.5,
        color: color.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            children: [
              Text(
                '$valor',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _colorEstado(String estado) {
  switch (estado) {
    case 'aprobado':
    case 'desembolsado':
      return AppColors.success;
    case 'rechazado':
      return AppColors.danger;
    case 'condicionado':
      return AppColors.warning;
    default:
      return AppColors.info;
  }
}

class _DetalleSheet extends ConsumerStatefulWidget {
  final SolicitudResumen s;
  const _DetalleSheet({required this.s});
  @override
  ConsumerState<_DetalleSheet> createState() => _DetalleSheetState();
}

class _DetalleSheetState extends ConsumerState<_DetalleSheet> {
  Future<void> _compartirPdf() async {
    final s = widget.s;
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Banco Andino — Estado de solicitud',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Text('Cliente: ${s.clienteNombre}'),
            pw.Text('Expediente: ${s.numeroExpediente}'),
            pw.Text('Monto solicitado: ${Formatters.soles(s.montoSolicitado)}'),
            pw.Text('Estado actual: ${s.estado.toUpperCase()}'),
            if (s.createdAt != null) pw.Text('Fecha: ${s.createdAt}'),
            pw.SizedBox(height: 20),
            pw.Text(
              'Documento generado desde Banca Movil Banco Andino.',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'estado_${s.numeroExpediente}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    const etapas = [
      'enviado',
      'recibido_comite',
      'en_evaluacion',
      'aprobado',
      'desembolsado',
    ];
    final idxActual = etapas.indexOf(s.estado);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.clienteNombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: AppColors.primary),
                  tooltip: 'Compartir PDF',
                  onPressed: _compartirPdf,
                ),
              ],
            ),
            Text(
              '${s.numeroExpediente} · ${Formatters.soles(s.montoSolicitado)}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const Divider(height: 20),
            ...List.generate(etapas.length, (i) {
              final hecho = idxActual >= 0 && i <= idxActual;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      hecho ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: hecho ? AppColors.success : AppColors.neutral,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      etapas[i].replaceAll('_', ' '),
                      style: TextStyle(
                        color: hecho
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.danger, fontSize: 14),
      ),
    );
  }
}
