// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'dart:ui';
import 'package:dashboardpro/view/dashboard/detalles_viaje_bottom_sheet.dart';
import 'package:flutter/services.dart';
import 'package:dashboardpro/controller/auth_bloc.dart';
import 'package:dashboardpro/controller/extravio_bloc.dart';
import 'package:dashboardpro/model/auth/user.dart';
import 'package:quickalert/quickalert.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dashboardpro/widgets/routes/app_routes.dart' as app_routes;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _walletLoaded = false;

  @override
  void initState() {
    super.initState();
    // Cargar el wallet cuando se inicializa el dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_walletLoaded) {
        _walletLoaded = true;
        monederoBloc.obtenerWallet().then((_) {
          // Después de cargar el wallet, cargar las tarjetas de NetPay si hay customerIdNetPay
          _cargarTarjetasNetPay();
        });
      } else {
        // Si el wallet ya está cargado, verificar si necesitamos cargar las tarjetas
        _cargarTarjetasNetPay();
      }
    });
  }

  void _cargarTarjetasNetPay() {
    final wallet = monederoBloc.wallet;
    if (wallet != null && wallet.customerIdNetPay != null && wallet.customerIdNetPay!.isNotEmpty) {
      netPayBloc.obtenerClienteNetPay(wallet.customerIdNetPay!);
    }
  }

  /// Método para actualizar los datos cuando el usuario hace pull-to-refresh
  Future<void> _onRefresh() async {
    try {
      // Actualizar los datos del wallet
      await monederoBloc.refreshWallet();
      // También recargar las tarjetas de NetPay si hay customerIdNetPay
      _cargarTarjetasNetPay();
      debugPrint('✅ Datos del dashboard actualizados correctamente');
    } catch (e) {
      debugPrint('❌ Error al actualizar los datos: $e');
      // El RefreshIndicator manejará el error automáticamente
      rethrow;
    }
  }

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
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFF205AA8),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Permite el pull-to-refresh incluso si el contenido no es scrollable
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
      ),
    );
  }

  Widget desktopView({required BuildContext context, required bool isDark}) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFF205AA8),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Permite el pull-to-refresh incluso si el contenido no es scrollable
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

          // Title dinámico - alineado con Monedero
          StreamBuilder<User?>(
            stream: authBloc.userStream,
            builder: (context, userSnapshot) {
              final user = userSnapshot.data ?? authBloc.currentUser;
              final nombreUsuario = user?.nombre ?? 'Usuario';

              return Text(
                "¡Hola, $nombreUsuario!",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),

          // Spacer to push avatar to the right
          Spacer(),

          // Profile avatar
          GestureDetector(
            onTap: () {
              // Navegar a perfil de usuario
              GoRouter.of(context).go(RoutesName.perfil);
            },
            child: StreamBuilder<User?>(
              stream: authBloc.userStream,
              builder: (context, userSnapshot) {
                final user = userSnapshot.data ?? authBloc.currentUser;
                return UserAvatar(
                  imageUrl: user?.fotoPerfil,
                  radius: 20,
                  backgroundColor:
                      isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  iconColor: isDark ? Colors.white : Colors.black,
                  iconSize: 24,
                );
              },
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
            const Spacer(),
            GestureDetector(
              onTap: () {
                _mostrarModalExtravio(context, isDark);
              },
              child: Text(
                "Extravío de monedero",
                style: TextStyle(
                  color: const Color(0xFFA6A4A4),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),

        // Main wallet card with gradient - usando StreamBuilder para obtener datos del wallet
        StreamBuilder<MonederoStatus>(
          stream: monederoBloc.walletStatusStream,
          initialData: monederoBloc.walletStatus,
          builder: (context, statusSnapshot) {
            final status = statusSnapshot.data ?? MonederoStatus.initial;

            return StreamBuilder<PasajeroWalletModel?>(
              stream: monederoBloc.walletStream,
              initialData: monederoBloc.wallet,
              builder: (context, walletSnapshot) {
                final wallet = walletSnapshot.data;

                // Loading state
                if (status == MonederoStatus.loading) {
                  return Container(
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
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                // Error state
                if (status == MonederoStatus.error) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.red[100],
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[700], size: 32),
                          const SizedBox(height: 8),
                          Text(
                            monederoBloc.walletErrorMessage ?? 'Error al cargar',
                            style: TextStyle(
                              color: Colors.red[900],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Loaded state o initial state (mostrar datos o valores por defecto)
                final saldoTotal = wallet?.saldoTotalFormateado ?? '\$0.00';
                final monederosTexto = wallet?.monederos ?? 'Sin monedero';

                return Container(
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
                      // Tipo de pasajero label (top right)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA6CE39).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFA6CE39), width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 4),
                              Text(
                                wallet?.nombreTipoPasajero ?? 'Estudiante',
                                style: const TextStyle(
                                  color: Color(0xFFA6CE39),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                saldoTotal,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
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
                                monederosTexto,
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
                );
              },
            );
          },
        ),
      ],
    );
  }

  // * Mostrar modal de tipo de viaje antes de generar QR
  void _mostrarModalTipoViaje(BuildContext context, bool isDark) {
    TipoViajeDialog.mostrar(
      context: context,
      isDark: isDark,
      onContinue: (bool esFamiliar, int? numeroPasajeros) {
        // * Continuar con el flujo actual (navegar a generar QR)
        GoRouter.of(context).go(RoutesName.pagoQR);
        // * Por ahora solo se captura, no se envía al API
        debugPrint('📋 Tipo de viaje: ${esFamiliar ? "Familiar" : "Individual"}');
        if (esFamiliar && numeroPasajeros != null) {
          debugPrint('👥 Número de pasajeros: $numeroPasajeros');
        }
      },
    );
  }

  void _mostrarModalExtravio(BuildContext context, bool isDark) {
    final wallet = monederoBloc.wallet;
    final numeroSerieMonedero = wallet?.monederos ?? 'N/A';
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return _ExtravioMonederoDialog(
          numeroSerieMonedero: numeroSerieMonedero,
          isDark: isDark,
        );
      },
    );
  }

  Widget _buildExpenseCard({bool isDark = true}) {
    final cardColor = isDark ? Colors.grey[800] : Colors.grey[100];
    final textColor = isDark ? Colors.white : Colors.black;

    return StreamBuilder<PasajeroWalletModel?>(
      stream: monederoBloc.walletStream,
      initialData: monederoBloc.wallet,
      builder: (context, walletSnapshot) {
        final wallet = walletSnapshot.data;
        final totalDebitos = wallet?.totalDebitosFormateado ?? '--';

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
                child: const Icon(
                  Icons.arrow_downward,
                  color: Color(0xFFFDB462), // Yellow
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Gasto último mes",
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                totalDebitos,
                style: TextStyle(
                  color: totalDebitos == '--'
                      ? Colors.grey[600]
                      : const Color(0xFFFDB462), // Yellow
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRechargeCard({bool isDark = true}) {
    final cardColor = isDark ? Colors.grey[800] : Colors.grey[100];
    final textColor = isDark ? Colors.white : Colors.black;

    return StreamBuilder<PasajeroWalletModel?>(
      stream: monederoBloc.walletStream,
      initialData: monederoBloc.wallet,
      builder: (context, walletSnapshot) {
        final wallet = walletSnapshot.data;
        final ultimaRecarga = wallet?.ultimaRecargaFormateada ?? '--';

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
                child: const Icon(
                  Icons.arrow_upward,
                  color: Color(0xFF205AA8), // Blue
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
                ultimaRecarga,
                style: TextStyle(
                  color: ultimaRecarga == '--'
                      ? Colors.grey[600]
                      : const Color(0xFF205AA8), // Blue
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFacturarButton(BuildContext context) {
    return FilledButton(
      onPressed: () {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: '¡En construcción!',
          text: 'Esta funcionalidad se encuentra en desarrollo.',
          confirmBtnText: 'Aceptar',
          confirmBtnColor: const Color(0xFF205AA8),
        );
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
                      // * Mostrar modal de tipo de viaje antes de navegar
                      _mostrarModalTipoViaje(context, isDark);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildGeneralCard(
                    context: context,
                    icon: Icons.bar_chart,
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
                  _buildMetodosPagoCard(
                    context: context,
                    isDark: isDark,
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

  Widget _buildMetodosPagoCard({
    required BuildContext context,
    required bool isDark,
  }) {
    final cardColor = isDark ? Colors.grey[800] : Colors.grey[100];
    final textColor = isDark ? Colors.white : Colors.black;
    const color = Color(0xFFA6CE39); // Green

    return GestureDetector(
      onTap: () {
        // Navigate to Payment Methods screen
        GoRouter.of(context).go(RoutesName.metodosPago);
      },
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
                  child: const Icon(
                    Icons.payment,
                    color: color,
                    size: 28,
                  ),
                ),
                // StreamBuilder para mostrar el número dinámico de tarjetas
                StreamBuilder<NetPayCustomerModel?>(
                  stream: netPayBloc.customerStream,
                  initialData: netPayBloc.currentCustomer,
                  builder: (context, snapshot) {
                    final customer = snapshot.data;
                    final cantidadTarjetas = customer?.paymentSources.length ?? 0;
                    return Text(
                      cantidadTarjetas.toString(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Métodos de Pago",
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
            StreamBuilder<User?>(
              stream: authBloc.userStream,
              builder: (context, userSnapshot) {
                final user = userSnapshot.data ?? authBloc.currentUser;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                  ),
                  child: Column(
                    children: [
                      // Profile image
                      UserAvatar(
                        imageUrl: user?.fotoPerfil,
                        radius: 50,
                        backgroundColor:
                            isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        iconColor: textColor,
                        iconSize: 50,
                      ),
                      const SizedBox(height: 16),
                      // Full name
                      Text(
                        user != null
                            ? '${user.nombre} ${user.apellidoPaterno}'
                            : 'Usuario',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Status
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA6CE39).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFA6CE39), width: 1.5),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle,
                                  color: Color(0xFFA6CE39), size: 14),
                              SizedBox(width: 4),
                              Text(
                                "Activo",
                                style: TextStyle(
                                  color: Color(0xFFA6CE39),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Menu options
            Expanded(
              child: StreamBuilder<User?>(
                stream: authBloc.userStream,
                builder: (context, userSnapshot) {
                  final user = userSnapshot.data ?? authBloc.currentUser;
                  final rolNombre = user?.rol?.nombre.toLowerCase() ?? '';
                  final isPasajero = rolNombre == 'pasajero';
                  final isCajero = rolNombre == 'cajero';
                  final isAdministrador = rolNombre == 'administrador';

                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Solo mostrar si NO es Cajero
                      if (!isCajero)
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
                      // Solo mostrar si NO es Cajero
                      if (!isCajero)
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
                      // Mostrar si NO es Pasajero (incluye Cajero y otros roles)
                      if (!isPasajero)
                        ListTile(
                          leading: Icon(Icons.point_of_sale, color: textColor),
                          title: Text(
                            "Punto de Venta",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            GoRouter.of(context).go(RoutesName.pos);
                          },
                        ),
                      // Solo mostrar si es Cajero o Administrador
                      if (isCajero || isAdministrador)
                        ListTile(
                          leading: Icon(Icons.credit_card, color: textColor),
                          title: Text(
                            "Monederos",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            GoRouter.of(context).go(RoutesName.monederos);
                          },
                        ),
                      // Mostrar si NO es Pasajero (incluye Cajero y otros roles)
                      if (!isPasajero)
                        ListTile(
                          leading: Icon(Icons.swap_horiz, color: textColor),
                          title: Text(
                            "Transacciones",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            GoRouter.of(context).go(RoutesName.transacciones);
                          },
                        ),
                      // Solo mostrar si NO es Cajero
                      if (!isCajero)
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
                      // Configuración visible para todos los roles
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
                      // Apariencia visible para todos los roles
                      ListTile(
                        leading: Icon(Icons.contrast, color: textColor),
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
                  );
                },
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
              onTap: () async {
                Navigator.pop(context);
                // Cerrar sesión usando AuthBloc
                await authBloc.logout();
                // Navigate to login page
                if (context.mounted) {
                  GoRouter.of(context).go(RoutesName.login);
                }
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
  bool _transaccionesLoaded = false;

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
    
    // Si el tab inicial es Registros, cargar transacciones
    if (widget.initialTabIndex == 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadTransacciones();
      });
    }
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
      
      // Cargar transacciones cuando se selecciona el tab de Registros
      if (_selectedTabIndex == 3 && !_transaccionesLoaded) {
        _loadTransacciones();
      } else if (_selectedTabIndex != 3) {
        // Resetear flag cuando se sale del tab de Registros
        // para recargar cuando se vuelva a entrar
        _transaccionesLoaded = false;
      }
    }
  }

  void _loadTransacciones() {
    if (!_transaccionesLoaded) {
      _transaccionesLoaded = true;
      monederoBloc.obtenerTransacciones();
    }
  }

  void _loadMoreTransacciones() {
    if (monederoBloc.hasMorePages && !monederoBloc.isLoadingMore) {
      monederoBloc.cargarMasTransacciones();
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
                    child: _selectedTabIndex == 3
                        ? _buildRegistrosContent(
                            scrollController: scrollController,
                            textColor: textColor,
                            isDark: isDark,
                          )
                        : SingleChildScrollView(
                            controller: scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_selectedTabIndex == 0) ...[
                                    // General section with charts
                                    _buildGeneralSection(textColor: textColor, isDark: isDark),
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
              // * Guardar el contexto antes de cerrar el bottom sheet
              final navigatorContext = context;
              Navigator.pop(context);
              // * Esperar un frame para que el bottom sheet se cierre completamente
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // * Verificar que el contexto aún esté montado
                if (!navigatorContext.mounted) return;
                
                // * Mostrar modal de tipo de viaje antes de navegar
                TipoViajeDialog.mostrar(
                  context: navigatorContext,
                  isDark: isDark,
                  onContinue: (bool esFamiliar, int? numeroPasajeros) {
                    debugPrint('📋 Tipo de viaje: ${esFamiliar ? "Familiar" : "Individual"}');
                    if (esFamiliar && numeroPasajeros != null) {
                      debugPrint('👥 Número de pasajeros: $numeroPasajeros');
                    }
                    // * Esperar otro frame para asegurar que el modal se cerró
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      // * Verificar que el contexto aún esté montado antes de navegar
                      if (navigatorContext.mounted) {
                        GoRouter.of(navigatorContext).go(RoutesName.pagoQR);
                      } else {
                        debugPrint('⚠️ Contexto no montado, usando navigator key');
                        // * Fallback: usar el navigator key global
                        final routerContext = app_routes.rootNavigatorKey.currentContext;
                        if (routerContext != null && routerContext.mounted) {
                          GoRouter.of(routerContext).go(RoutesName.pagoQR);
                        }
                      }
                    });
                  },
                );
              });
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

  Widget _buildRegistrosContent({
    required ScrollController scrollController,
    Color textColor = Colors.white,
    bool isDark = true,
  }) {
    // Usar el scrollController proporcionado por DraggableScrollableSheet
    // No debemos hacer dispose de este controller ya que es manejado por DraggableScrollableSheet

    return StreamBuilder<MonederoStatus>(
      stream: monederoBloc.transaccionesStatusStream,
      initialData: monederoBloc.transaccionesStatus,
      builder: (context, statusSnapshot) {
        final status = statusSnapshot.data ?? MonederoStatus.initial;

        return StreamBuilder<List<TransaccionModel>>(
          stream: monederoBloc.transaccionesStream,
          initialData: monederoBloc.transacciones,
          builder: (context, transaccionesSnapshot) {
            final transacciones = transaccionesSnapshot.data ?? [];

            return StreamBuilder<String?>(
              stream: monederoBloc.transaccionesErrorStream,
              initialData: monederoBloc.transaccionesErrorMessage,
              builder: (context, errorSnapshot) {
                final error = errorSnapshot.data;

                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (status == MonederoStatus.loading && transacciones.isEmpty)
                        // Loading state inicial
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  color: Color(0xFF205AA8),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Cargando transacciones...',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (error != null && transacciones.isEmpty)
                        // Error state
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error al cargar transacciones',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  error,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: () {
                                    _transaccionesLoaded = false;
                                    _loadTransacciones();
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF205AA8),
                                  ),
                                  child: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (transacciones.isEmpty)
                        // Empty state
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  color: Colors.grey[400],
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay transacciones disponibles',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tus transacciones aparecerán aquí',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        // Success state - Lista de transacciones
                        Expanded(
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (scrollInfo is ScrollEndNotification) {
                                if (scrollController.position.pixels >=
                                    scrollController.position.maxScrollExtent - 200) {
                                  _loadMoreTransacciones();
                                }
                              }
                              return false;
                            },
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: transacciones.length +
                                  (monederoBloc.hasMorePages ? 1 : 0),
                              itemBuilder: (context, index) {
                              if (index >= transacciones.length) {
                                // Mostrar indicador de carga al final
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: monederoBloc.isLoadingMore
                                        ? const CircularProgressIndicator(
                                            color: Color(0xFF205AA8),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                );
                              }

                              final transaccion = transacciones[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildTransaccionItem(
                                  transaccion: transaccion,
                                  textColor: textColor,
                                  isDark: isDark,
                                ),
                              );
                            },
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
      },
    );
  }

  Widget _buildOperacionesSection(
      {Color textColor = Colors.white, bool isDark = true}) {
    // Este método ya no se usa, pero se mantiene por compatibilidad
    return const SizedBox.shrink();
  }

  Widget _buildTransaccionItem({
    required TransaccionModel transaccion,
    Color textColor = Colors.white,
    bool isDark = true,
  }) {
    // Determinar icono y color según el tipo de transacción
    IconData iconData;
    Color iconColor;
    final isRecarga = transaccion.esRecarga;

    if (isRecarga) {
      iconData = Icons.attach_money;
      iconColor = const Color(0xFFA6CE39); // Green para recargas
    } else {
      // Débito: usar icono QR si es un débito por QR, sino bus
      iconData = Icons.qr_code;
      iconColor = const Color(0xFF205AA8); // Blue para débitos
    }

    // Formatear fecha y hora
    String fechaHoraTexto = 'N/A';
    if (transaccion.fechaHora != null) {
      DateTime fecha = transaccion.fechaHora!;
      
      // Extraer los componentes de fecha y hora (usar UTC si la fecha es UTC)
      int year, month, day, hour, minute;
      
      if (fecha.isUtc) {
        // Usar componentes UTC directamente
        year = fecha.year;
        month = fecha.month;
        day = fecha.day;
        hour = fecha.hour;
        minute = fecha.minute;
      } else {
        // Convertir a local y usar esos componentes
        final fechaLocal = fecha.toLocal();
        year = fechaLocal.year;
        month = fechaLocal.month;
        day = fechaLocal.day;
        hour = fechaLocal.hour;
        minute = fechaLocal.minute;
      }
      
      // Formatear manualmente para evitar problemas de zona horaria
      final hora12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final amPm = hour >= 12 ? 'PM' : 'AM';
      
      fechaHoraTexto = '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year ${hora12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm';
    }

    // Formatear monto con signo
    String montoTexto = 'N/A';
    if (transaccion.monto != null) {
      final formatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
      final montoFormateado = formatter.format(transaccion.monto);
      // Agregar signo negativo para débitos, positivo para recargas
      montoTexto = isRecarga ? montoFormateado : '-$montoFormateado';
    }

    // Descripción: número de monedero o tipo de transacción
    final description = transaccion.numeroSerieMonedero ?? 'N/A';
    final tipoTexto = isRecarga ? 'Recarga' : 'Débito';

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
                  fechaHoraTexto,
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
                montoTexto,
                style: TextStyle(
                  color: isRecarga
                      ? const Color(0xFFA6CE39) // Verde para recargas
                      : Colors.red, // Rojo para débitos
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tipoTexto,
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

  Widget _buildGeneralSection({Color textColor = Colors.white, bool isDark = true}) {
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
          child: _buildStackedBarChart(textColor: textColor, isDark: isDark),
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
          child: _buildGroupedBarChart(textColor: textColor, isDark: isDark),
        ),
      ],
    );
  }

  Widget _buildStackedBarChart({Color textColor = Colors.white, bool isDark = true}) {
    return StreamBuilder<PasajeroWalletModel?>(
      stream: monederoBloc.walletStream,
      initialData: monederoBloc.wallet,
      builder: (context, snapshot) {
        final wallet = snapshot.data;
        
        // Si no hay wallet o datos, mostrar gráfica vacía
        if (wallet == null || wallet.gastosYRecargasPorMes.isEmpty) {
          return Center(
            child: Text(
              'No hay datos disponibles',
              style: TextStyle(color: textColor),
            ),
          );
        }

        // Mapear los datos del wallet a MonthlyData
        final monthlyData = wallet.gastosYRecargasPorMes.map((item) {
          final mesNombres = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
                             'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
          return MonthlyData(
            mesNombres[item.mes - 1], 
            item.totalGastado, 
            item.totalRecargado
          );
        }).toList();

        // Encontrar el valor máximo para escalar el eje Y
        // El maxY debe ser el toY máximo, que es expenses + recharges
        double maxY = 0;
        for (var data in monthlyData) {
          final total = data.expenses + data.recharges;
          if (total > maxY) maxY = total;
        }
        // Si no hay gastos (solo recargas), no añadir margen para mostrar el valor exacto
        // Si hay gastos, añadir un margen pequeño para mejor visualización
        if (maxY > 0) {
          final hasExpenses = monthlyData.any((data) => data.expenses > 0);
          if (hasExpenses) {
            maxY = (maxY * 1.1).ceilToDouble(); // 10% de margen si hay gastos
          } else {
            // Sin gastos, mostrar el valor exacto o un margen mínimo
            maxY = maxY.ceilToDouble();
          }
        }
        
        // Asegurar que maxY sea al menos 1 para evitar divisiones por cero
        if (maxY == 0) maxY = 1.0;

        // Calcular horizontalInterval asegurándonos de que no sea cero
        final horizontalInterval = maxY > 0 ? maxY / 5 : 1.0;

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => Colors.grey[800]!,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final data = monthlyData[group.x.toInt()];
                  double value;
                  String label;
                  
                  if (rodIndex == 0) {
                    // Primera barra: Gastos
                    value = data.expenses;
                    label = 'Gastos';
                  } else {
                    // Segunda barra: Recargas (mostrar solo el valor de recargas, no el total acumulado)
                    value = data.recharges;
                    label = 'Recargas';
                  }
                  
                  // Formatear: si es menor a 1000, mostrar valor real sin "k"
                  final formattedValue = value < 1000 
                      ? value.toStringAsFixed(2)
                      : '${(value / 1000).toStringAsFixed(1)}k';
                  
                  return BarTooltipItem(
                    '$label\n\$$formattedValue',
                    TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < monthlyData.length) {
                      return Text(
                        monthlyData[value.toInt()].month,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }
                    return const Text('');
                  },
                  reservedSize: 30,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    final interval = horizontalInterval;
                    final diff = ((value / interval).roundToDouble() * interval - value);
                    if ((diff < 0 ? -diff : diff) < 0.01 || value == 0) {
                      // Formatear: si es menor a 1000, mostrar valor real sin "k"
                      final formattedValue = value < 1000 
                          ? value.toStringAsFixed(0)
                          : '${(value / 1000).toStringAsFixed(0)}k';
                      return Text(
                        '\$$formattedValue',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 10,
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            barGroups: monthlyData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              return BarChartGroupData(
                x: index,
                groupVertically: true,
                barRods: [
                  BarChartRodData(
                    toY: data.expenses,
                    color: const Color(0xFFFDB462), // Yellow/Orange for Gastos
                    width: 22,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(0),
                    ),
                  ),
                  BarChartRodData(
                    toY: data.expenses + data.recharges,
                    color: const Color(0xFFA6CE39), // Green for Recargas
                    width: 22,
                    fromY: data.expenses,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(0),
                    ),
                  ),
                ],
              );
            }).toList(),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: horizontalInterval,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: textColor.withOpacity(0.1),
                  strokeWidth: 1,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupedBarChart({Color textColor = Colors.white, bool isDark = true}) {
    return StreamBuilder<PasajeroWalletModel?>(
      stream: monederoBloc.walletStream,
      initialData: monederoBloc.wallet,
      builder: (context, snapshot) {
        final wallet = snapshot.data;
        
        // Si no hay wallet o datos, mostrar gráfica vacía
        if (wallet == null || wallet.gastosPorMes.isEmpty) {
          return Center(
            child: Text(
              'No hay datos disponibles',
              style: TextStyle(color: textColor),
            ),
          );
        }

        // Mapear los datos del wallet
        final expenseData = wallet.gastosPorMes.map((item) {
          final mesNombres = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
                             'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
          return ExpenseCategory(
            mesNombres[item.mes - 1], 
            item.total, 
            0, 
            0
          );
        }).toList();

        // Encontrar el valor máximo para escalar el eje Y
        double maxY = 0;
        for (var data in expenseData) {
          if (data.category1 > maxY) maxY = data.category1;
        }
        maxY = (maxY * 1.2).ceilToDouble(); // Añadir 20% de margen
        
        // Asegurar que maxY sea al menos 1 para evitar divisiones por cero
        if (maxY == 0) maxY = 1.0;

        // Calcular horizontalInterval asegurándonos de que no sea cero
        final horizontalInterval = maxY > 0 ? maxY / 5 : 1.0;

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => Colors.grey[800]!,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  double value = rod.toY;
                  
                  // Formatear: si es menor a 1000, mostrar valor real sin "k"
                  final formattedValue = value < 1000 
                      ? value.toStringAsFixed(2)
                      : '${(value / 1000).toStringAsFixed(1)}k';
                  
                  return BarTooltipItem(
                    'Gastos\n\$$formattedValue',
                    TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
              touchCallback: (FlTouchEvent event, barTouchResponse) {
                // Opcional: manejar eventos de toque
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < expenseData.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          expenseData[value.toInt()].month,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                  reservedSize: 30,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    final interval = horizontalInterval;
                    final diff = ((value / interval).roundToDouble() * interval - value);
                    if ((diff < 0 ? -diff : diff) < 0.01 || value == 0) {
                      // Formatear: si es menor a 1000, mostrar valor real sin "k"
                      final formattedValue = value < 1000 
                          ? value.toStringAsFixed(0)
                          : '${(value / 1000).toStringAsFixed(0)}k';
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          '\$$formattedValue',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            barGroups: expenseData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              return BarChartGroupData(
                x: index,
                groupVertically: false,
                barsSpace: 8,
                barRods: [
                  BarChartRodData(
                    toY: data.category1,
                    color: const Color(0xFFFDB462), // Yellow/Orange for Gastos
                    width: 22,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              );
            }).toList(),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: horizontalInterval,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: textColor.withOpacity(0.1),
                  strokeWidth: 1,
                );
              },
            ),
          ),
        );
      },
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
  String? _selectedTheme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inicializar el tema seleccionado basándose en el tema actual
    if (_selectedTheme == null) {
      _updateSelectedThemeFromCurrent();
    }
  }

  void _updateSelectedThemeFromCurrent() {
    final isDarkMode = themeBloc.isDarkMode;
    
    // Verificar si el tema actual coincide con el brightness del sistema
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final systemIsDark = systemBrightness == Brightness.dark;
    
    // Si el modo actual coincide con el sistema, está en modo "Sistema"
    // Si no coincide, el usuario seleccionó manualmente "Claro" o "Oscuro"
    if (isDarkMode == systemIsDark) {
      _selectedTheme = 'Sistema';
    } else if (isDarkMode) {
      _selectedTheme = 'Oscuro';
    } else {
      _selectedTheme = 'Claro';
    }
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
        
        // Actualizar el tema seleccionado cuando el stream emita un nuevo valor
        if (snapshot.hasData && _selectedTheme == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _updateSelectedThemeFromCurrent();
            }
          });
        }

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
                groupValue: _selectedTheme ?? 'Sistema',
                onChanged: (String? newValue) {
                  if (newValue == null) return;
                  setState(() {
                    _selectedTheme = newValue;
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
                        Flexible(
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
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
                        Flexible(
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
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

class _ExtravioMonederoDialog extends StatefulWidget {
  final String numeroSerieMonedero;
  final bool isDark;

  const _ExtravioMonederoDialog({
    required this.numeroSerieMonedero,
    required this.isDark,
  });

  @override
  State<_ExtravioMonederoDialog> createState() => _ExtravioMonederoDialogState();
}

class _ExtravioMonederoDialogState extends State<_ExtravioMonederoDialog> {
  final TextEditingController _nuevoMonederoController = TextEditingController();
  bool _isSubmitting = false;

  bool _esNumeroSerieValido(String value) {
    final regex = RegExp(r'^[A-Za-z0-9-]{4,}$');
    return regex.hasMatch(value);
  }

  @override
  void dispose() {
    _nuevoMonederoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isDark ? Colors.grey[800] : Colors.grey[100];
    final textColor = widget.isDark ? Colors.white : Colors.black;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icono de advertencia
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFDB462).withValues(alpha: 0.2),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFDB462), // Yellow
                  size: 36,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Título
            Text(
              "¡Reporte de Extravío!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Mensaje informativo
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: "Se marcará como extraviado tu actual monedero: "),
                  TextSpan(
                    text: widget.numeroSerieMonedero,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: "."),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Instrucción
            Text(
              "Ingresa el número de tu nuevo monedero",
              style: TextStyle(
                fontSize: 14,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Campo de entrada
            TextField(
              controller: _nuevoMonederoController,
              style: TextStyle(
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: "Nuevo monedero",
                hintStyle: TextStyle(
                  color: widget.isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
                filled: true,
                fillColor: widget.isDark ? Colors.grey[700] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botones
            Row(
              children: [
                // Botón "Reportar" (azul)
                Expanded(
                  child: FilledButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            final nuevoMonedero =
                                _nuevoMonederoController.text.trim();

                            if (nuevoMonedero.isEmpty) {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.warning,
                                title: 'Campo requerido',
                                text: 'Ingresa el número de serie del monedero.',
                                confirmBtnText: 'Aceptar',
                                confirmBtnColor: const Color(0xFF205AA8),
                              );
                              return;
                            }

                            if (!_esNumeroSerieValido(nuevoMonedero)) {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.warning,
                                title: 'Formato inválido',
                                text:
                                    'El número de serie no tiene un formato válido.',
                                confirmBtnText: 'Aceptar',
                                confirmBtnColor: const Color(0xFF205AA8),
                              );
                              return;
                            }

                            setState(() {
                              _isSubmitting = true;
                            });

                            final result = await extravioBloc.reportarExtravio(
                              numeroSerie: nuevoMonedero,
                            );

                            if (!mounted) return;

                            setState(() {
                              _isSubmitting = false;
                            });

                            if (result.isSuccess) {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.success,
                                title: 'Reporte enviado',
                                text: result.data?.message ??
                                    'El extravío fue reportado correctamente.',
                                confirmBtnText: 'Aceptar',
                                confirmBtnColor: const Color(0xFF205AA8),
                                onConfirmBtnTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                              );
                            } else {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.error,
                                title: 'Error',
                                text: result.errorMessage ??
                                    'No se pudo reportar el extravío.',
                                confirmBtnText: 'Aceptar',
                                confirmBtnColor: const Color(0xFF205AA8),
                              );
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF205AA8), // Blue
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Reportar",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Botón "Cancelar"
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: widget.isDark ? Colors.grey[700] : Colors.white,
                      side: BorderSide(
                        color: widget.isDark ? Colors.grey[600]! : Colors.grey[300]!,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Cancelar",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// * Modal para seleccionar tipo de viaje (Familiar / Individual)
// * Clase pública para poder ser reutilizada desde otros archivos
class TipoViajeDialog extends StatefulWidget {
  final bool isDark;
  final Function(bool esFamiliar, int? numeroPasajeros) onContinue;

  const TipoViajeDialog({
    required this.isDark,
    required this.onContinue,
  });

  /// * Método estático para mostrar el modal de forma reutilizable
  static void mostrar({
    required BuildContext context,
    required bool isDark,
    required Function(bool esFamiliar, int? numeroPasajeros) onContinue,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return TipoViajeDialog(
          isDark: isDark,
          onContinue: (bool esFamiliar, int? numeroPasajeros) {
            // * Cerrar el modal primero
            Navigator.of(dialogContext).pop();
            // * Ejecutar el callback inmediatamente después de cerrar
            // * El callback manejará la navegación con el contexto correcto
            onContinue(esFamiliar, numeroPasajeros);
          },
        );
      },
    );
  }

  @override
  State<TipoViajeDialog> createState() => _TipoViajeDialogState();
}

class _TipoViajeDialogState extends State<TipoViajeDialog> {
  bool? _esFamiliar; // null = no seleccionado, true = sí, false = no
  final TextEditingController _numeroPasajerosController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _numeroPasajerosController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    if (_esFamiliar == null) return false;
    if (_esFamiliar == true) {
      // Si es familiar, debe tener número de pasajeros válido
      final numero = int.tryParse(_numeroPasajerosController.text.trim());
      return numero != null && numero >= 1;
    }
    // Si no es familiar, solo necesita estar seleccionado
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isDark ? Colors.grey[800] : Colors.grey[100];
    final textColor = widget.isDark ? Colors.white : Colors.black;
    final hintTextColor = widget.isDark ? Colors.grey[400] : Colors.grey[600];
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Icono
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF205AA8).withValues(alpha: 0.2),
                  ),
                  child: const Icon(
                    Icons.qr_code,
                    color: Color(0xFF205AA8),
                    size: 36,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Título
              Text(
                "Generar Código QR",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Pregunta
              Text(
                "¿El viaje es familiar?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // Radio buttons
              _buildRadioOption(
                value: true,
                label: "Sí",
                textColor: textColor,
                isDark: widget.isDark,
              ),
              const SizedBox(height: 12),
              _buildRadioOption(
                value: false,
                label: "No",
                textColor: textColor,
                isDark: widget.isDark,
              ),
              
              // Campo de número de pasajeros (solo si es familiar)
              if (_esFamiliar == true) ...[
                const SizedBox(height: 24),
                Text(
                  "Número de pasajeros",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _numeroPasajerosController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: "Ej: 2",
                    hintStyle: TextStyle(color: hintTextColor),
                    filled: true,
                    fillColor: widget.isDark ? Colors.grey[700] : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el número de pasajeros';
                    }
                    final numero = int.tryParse(value.trim());
                    if (numero == null || numero < 1) {
                      return 'Debe ser al menos 1';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Botones
              Row(
                children: [
                  // Botón "Cancelar"
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: widget.isDark ? Colors.grey[700] : Colors.white,
                        side: BorderSide(
                          color: widget.isDark ? Colors.grey[600]! : Colors.grey[300]!,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Cancelar",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Botón de acción (Pago Familiar o Pago individual)
                  Expanded(
                    child: FilledButton(
                      onPressed: _isFormValid()
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                final numeroPasajeros = _esFamiliar == true
                                    ? int.tryParse(_numeroPasajerosController.text.trim())
                                    : null;
                                widget.onContinue(_esFamiliar == true, numeroPasajeros);
                              }
                            }
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF205AA8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _esFamiliar == true ? "Pago Familiar" : "Pago individual",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required bool value,
    required String label,
    required Color textColor,
    required bool isDark,
  }) {
    final isSelected = _esFamiliar == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _esFamiliar = value;
          if (value == false) {
            // Limpiar el campo si se selecciona "No"
            _numeroPasajerosController.clear();
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF205AA8).withValues(alpha: 0.1)
              : (isDark ? Colors.grey[700] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF205AA8)
                : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio button visual
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF205AA8)
                      : (isDark ? Colors.grey[500]! : Colors.grey[400]!),
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFF205AA8).withValues(alpha: 0.2)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF205AA8),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
