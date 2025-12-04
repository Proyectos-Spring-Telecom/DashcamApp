// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'dart:ui';
import 'package:dashboardpro/view/dashboard/detalles_viaje_bottom_sheet.dart';
import 'package:flutter/services.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppTheme>(
      stream: themeBloc.themeStream,
      initialData: themeBloc.currentTheme,
      builder: (context, snapshot) {
        final isDark = snapshot.data?.data.brightness == Brightness.dark;
        final backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

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
            drawer: _buildDrawer(context, isDark),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              color: backgroundColor,
              child: SafeArea(
                top: false,
                bottom: false,
                child: Responsive(
                  mobile: mobileView(context: context, isDark: isDark),
                  desktop: desktopView(context: context, isDark: isDark),
                  tablet: mobileView(context: context, isDark: isDark),
                ),
              ),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(context, isDark),
          ),
        );
      },
    );
  }

  Widget mobileView({required BuildContext context, required bool isDark}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          _buildHeader(context, isDark: isDark),

          // Content
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Monedero section
                _buildMonederoSection(context, isDark: isDark),
                const SizedBox(height: 16.0),

                // Expense and Recharge cards
                Row(
                  children: [
                    Expanded(
                      child: _buildExpenseCard(isDark: isDark),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildRechargeCard(isDark: isDark),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildFacturarButton(context),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildRecargarButton(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // General section
                _buildGeneralSection(context, isDark: isDark),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget desktopView({required BuildContext context, required bool isDark}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          _buildHeader(context, isDark: isDark),

          // Content
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 48.0, vertical: 12.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Monedero section
                  _buildMonederoSection(context, isDark: isDark),
                  const SizedBox(height: 16.0),

                  // Expense and Recharge cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildExpenseCard(isDark: isDark),
                      ),
                      const SizedBox(width: 24.0),
                      Expanded(
                        child: _buildRechargeCard(isDark: isDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildFacturarButton(context),
                      ),
                      const SizedBox(width: 24.0),
                      Expanded(
                        child: _buildRecargarButton(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  // General section
                  _buildGeneralSection(context, isDark: isDark),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {bool isDark = true}) {
    final paddingTop = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 24.0,
        top: paddingTop + 8.0,
        bottom: 8.0,
      ),
      child: Row(
        children: [
          // Hamburger menu - sin padding extra para alineación
          Builder(
            builder: (context) => IconButton(
              icon:
                  Icon(Icons.menu, color: isDark ? Colors.white : Colors.black),
              padding: EdgeInsets.zero, // Eliminar padding interno
              constraints:
                  const BoxConstraints(), // Eliminar constraints mínimos
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          const SizedBox(width: 8), // Espacio entre menú y texto

          // Title "¡Hola, Andrea!" - alineado con Monedero
          Text(
            "¡Hola, Andrea!",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          // Spacer to push avatar to the right
          Spacer(),

          // Profile avatar
          GestureDetector(
            onTap: () {
              // Navegar a perfil de usuario
              GoRouter.of(context).go(RoutesName.perfil);
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
              child: Icon(
                Icons.person,
                color: isDark ? Colors.white : Colors.black,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonederoSection(BuildContext context, {bool isDark = true}) {
    final textColor = isDark ? Colors.white : Colors.black;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Monedero title with green dot
        Row(
          children: [
            Text(
              "Monedero",
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFA6CE39), // Green
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),

        // Main wallet card with gradient
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                const Color(0xFF2E82A5), // Light blue
                const Color(0xFF2E4D87), // Dark blue
              ],
            ),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Stack(
            children: [
              // Estudiante label (top right)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA6CE39), // Green
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "Estudiante",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // Main content column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Saldo total text and amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Saldo total:",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "\$ 222,358",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Bottom section with card number (left) and logo (right) aligned
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Card number - left side
                      Text(
                        "**** **** **** 0322",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          letterSpacing: 2,
                        ),
                      ),

                      // Logo - right side
                      Image.asset(
                        'assets/images/logo_dash.png',
                        height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 40,
                            width: 40,
                            color: Colors.white.withOpacity(0.2),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard({bool isDark = true}) {
    final cardColor = isDark ? Colors.grey[800] : Colors.grey[100];
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFDB462)
                  .withOpacity(0.2), // Yellow with opacity
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.swap_horiz,
              color: const Color(0xFFFDB462), // Yellow
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Gasto Octubre",
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "\$ 20,850",
            style: TextStyle(
              color: const Color(0xFFFDB462), // Yellow
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRechargeCard({bool isDark = true}) {
    final cardColor = isDark ? Colors.grey[800] : Colors.grey[100];
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  const Color(0xFF205AA8).withOpacity(0.2), // Blue with opacity
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_upward,
              color: const Color(0xFF205AA8), // Blue
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Última recarga",
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "\$ 100",
            style: TextStyle(
              color: const Color(0xFF205AA8), // Blue
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacturarButton(BuildContext context) {
    return FilledButton(
      onPressed: () {
        // Action for Facturar
      },
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF205AA8), // Blue
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            "Facturar",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecargarButton(BuildContext context) {
    return FilledButton(
      onPressed: () {
        GoRouter.of(context).go(RoutesName.recargar);
      },
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFA6CE39), // Green
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.attach_money, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            "Recargar",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSection(BuildContext context, {bool isDark = true}) {
    final textColor = isDark ? Colors.white : Colors.black;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "General",
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12.0),

        // 2x2 Grid
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildGeneralCard(
                    context: context,
                    icon: Icons.qr_code,
                    title: "Generar Código QR",
                    color: const Color(0xFFFDB462), // Yellow
                    badge: CodigosQRData.cantidad.toString(),
                    isDark: isDark,
                    onTap: () {
                      // Navigate to QR Code generation screen
                      GoRouter.of(context).go(RoutesName.pagoQR);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildGeneralCard(
                    context: context,
                    icon: Icons.analytics,
                    title: "Estadísticas",
                    color: const Color(0xFFFB8072), // Red
                    isDark: isDark,
                    onTap: () {
                      // Show statistics bottom sheet
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const EstadisticasBottomSheet(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _buildGeneralCard(
                    context: context,
                    icon: Icons.chat_bubble_rounded,
                    title: "Métodos de Pago",
                    color: const Color(0xFFA6CE39), // Green
                    badge: TarjetasPagoData.cantidad.toString(),
                    isDark: isDark,
                    onTap: () {
                      // Navigate to Payment Methods screen
                      GoRouter.of(context).go(RoutesName.metodosPago);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildGeneralCard(
                    context: context,
                    icon: Icons.swap_horiz,
                    title: "Registros",
                    color: const Color(0xFF205AA8), // Blue
                    badge: null,
                    isDark: isDark,
                    onTap: () {
                      // Abrir bottomsheet de Monedero en la sección de Operaciones
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            const MonederoBottomSheet(initialTabIndex: 3),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGeneralCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    String? badge,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final cardColor = isDark ? Colors.grey[800] : Colors.grey[100];
    final textColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                if (badge != null)
                  Text(
                    badge,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
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

  Widget _buildDrawer(BuildContext context, bool isDark) {
    final backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? Colors.grey[900] : Colors.grey[100];

    return Drawer(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Profile section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: cardColor,
              ),
              child: Column(
                children: [
                  // Profile image
                  CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        isDark ? Colors.grey[800] : Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      color: textColor,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Full name
                  Text(
                    "Andrea Barajas Cruz",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFA6CE39), // Green for active
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Activo",
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Menu options
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading:
                        Icon(Icons.account_balance_wallet, color: textColor),
                    title: Text(
                      "Monedero",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      GoRouter.of(context).go(RoutesName.dashboard);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.directions_bus, color: textColor),
                    title: Text(
                      "Transporte",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      GoRouter.of(context).go(RoutesName.transporte);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.timeline, color: textColor),
                    title: Text(
                      "Actividad",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const MonederoBottomSheet(),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: textColor),
                    title: Text(
                      "Configuración",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      GoRouter.of(context).go(RoutesName.perfil);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.palette, color: textColor),
                    title: Text(
                      "Apariencia",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const AparienciaBottomSheet(),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Cierre de Sesión at the bottom
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF205AA8)),
              title: Text(
                "Cierre de Sesión",
                style: TextStyle(
                  color: const Color(0xFF205AA8), // Blue
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Navigate to login page
                GoRouter.of(context).go(RoutesName.login);
              },
            ),
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
              color: Colors.black.withOpacity(0.2),
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
              // Abrir bottomsheet de Monedero
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const MonederoBottomSheet(),
              );
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

// Modelo para representar un código QR
class CodigoQR {
  final String code;
  final String date;
  final String amount;
  final String type;

  CodigoQR({
    required this.code,
    required this.date,
    required this.amount,
    required this.type,
  });
}

// Lista compartida de códigos QR
class CodigosQRData {
  static List<CodigoQR> _codigos = [
    CodigoQR(
      code: "1234567VBDFFJGRTH",
      date: "01-Mayo-2025",
      amount: "-\$ 15",
      type: "Débito",
    ),
    CodigoQR(
      code: "1234567VBDFFJGRTH",
      date: "01-Mayo-2025",
      amount: "-\$ 15",
      type: "Débito",
    ),
    CodigoQR(
      code: "1234567VBDFFJGRTH",
      date: "01-Mayo-2025",
      amount: "-\$ 15",
      type: "Débito",
    ),
    CodigoQR(
      code: "1234567VBDFFJGRTH",
      date: "01-Mayo-2025",
      amount: "-\$ 15",
      type: "Débito",
    ),
  ];

  static List<CodigoQR> get codigos => _codigos;
  static int get cantidad => _codigos.length;

  // Método para agregar un nuevo código QR
  static void agregarCodigo(CodigoQR codigo) {
    _codigos.add(codigo);
  }

  // Método para eliminar un código QR
  static void eliminarCodigo(int index) {
    if (index >= 0 && index < _codigos.length) {
      _codigos.removeAt(index);
    }
  }
}

// Modelo para representar una tarjeta de pago
class TarjetaPago {
  final String cardNumber;
  final String cvv;
  final String cardholderName;
  final List<Color> gradientColors;
  final Color textColor;
  final String cardType; // 'mastercard' o 'visa'

  TarjetaPago({
    required this.cardNumber,
    required this.cvv,
    required this.cardholderName,
    required this.gradientColors,
    required this.textColor,
    required this.cardType,
  });
}

// Lista compartida de tarjetas de pago
class TarjetasPagoData {
  static List<TarjetaPago> _tarjetas = [
    TarjetaPago(
      cardNumber: "1234 5678 9999 0000",
      cvv: "CVV 123",
      cardholderName: "Andrea Barajas Cruz",
      gradientColors: [
        const Color(0xFF8B0000), // Dark red
        const Color(0xFFDC143C), // Crimson red
      ],
      textColor: Colors.white,
      cardType: 'mastercard',
    ),
    TarjetaPago(
      cardNumber: "5678 1234 8888 9999",
      cvv: "CVV 456",
      cardholderName: "Andrea Barajas Cruz",
      gradientColors: [
        Colors.white,
        Colors.grey[300]!,
      ],
      textColor: Colors.black,
      cardType: 'visa',
    ),
    TarjetaPago(
      cardNumber: "9999 8888 7777 6666",
      cvv: "CVV 789",
      cardholderName: "Andrea Barajas Cruz",
      gradientColors: [
        const Color(0xFF1E3A8A), // Dark blue
        const Color(0xFF3B82F6), // Bright blue
      ],
      textColor: Colors.white,
      cardType: 'mastercard',
    ),
  ];

  static List<TarjetaPago> get tarjetas => _tarjetas;
  static int get cantidad => _tarjetas.length;

  // Método para agregar una nueva tarjeta
  static void agregarTarjeta(TarjetaPago tarjeta) {
    _tarjetas.add(tarjeta);
  }

  // Método para eliminar una tarjeta
  static void eliminarTarjeta(int index) {
    if (index >= 0 && index < _tarjetas.length) {
      _tarjetas.removeAt(index);
    }
  }
}

class MonederoBottomSheet extends StatefulWidget {
  final int initialTabIndex;

  const MonederoBottomSheet({
    super.key,
    this.initialTabIndex = 0, // Por defecto, General
  });

  @override
  State<MonederoBottomSheet> createState() => _MonederoBottomSheetState();
}

class _MonederoBottomSheetState extends State<MonederoBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _selectedTabIndex;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
      // All tabs show content in same page, no navigation
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

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
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Tabs
                  _buildTabs(textColor: textColor),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_selectedTabIndex == 0) ...[
                              // General section with charts
                              _buildGeneralSection(textColor: textColor),
                            ] else if (_selectedTabIndex == 1) ...[
                              // Código QR section
                              _buildCodigoQRSection(context,
                                  textColor: textColor, isDark: isDark),
                              const SizedBox(height: 24.0),
                              // Mis códigos section
                              _buildMisCodigosSection(
                                  textColor: textColor, isDark: isDark),
                            ] else if (_selectedTabIndex == 2) ...[
                              // Viajes section
                              _buildViajesSection(
                                  textColor: textColor, isDark: isDark),
                            ] else if (_selectedTabIndex == 3) ...[
                              // Operaciones section
                              _buildOperacionesSection(
                                  textColor: textColor, isDark: isDark),
                            ],
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

  Widget _buildTabs({Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem('General', 0, textColor: textColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabItem('Códigos QR', 1, textColor: textColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabItem('Viajes', 2, textColor: textColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabItem('Registros', 3, textColor: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index,
      {Color textColor = Colors.white}) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF205AA8) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (textColor == Colors.white
                      ? Colors.grey[600]
                      : Colors.grey[700]),
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildCodigoQRSection(BuildContext context,
      {Color textColor = Colors.white, bool isDark = true}) {
    final cardColor = isDark ? Colors.grey[800] : Colors.grey[100];

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Código QR",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Genera código qr para realizar pagos.",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Large button with plus icon
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).go(RoutesName.pagoQR);
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF205AA8), // Blue
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMisCodigosSection(
      {Color textColor = Colors.white, bool isDark = true}) {
    final codigos = CodigosQRData.codigos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mis códigos",
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // List of QR codes - dinámico
        if (codigos.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "No hay códigos QR generados",
              style: TextStyle(
                color: textColor,
                fontSize: 14,
              ),
            ),
          )
        else
          ...codigos.asMap().entries.map((entry) {
            final index = entry.key;
            final codigo = entry.value;
            return Padding(
              padding:
                  EdgeInsets.only(bottom: index < codigos.length - 1 ? 12 : 0),
              child: _buildCodigoItem(
                code: codigo.code,
                date: codigo.date,
                amount: codigo.amount,
                type: codigo.type,
                textColor: textColor,
                isDark: isDark,
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildCodigoItem({
    required String code,
    required String date,
    required String amount,
    required String type,
    Color textColor = Colors.white,
    bool isDark = true,
  }) {
    final cardColor = isDark ? Colors.grey[800] : Colors.grey[100];

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // QR icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFDB462)
                  .withOpacity(0.2), // Orange with opacity
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code,
              color: Color(0xFFFDB462), // Orange
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Code and date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Amount and type
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                type,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperacionesSection(
      {Color textColor = Colors.white, bool isDark = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lista de transacciones
        _buildTransaccionItem(
          description: "1234567VBDFFJGRTH",
          date: "01-Mayo-2022",
          amount: "-\$ 15",
          type: "Débito",
          iconType: 'qr',
          textColor: textColor,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTransaccionItem(
          description: "1234567VBDFFJGRTH",
          date: "01-Mayo-2022",
          amount: "-\$ 10",
          type: "Débito",
          iconType: 'bus',
          textColor: textColor,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTransaccionItem(
          description: "1234567VBDFFJGRTH",
          date: "01-Mayo-2022",
          amount: "-\$ 20",
          type: "Débito",
          iconType: 'qr',
          textColor: textColor,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTransaccionItem(
          description: "1234567VBDFFJGRTH",
          date: "01-Mayo-2022",
          amount: "\$ 100",
          type: "Recarga",
          iconType: 'recharge',
          textColor: textColor,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTransaccionItem(
          description: "1234567VBDFFJGRTH",
          date: "01-Mayo-2022",
          amount: "-\$ 20",
          type: "Débito",
          iconType: 'bus',
          textColor: textColor,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTransaccionItem(
          description: "1234567VBDFFJGRTH",
          date: "01-Mayo-2022",
          amount: "-\$ 20",
          type: "Débito",
          iconType: 'qr',
          textColor: textColor,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTransaccionItem(
          description: "1234567VBDFFJGRTH",
          date: "01-Mayo-2022",
          amount: "\$ 100",
          type: "Recarga",
          iconType: 'recharge',
          textColor: textColor,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTransaccionItem(
          description: "1234567VBDFFJGRTH",
          date: "01-Mayo-2022",
          amount: "-\$ 20",
          type: "Débito",
          iconType: 'bus',
          textColor: textColor,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildTransaccionItem({
    required String description,
    required String date,
    required String amount,
    required String type,
    required String iconType,
    Color textColor = Colors.white,
    bool isDark = true,
  }) {
    IconData iconData;
    Color iconColor;

    if (iconType == 'qr') {
      iconData = Icons.qr_code;
      iconColor = const Color(0xFF205AA8); // Blue
    } else if (iconType == 'bus') {
      iconData = Icons.directions_bus;
      iconColor = const Color(0xFF205AA8); // Blue
    } else {
      // recharge
      iconData = Icons.attach_money;
      iconColor = const Color(0xFFA6CE39); // Green
    }

    final cardColor = isDark ? Colors.grey[800] : Colors.grey[100];

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Description and date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Amount and type
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                type,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSection({Color textColor = Colors.white}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Balance section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Balance",
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Legend
            Row(
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDB462), // Yellow/Orange
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Gastos",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA6CE39), // Green
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Recargas",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24.0),

        // Stacked Bar Chart
        SizedBox(
          height: 250,
          child: _buildStackedBarChart(textColor: textColor),
        ),

        const SizedBox(height: 32.0),

        // Monthly expenses chart
        Text(
          "Gastos durante cada mes",
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24.0),

        // Grouped Bar Chart
        SizedBox(
          height: 250,
          child: _buildGroupedBarChart(textColor: textColor),
        ),
      ],
    );
  }

  Widget _buildStackedBarChart({Color textColor = Colors.white}) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: TextStyle(color: textColor),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: const MajorGridLines(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        labelStyle: TextStyle(color: textColor),
      ),
      series: <CartesianSeries>[
        StackedColumnSeries<MonthlyData, String>(
          dataSource: [
            MonthlyData('Ene', 45000, 80000),
            MonthlyData('Feb', 60000, 70000),
            MonthlyData('Mar', 55000, 75000),
            MonthlyData('Abr', 70000, 60000),
            MonthlyData('May', 65000, 85000),
            MonthlyData('Jun', 95000, 25000),
            MonthlyData('Jul', 50000, 70000),
            MonthlyData('Ago', 75000, 55000),
            MonthlyData('Sep', 60000, 80000),
          ],
          xValueMapper: (MonthlyData data, _) => data.month,
          yValueMapper: (MonthlyData data, _) => data.expenses,
          color: const Color(0xFFFDB462), // Yellow/Orange for Gastos
          name: 'Gastos',
        ),
        StackedColumnSeries<MonthlyData, String>(
          dataSource: [
            MonthlyData('Ene', 45000, 80000),
            MonthlyData('Feb', 60000, 70000),
            MonthlyData('Mar', 55000, 75000),
            MonthlyData('Abr', 70000, 60000),
            MonthlyData('May', 65000, 85000),
            MonthlyData('Jun', 95000, 25000),
            MonthlyData('Jul', 50000, 70000),
            MonthlyData('Ago', 75000, 55000),
            MonthlyData('Sep', 60000, 80000),
          ],
          xValueMapper: (MonthlyData data, _) => data.month,
          yValueMapper: (MonthlyData data, _) => data.recharges,
          color: const Color(0xFFA6CE39), // Green for Recargas
          name: 'Recargas',
        ),
      ],
    );
  }

  Widget _buildGroupedBarChart({Color textColor = Colors.white}) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: TextStyle(color: textColor),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: const MajorGridLines(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        labelStyle: TextStyle(color: textColor),
      ),
      series: <CartesianSeries>[
        ColumnSeries<ExpenseCategory, String>(
          dataSource: [
            ExpenseCategory('Ene', 45000, 35000, 25000),
            ExpenseCategory('Feb', 55000, 40000, 35000),
            ExpenseCategory('Mar', 38000, 42000, 30000),
          ],
          xValueMapper: (ExpenseCategory data, _) => data.month,
          yValueMapper: (ExpenseCategory data, _) => data.category1,
          color: const Color(0xFFA6CE39), // Green
          name: 'Category 1',
          width: 0.6,
        ),
        ColumnSeries<ExpenseCategory, String>(
          dataSource: [
            ExpenseCategory('Ene', 45000, 35000, 25000),
            ExpenseCategory('Feb', 55000, 40000, 35000),
            ExpenseCategory('Mar', 38000, 42000, 30000),
          ],
          xValueMapper: (ExpenseCategory data, _) => data.month,
          yValueMapper: (ExpenseCategory data, _) => data.category2,
          color: const Color(0xFF205AA8), // Blue
          name: 'Category 2',
          width: 0.6,
        ),
        ColumnSeries<ExpenseCategory, String>(
          dataSource: [
            ExpenseCategory('Ene', 45000, 35000, 25000),
            ExpenseCategory('Feb', 55000, 40000, 35000),
            ExpenseCategory('Mar', 38000, 42000, 30000),
          ],
          xValueMapper: (ExpenseCategory data, _) => data.month,
          yValueMapper: (ExpenseCategory data, _) => data.category3,
          color: const Color(0xFFFB8072), // Red/Pink
          name: 'Category 3',
          width: 0.6,
        ),
      ],
    );
  }

  // Viajes Section
  Widget _buildViajesSection(
      {Color textColor = Colors.white, bool isDark = true}) {
    final cardColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Último Viaje section
        _buildUltimoViajeSection(
          textColor: textColor,
          isDark: isDark,
          cardColor: cardColor,
        ),
        const SizedBox(height: 24.0),

        // Actividad section
        Text(
          "Actividad",
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),

        // Activity grid 2x2
        _buildActivityGrid(
          textColor: textColor,
          isDark: isDark,
          cardColor: cardColor,
        ),
      ],
    );
  }

  Widget _buildUltimoViajeSection({
    required Color textColor,
    required bool isDark,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Último Viaje:",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Calle Ignacio Zaragoza 12",
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "27 Nov 25 - 12:13 pm",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              // Total aligned to the right
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Total: \$ 84.14",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          // Top right - Green car icon
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFA6CE39), // Green
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.directions_car,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityGrid({
    required Color textColor,
    required bool isDark,
    required Color cardColor,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildActivityCard(
          location: "Ignacio Zaragoza 12",
          dateTime: "27 Nov 25 - 12:13 pm",
          cost: "\$ 84.14",
          textColor: textColor,
          cardColor: cardColor,
        );
      },
    );
  }

  Widget _buildActivityCard({
    required String location,
    required String dateTime,
    required String cost,
    required Color textColor,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                dateTime,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cost,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Detalle button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Obtener el Navigator principal antes de cerrar
                final navigator = Navigator.of(context, rootNavigator: false);
                // Cerrar el bottomsheet actual
                navigator.pop();
                // Abrir el bottomsheet de detalles del viaje usando el Navigator principal
                Future.delayed(const Duration(milliseconds: 200), () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (newContext) => const DetallesViajeBottomSheet(),
                  );
                });
              },
              icon: const Icon(
                Icons.description,
                size: 16,
                color: Colors.white,
              ),
              label: const Text(
                "Detalle",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF205AA8), // Blue
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AparienciaBottomSheet extends StatefulWidget {
  const AparienciaBottomSheet({super.key});

  @override
  State<AparienciaBottomSheet> createState() => _AparienciaBottomSheetState();
}

class _AparienciaBottomSheetState extends State<AparienciaBottomSheet> {
  String _selectedTheme = 'Sistema'; // Default: Sistema

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
          initialChildSize: 0.4,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: Text(
                      "Apariencia",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Content with three horizontal options
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildThemeOption('Claro', 'Claro'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildThemeOption('Oscuro', 'Oscuro'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildThemeOption('Sistema', 'Sistema'),
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

  Widget _buildThemeOption(String label, String value) {
    return StreamBuilder<AppTheme>(
      stream: themeBloc.themeStream,
      initialData: themeBloc.currentTheme,
      builder: (context, snapshot) {
        final isDark = snapshot.data?.data.brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedTheme = value;
            });
            // Lógica para cambiar el tema
            if (value == 'Claro') {
              themeBloc.toggleDarkMode(false);
            } else if (value == 'Oscuro') {
              themeBloc.toggleDarkMode(true);
            } else {
              // Sistema - usar el tema del sistema
              final brightness = MediaQuery.of(context).platformBrightness;
              themeBloc.toggleDarkMode(brightness == Brightness.dark);
            }
          },
          child: Column(
            children: [
              // Preview card
              _buildPreviewCard(value),
              const SizedBox(height: 12),
              // Label
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              // Radio button
              Radio<String>(
                value: value,
                groupValue: _selectedTheme,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTheme = newValue!;
                  });
                  // Lógica para cambiar el tema
                  if (newValue == 'Claro') {
                    themeBloc.toggleDarkMode(false);
                  } else if (newValue == 'Oscuro') {
                    themeBloc.toggleDarkMode(true);
                  } else {
                    // Sistema - usar el tema del sistema
                    final brightness =
                        MediaQuery.of(context).platformBrightness;
                    themeBloc.toggleDarkMode(brightness == Brightness.dark);
                  }
                },
                activeColor: const Color(0xFF205AA8),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewCard(String theme) {
    if (theme == 'Claro') {
      return _buildLightPreview();
    } else if (theme == 'Oscuro') {
      return _buildDarkPreview();
    } else {
      // Sistema - dividido verticalmente
      return _buildSystemPreview();
    }
  }

  Widget _buildLightPreview() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar and lines
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Card content
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkPreview() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar and lines
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Card content
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemPreview() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Left half - Light
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right half - Dark
            Expanded(
              child: Container(
                color: const Color(0xFF2C2C2C),
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[700],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[700],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
