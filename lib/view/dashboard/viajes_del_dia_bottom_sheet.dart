// Project imports:
import 'package:dashboardpro/controller/transacciones_controller.dart';
import 'package:dashboardpro/dashboardpro.dart';
import 'package:dashboardpro/model/transaccion/transaccion_model.dart';
import 'package:dashboardpro/utils/date_formatter.dart';
import 'package:dashboardpro/view/dashboard/detalles_viaje_bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:quickalert/quickalert.dart';

/// BottomSheet que muestra los viajes del día actual.
/// Al abrirse llama a [transaccionesController.cargarViajesDelDia()].
/// Estados: loading, empty, success, error (QuickAlert en error).
class ViajesDelDiaBottomSheet extends StatefulWidget {
  const ViajesDelDiaBottomSheet({super.key});

  @override
  State<ViajesDelDiaBottomSheet> createState() =>
      _ViajesDelDiaBottomSheetState();
}

class _ViajesDelDiaBottomSheetState extends State<ViajesDelDiaBottomSheet> {
  bool _errorAlertShown = false;

  @override
  void initState() {
    super.initState();
    debugPrint('📤 [ViajesDelDiaBS] Abriendo sheet, cargando viajes del día');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      transaccionesController.cargarViajesDelDia();
    });
  }

  void _showErrorAlert() {
    if (_errorAlertShown || !mounted) return;
    _errorAlertShown = true;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Error',
      text: 'No fue posible obtener los viajes del día',
    ).whenComplete(() {
      _errorAlertShown = false;
    });
  }

  void _onDetallePressed(TransaccionModel transaccion) {
    final navigator = Navigator.of(context, rootNavigator: false);
    navigator.pop(); // Cerrar lista de viajes
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => DetallesViajeBottomSheet(transaccion: transaccion),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppTheme>(
      stream: themeBloc.themeStream,
      initialData: themeBloc.currentTheme,
      builder: (context, snapshot) {
        final isDark = snapshot.data?.data.brightness == Brightness.dark;
        final backgroundColor =
            isDark ? const Color(0xFF2C2C2C) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;
        final cardColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.4,
          maxChildSize: 0.98,
          builder: (sheetContext, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  _buildHandleBar(),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Viajes del día',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: transaccionesController,
                      builder: (context, _) {
                        final ctrl = transaccionesController;
                        if (ctrl.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (ctrl.isError) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _showErrorAlert();
                          });
                          return _buildErrorState(textColor);
                        }
                        if (ctrl.isEmpty) {
                          return _buildEmptyState(textColor);
                        }
                        return _buildList(
                          scrollController: scrollController,
                          viajes: ctrl.viajes,
                          textColor: textColor,
                          cardColor: cardColor,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bus_outlined,
            size: 64,
            color: Colors.grey[500],
          ),
          const SizedBox(height: 16),
          Text(
            'No se registran viajes el día de hoy',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey[500]),
          const SizedBox(height: 12),
          Text(
            transaccionesController.errorMessage ??
                'No fue posible obtener los viajes.',
            style: TextStyle(color: textColor, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              transaccionesController.cargarViajesDelDia();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildList({
    required ScrollController scrollController,
    required List<TransaccionModel> viajes,
    required Color textColor,
    required Color cardColor,
  }) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: viajes.length,
      itemBuilder: (context, index) {
        final t = viajes[index];
        return _buildViajeItem(
          transaccion: t,
          textColor: textColor,
          cardColor: cardColor,
        );
      },
    );
  }

  Widget _buildViajeItem({
    required TransaccionModel transaccion,
    required Color textColor,
    required Color cardColor,
  }) {
    final montoStr = transaccion.monto != null
        ? '\$${transaccion.monto!.toStringAsFixed(2)}'
        : '—';
    final fechaStr = DateFormatter.formatDateTimeFromDateTime(transaccion.fechaHora);
    final metodoPago = transaccion.nombreMetodoPago ?? '—';
    final pasajero = transaccion.nombrePasajeroCompleto ?? '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      montoStr,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fechaStr,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Método: $metodoPago',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pasajero: $pasajero',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                child: ElevatedButton.icon(
                  onPressed: () => _onDetallePressed(transaccion),
                  icon: const Icon(Icons.description, size: 16, color: Colors.white),
                  label: const Text(
                    'Detalle',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF205AA8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
