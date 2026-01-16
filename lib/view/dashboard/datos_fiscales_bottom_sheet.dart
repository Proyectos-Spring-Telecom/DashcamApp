// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class DatosFiscalesBottomSheet extends StatelessWidget {
  const DatosFiscalesBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppTheme>(
      stream: themeBloc.themeStream,
      initialData: themeBloc.currentTheme,
      builder: (context, snapshot) {
        final isDark = snapshot.data?.data.brightness == Brightness.dark;
        final backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;

        return DraggableScrollableSheet(
          initialChildSize: 0.60,
          minChildSize: 0.5,
          maxChildSize: 0.98,
          builder: (context, scrollController) {
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
                          children: [
                            // Nuevo perfil fiscal options
                            _buildNuevoPerfilFiscalOptions(
                              context,
                              textColor: textColor,
                              isDark: isDark,
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

  Widget _buildNuevoPerfilFiscalOptions(BuildContext context,
      {Color textColor = Colors.white, bool isDark = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          "Nuevo perfil fiscal",
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // Registro manual
        _buildOptionItem(
          icon: Icons.edit,
          iconColor: const Color(0xFFFDB462), // Yellow
          title: "Registro manual",
          textColor: textColor,
          onTap: () {
            Navigator.of(context).pop();
            GoRouter.of(context).go(RoutesName.nuevoPerfilFiscal);
          },
        ),
        Divider(color: Colors.grey.withOpacity(0.3), height: 1),

          // Escanear QR de Constancia
          _buildOptionItem(
            icon: Icons.qr_code_scanner,
            iconColor: const Color(0xFF205AA8), // Blue
            title: "Escanear QR de Constancia",
            textColor: textColor,
            onTap: () {
              Navigator.of(context).pop();
              GoRouter.of(context).go(RoutesName.escaneoQRConstancia);
            },
          ),
        Divider(color: Colors.grey.withOpacity(0.3), height: 1),

          // Cargar Constancia Fiscal
          _buildOptionItemWithPlus(
            icon: Icons.description,
            iconColor: Colors.grey[600]!,
            title: "Cargar Constancia Fiscal",
            textColor: textColor,
            onTap: () {
              Navigator.of(context).pop();
              GoRouter.of(context).go(RoutesName.cargarConstanciaFiscal);
            },
          ),
      ],
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: textColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItemWithPlus({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            // Icon with plus
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        color: iconColor,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: textColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

}

