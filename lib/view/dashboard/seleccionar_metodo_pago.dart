// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SeleccionarMetodoPagoPage extends StatefulWidget {
  final String? amount;
  const SeleccionarMetodoPagoPage({super.key, this.amount});

  @override
  State<SeleccionarMetodoPagoPage> createState() =>
      _SeleccionarMetodoPagoPageState();
}

class _SeleccionarMetodoPagoPageState extends State<SeleccionarMetodoPagoPage> {
  String? _selectedCard = '9812'; // Default selected card

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppTheme>(
      stream: themeBloc.themeStream,
      initialData: themeBloc.currentTheme,
      builder: (context, snapshot) {
        final isDark = snapshot.data?.data.brightness == Brightness.dark;
        final backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;

        const systemUiOverlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemUiOverlayStyle,
          child: Scaffold(
            backgroundColor: backgroundColor,
            extendBodyBehindAppBar: true,
            body: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: backgroundColor,
                child: Responsive(
                  mobile: mobileView(context: context, isDark: isDark, textColor: textColor),
                  desktop: desktopView(context: context, isDark: isDark, textColor: textColor),
                  tablet: mobileView(context: context, isDark: isDark, textColor: textColor),
                ),
              ),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(context, isDark),
          ),
        );
      },
    );
  }

  Widget mobileView({required BuildContext context, required bool isDark, required Color textColor}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          _buildHeader(context, textColor: textColor, isDark: isDark),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                          // Title
                          Text(
                            "Selecciona la forma de pago",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16.0),

                          // Payment cards section
                          _buildPaymentCardsSection(
                            isDark: isDark,
                            textColor: textColor,
                          ),
                          const SizedBox(height: 24.0),

                          // Other payment methods
                          _buildPaymentMethodButton(
                            title: "mercado pago",
                            isDark: isDark,
                            textColor: textColor,
                            onTap: () {
                              // Action for Mercado Pago
                            },
                          ),
                          const SizedBox(height: 12.0),
                          _buildPaymentMethodButton(
                            title: "PayPal",
                            isDark: isDark,
                            textColor: textColor,
                            onTap: () {
                              // Action for PayPal
                            },
                          ),
                          const SizedBox(height: 12.0),
                          _buildPaymentMethodButton(
                            title: "SPEI",
                            isDark: isDark,
                            textColor: textColor,
                            onTap: () {
                              // Action for SPEI
                            },
                          ),
                          const SizedBox(height: 32.0),
                          // Commission text - centered
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                "Esta operación no genera ningún tipo de comisión.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          // Continuar button
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                final amount = widget.amount ?? '50';
                                GoRouter.of(context).go(
                                  RoutesName.resumen,
                                  extra: {'amount': amount},
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF205AA8,
                                ), // Blue
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Continuar",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget desktopView({required BuildContext context, required bool isDark, required Color textColor}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          _buildHeader(context, textColor: textColor, isDark: isDark),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    "Selecciona la forma de pago",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Payment cards section
                  _buildPaymentCardsSection(
                    isDark: isDark,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 24.0),

                  // Other payment methods
                  _buildPaymentMethodButton(
                    title: "mercado pago",
                    isDark: isDark,
                    textColor: textColor,
                    onTap: () {
                      // Action for Mercado Pago
                    },
                  ),
                  const SizedBox(height: 12.0),
                  _buildPaymentMethodButton(
                    title: "PayPal",
                    isDark: isDark,
                    textColor: textColor,
                    onTap: () {
                      // Action for PayPal
                    },
                  ),
                  const SizedBox(height: 12.0),
                  _buildPaymentMethodButton(
                    title: "SPEI",
                    isDark: isDark,
                    textColor: textColor,
                    onTap: () {
                      // Action for SPEI
                    },
                  ),
                  const SizedBox(height: 32.0),
                  // Commission text - centered
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        "Esta operación no genera ningún tipo de comisión.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Continuar button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final amount = widget.amount ?? '50';
                        GoRouter.of(context).go(
                          RoutesName.resumen,
                          extra: {'amount': amount},
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF205AA8,
                        ), // Blue
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Continuar",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {Color textColor = Colors.white, bool isDark = true}) {
    final paddingTop = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: paddingTop + 16.0,
        bottom: 16.0,
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: Icon(Icons.arrow_back, color: textColor, size: 24),
            onPressed: () {
              GoRouter.of(context).go(RoutesName.recargar);
            },
          ),
          // Title
          Expanded(
            child: Text(
              "Recargar Monedero",
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Profile avatar
          GestureDetector(
            onTap: () {
              GoRouter.of(context).go(RoutesName.perfil);
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
              child: Icon(Icons.person, color: textColor, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCardsSection({
    required bool isDark,
    required Color textColor,
  }) {
    final cardColor = isDark ? Colors.grey[800] : Colors.grey[100];

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment methods logos at top right
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image(
                image: AssetImage('assets/images/metodos.png'),
                width: 120,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading image: $error');
                  return Container(
                    width: 120,
                    height: 40,
                    color: Colors.red.withValues(alpha: 0.3),
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 30),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Card selection buttons
          Row(
            children: [
              Expanded(
                child: _buildCardButton(
                  cardNumber: "9812",
                  isSelected: _selectedCard == '9812',
                  isDark: isDark,
                  textColor: textColor,
                  onTap: () {
                    setState(() {
                      _selectedCard = '9812';
                    });
                  },
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildCardButton(
                  cardNumber: "3219",
                  isSelected: _selectedCard == '3219',
                  isDark: isDark,
                  textColor: textColor,
                  onTap: () {
                    setState(() {
                      _selectedCard = '3219';
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Add card button - inside the card
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                GoRouter.of(context).go(RoutesName.nuevaTarjeta);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFA6CE39), // Green
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Agregar tarjeta",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardButton({
    required String cardNumber,
    required bool isSelected,
    required bool isDark,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    final buttonColor = isDark ? Colors.grey[900] : Colors.grey[200];
    final borderColor = isSelected
        ? const Color(0xFFA6CE39) // Light green
        : Colors.grey[600]!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFFA6CE39) : Colors.grey[600]!,
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFFA6CE39).withValues(alpha: 0.2)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFA6CE39),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              "**** $cardNumber",
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton({
    required String title,
    required bool isDark,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    final buttonColor = isDark ? Colors.grey[800] : Colors.grey[100];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: title == "mercado pago"
                    ? Colors.blue[300]
                    : title == "PayPal"
                        ? Colors.blue
                        : textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isDark) {
    final navBarColor = isDark ? Colors.grey[900] : Colors.grey[100];
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: navBarColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF205AA8), // Blue
          unselectedItemColor: Colors.grey[600],
          currentIndex: 0, // Home is selected
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          iconSize: 24,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Monedero',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timeline),
              label: 'Actividad',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Configuración',
            ),
          ],
        onTap: (index) {
          if (index == 0) {
            // Navegar al dashboard
            GoRouter.of(context).go(RoutesName.dashboard);
          } else if (index == 1) {
            // Abrir bottomsheet de Monedero (Actividad)
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const MonederoBottomSheet(),
            );
          } else if (index == 2) {
            // Navegar a perfil de usuario
            GoRouter.of(context).go(RoutesName.perfil);
          }
        },
      ),
      ),
    );
  }
}
