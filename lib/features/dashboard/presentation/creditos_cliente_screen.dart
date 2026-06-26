import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/login_viewmodel.dart';
import '../../solicitud/data/solicitud_repository.dart';
import '../../solicitud/presentation/solicitud_viewmodel.dart';

class CreditosClienteScreen extends ConsumerStatefulWidget {
  const CreditosClienteScreen({super.key});

  @override
  ConsumerState<CreditosClienteScreen> createState() =>
      _CreditosClienteScreenState();
}

class _CreditosClienteScreenState extends ConsumerState<CreditosClienteScreen> {
  final _montoController = TextEditingController();
  final _motivoController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _solicitarCredito() async {
    final monto = double.tryParse(_montoController.text);
    final motivo = _motivoController.text.trim();

    if (monto == null || monto <= 0 || motivo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un monto válido y un motivo.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final cliente = ref.read(loginViewModelProvider).cliente;
      final repo = ref.read(solicitudRepositoryProvider);

      await repo.crear({
        "numero_documento": cliente!.numeroDocumento,
        "nombres": cliente.nombres,
        "apellidos": cliente.apellidos,
        "monto_solicitado": monto,
        "plazo_meses": 12,
        "destino_credito": motivo,
      });

      if (!mounted) return;
      ref.invalidate(solicitudesHistorialProvider);
      _mostrarDialogoExito();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar solicitud: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _mostrarDialogoExito() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Solicitud Enviada',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tu solicitud de crédito por S/ ${_montoController.text} fue registrada exitosamente.\n\nTu asesor desde la app de ventas definirá el plazo ideal de tus cuotas y procederá con la aprobación.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _montoController.clear();
                  _motivoController.clear();
                },
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner rojo "Mis creditos"
          Container(
            color: AppColors.primary,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: const Text(
              'Mis Créditos',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Oferta Pre-Aprobada Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'OFERTA PRE-APROBADA',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tienes un capital listo para hacer crecer tu negocio por un máximo de:',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'S/ 14000.00',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Formulario
                const Text(
                  '¿Cuánto dinero necesitas?',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Puedes solicitar desde S/ 100 hasta un máximo de S/ 14000.00',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _montoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.monetization_on_outlined, color: Colors.orange),
                    hintText: 'Ej. 5000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  '¿Para qué usarás este capital? (Motivo)',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _motivoController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.notes, color: Colors.orange),
                    hintText: 'Ej. Comprar mercadería y vitrinas',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _solicitarCredito,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'SOLICITAR CRÉDITO AHORA',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                // Historial de solicitudes
                const Text(
                  'Historial de Solicitudes',
                  style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ref.watch(solicitudesHistorialProvider).when(
                      data: (solicitudes) {
                        if (solicitudes.isEmpty) {
                          return const Text(
                            'Aún no tienes solicitudes previas.',
                            style: TextStyle(color: Colors.black54),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: solicitudes.length,
                          itemBuilder: (context, index) {
                            final s = solicitudes[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text('Monto: S/ ${s.montoSolicitado.toStringAsFixed(2)}'),
                                subtitle: Text('Expediente: ${s.numeroExpediente}'),
                                trailing: Chip(
                                  label: Text(
                                    s.estado.toUpperCase(),
                                    style: const TextStyle(fontSize: 10, color: Colors.white),
                                  ),
                                  backgroundColor: s.estado == 'enviado'
                                      ? Colors.blue
                                      : (s.estado == 'aprobado' ? Colors.green : Colors.orange),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Text('Error al cargar historial: $e'),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
