// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:dashboardpro/model/transaccion/transaccion_model.dart';
import 'package:dashboardpro/utils/date_formatter.dart';

class DetallesViajeBottomSheet extends StatelessWidget {
  /// Si se proporciona, se muestran los datos del viaje (monto, fecha, método de pago, ubicación).
  /// Si es null, se muestra contenido estático (comportamiento anterior).
  const DetallesViajeBottomSheet({super.key, this.transaccion});

  final TransaccionModel? transaccion;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppTheme>(
      stream: themeBloc.themeStream,
      initialData: themeBloc.currentTheme,
      builder: (context, snapshot) {
        final isDark = snapshot.data?.data.brightness == Brightness.dark;
        final backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;
        final cardColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.5,
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
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title outside the card
                            Center(
                              child: Text(
                                "Detalles del viaje",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20.0),

                            // Detalles del viaje section (usa datos reales si [transaccion] no es null)
                            _buildDetallesViajeSection(
                              context: sheetContext,
                              parentContext: context,
                              textColor: textColor,
                              isDark: isDark,
                              cardColor: cardColor,
                              transaccion: transaccion,
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildDetallesViajeSection({
    required BuildContext context,
    required BuildContext parentContext,
    required Color textColor,
    required bool isDark,
    required Color cardColor,
    TransaccionModel? transaccion,
  }) {
    final bool hasRealData = transaccion != null;
    final String montoStr = hasRealData && transaccion!.monto != null
        ? '\$${transaccion.monto!.toStringAsFixed(2)}'
        : '\$84.14';
    final String fechaStr = hasRealData && transaccion.fechaHora != null
        ? DateFormatter.formatDateTimeFromDateTime(transaccion.fechaHora)
        : '27 Nov 2025 - 12:44 pm';
    final String metodoPago = hasRealData && transaccion.nombreMetodoPago != null
        ? transaccion.nombreMetodoPago!
        : '—';
    final String inicioTexto = hasRealData && transaccion!.latitudFinal != null
        ? transaccion.latitudFinal!.toString()
        : '—';
    final String finTexto = hasRealData && transaccion.longitudFinal != null
        ? transaccion.longitudFinal!.toString()
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trip Summary
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasRealData ? 'Detalle del viaje' : "Viaje Dashcam: Diamante - Temixco",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fechaStr,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    montoStr,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hasRealData) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Método de pago: $metodoPago',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFA6CE39),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.directions_car,
                    color: Colors.white,
                    size: 32,
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Color(0xFFA6CE39),
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Inicio (latitudFinal) y Fin (longitudFinal) cuando hay datos reales
        if (hasRealData) ...[
          Text(
            "Inicio:",
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900]! : Colors.grey[200]!,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white,
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    inicioTexto,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Fin:",
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900]! : Colors.grey[200]!,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white,
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    finTexto,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ] else ...[
          // Inicio section (contenido estático cuando no hay transaccion)
          Text(
            "Inicio:",
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900]! : Colors.grey[200]!,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white,
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "Calle Prolongación geranios 22, Lomas del Carril, Temixco Morelos 62583",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "12:46 PM",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Destino:",
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900]! : Colors.grey[200]!,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white,
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "Av. Domingo Diez 15021, San Cristobal, 62230 Cuernavaca, Mor., México",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "12:54 PM",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle Facturar button
                },
                icon: const Icon(
                  Icons.description,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  "Facturar",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF205AA8), // Blue
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Cerrar el bottomsheet
                  Navigator.of(parentContext).pop();
                },
                icon: const Icon(
                  Icons.check,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  "Aceptar",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA6CE39), // Green
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
