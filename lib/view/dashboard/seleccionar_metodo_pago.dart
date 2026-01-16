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
  String? _selectedCard; // Selected card ID (token)

  @override
  void initState() {
    super.initState();
    // Cargar wallet si no está cargado y luego cargar las tarjetas de NetPay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wallet = monederoBloc.wallet;
      if (wallet == null) {
        monederoBloc.obtenerWallet().then((_) {
          _cargarTarjetasNetPay();
        });
      } else {
        _cargarTarjetasNetPay();
      }
    });
  }

  void _cargarTarjetasNetPay() {
    final wallet = monederoBloc.wallet;
    if (wallet != null && wallet.customerIdNetPay != null && wallet.customerIdNetPay!.isNotEmpty) {
      // Usar caché si está disponible, no forzar recarga
      netPayBloc.obtenerClienteNetPay(wallet.customerIdNetPay!, forceRefresh: false);
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

        // Obtener el padding del sistema antes de que se remueva
        final systemPaddingTop = MediaQuery.of(context).viewPadding.top;

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
                  mobile: mobileView(
                      context: context,
                      isDark: isDark,
                      textColor: textColor,
                      systemPaddingTop: systemPaddingTop),
                  desktop: desktopView(
                      context: context,
                      isDark: isDark,
                      textColor: textColor,
                      systemPaddingTop: systemPaddingTop),
                  tablet: mobileView(
                      context: context,
                      isDark: isDark,
                      textColor: textColor,
                      systemPaddingTop: systemPaddingTop),
                ),
              ),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(context, isDark),
          ),
        );
      },
    );
  }

  Widget mobileView(
      {required BuildContext context,
      required bool isDark,
      required Color textColor,
      required double systemPaddingTop}) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                _buildHeader(context,
                    textColor: textColor,
                    isDark: isDark,
                    systemPaddingTop: systemPaddingTop),
                // Content
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                      const SizedBox(height: 16.0),
                      // Commission text - centered
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
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
                      const SizedBox(height: 100.0), // Espacio para el botón fijo
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Continuar button - fijo en la parte inferior
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          width: double.infinity,
          child: FilledButton(
            onPressed: _selectedCard != null
                ? () {
                    final amount = widget.amount ?? '50';
                    GoRouter.of(context).go(
                      RoutesName.resumen,
                      extra: {
                        'amount': amount,
                        'selectedCardToken': _selectedCard!,
                      },
                    );
                  }
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: _selectedCard != null
                  ? const Color(0xFF205AA8) // Blue
                  : Colors.grey[400], // Disabled
              disabledBackgroundColor: Colors.grey[400],
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
    );
  }

  Widget desktopView(
      {required BuildContext context,
      required bool isDark,
      required Color textColor,
      required double systemPaddingTop}) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                _buildHeader(context,
                    textColor: textColor,
                    isDark: isDark,
                    systemPaddingTop: systemPaddingTop),
                // Content
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
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
                        const SizedBox(height: 16.0),
                        // Commission text - centered
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
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
                        const SizedBox(height: 100.0), // Espacio para el botón fijo
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Continuar button - fijo en la parte inferior
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
          constraints: const BoxConstraints(maxWidth: 1200),
          width: double.infinity,
          child: FilledButton(
            onPressed: _selectedCard != null
                ? () {
                    final amount = widget.amount ?? '50';
                    GoRouter.of(context).go(
                      RoutesName.resumen,
                      extra: {
                        'amount': amount,
                        'selectedCardToken': _selectedCard!,
                      },
                    );
                  }
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: _selectedCard != null
                  ? const Color(0xFF205AA8) // Blue
                  : Colors.grey[400], // Disabled
              disabledBackgroundColor: Colors.grey[400],
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
    );
  }

  Widget _buildHeader(BuildContext context,
      {Color textColor = Colors.white,
      bool isDark = true,
      required double systemPaddingTop}) {
    // Usar el padding del sistema que se obtuvo antes de MediaQuery.removePadding
    // Asegurar que haya suficiente espacio para el status bar
    final safePadding = systemPaddingTop > 0
        ? systemPaddingTop
        : 44.0; // Fallback para dispositivos sin notch
    return Container(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: safePadding + 16.0,
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
          // Profile avatar - dinámico
          GestureDetector(
            onTap: () {
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
                  iconColor: textColor,
                  iconSize: 24,
                );
              },
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
              Image.network(
                'https://dashcamsys.s3.us-east-2.amazonaws.com/imagenes/metodos.png',
                width: 120,
                height: 40,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 120,
                    height: 40,
                    color: Colors.transparent,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading image from AWS S3: $error');
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

          // Card selection buttons - dinámicos desde NetPay
          StreamBuilder<NetPayStatus>(
            stream: netPayBloc.statusStream,
            initialData: netPayBloc.currentStatus,
            builder: (context, statusSnapshot) {
              final status = statusSnapshot.data ?? NetPayStatus.idle;
              
              // Mostrar loader mientras se cargan las tarjetas
              if (status == NetPayStatus.loading) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF205AA8),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Cargando tarjetas...",
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return StreamBuilder<NetPayCustomerModel?>(
                stream: netPayBloc.customerStream,
                initialData: netPayBloc.currentCustomer,
                builder: (context, snapshot) {
                  final customer = snapshot.data;
                  final paymentSources = customer?.paymentSources ?? [];
                  
                  // Mostrar TODAS las tarjetas dinámicamente
                  if (paymentSources.isEmpty) {
                    // Si no hay tarjetas, mostrar mensaje
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.credit_card,
                              size: 64,
                              color: textColor.withOpacity(0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No tienes tarjetas registradas",
                              style: TextStyle(
                                color: textColor.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  // Seleccionar automáticamente la primera tarjeta si ninguna está seleccionada
                  if (_selectedCard == null && paymentSources.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _selectedCard = paymentSources.first.card.token;
                        });
                      }
                    });
                  }
                  
                  // Mostrar todas las tarjetas dinámicamente, 2 por fila
                  return Column(
                    children: [
                      // Crear filas de 2 tarjetas cada una
                      ...List.generate(
                        (paymentSources.length / 2).ceil(),
                        (rowIndex) {
                          final startIndex = rowIndex * 2;
                          final endIndex = (startIndex + 2 < paymentSources.length) 
                              ? startIndex + 2 
                              : paymentSources.length;
                          
                          // Obtener las tarjetas de esta fila
                          final tarjetasFila = paymentSources.sublist(startIndex, endIndex);
                          
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: rowIndex < ((paymentSources.length / 2).ceil() - 1) 
                                  ? 12.0 
                                  : 0,
                            ),
                            child: Row(
                              children: [
                                // Primera tarjeta de la fila
                                Expanded(
                                  child: _buildCardButton(
                                    cardNumber: tarjetasFila[0].card.lastFourDigits,
                                    isSelected: _selectedCard == tarjetasFila[0].card.token,
                                    isDark: isDark,
                                    textColor: textColor,
                                    onTap: () {
                                      setState(() {
                                        _selectedCard = tarjetasFila[0].card.token;
                                      });
                                    },
                                  ),
                                ),
                                // Segunda tarjeta de la fila (si existe)
                                if (tarjetasFila.length > 1) ...[
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: _buildCardButton(
                                      cardNumber: tarjetasFila[1].card.lastFourDigits,
                                      isSelected: _selectedCard == tarjetasFila[1].card.token,
                                      isDark: isDark,
                                      textColor: textColor,
                                      onTap: () {
                                        setState(() {
                                          _selectedCard = tarjetasFila[1].card.token;
                                        });
                                      },
                                    ),
                                  ),
                                ] else
                                  // Si solo hay una tarjeta en la última fila, agregar un espacio para mantener el layout
                                  const Expanded(child: SizedBox()),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
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
            // Mostrar imagen para NetPay, texto para los demás
            title == "NetPay"
                ? SizedBox(
                    width: 50,
                    height: 24,
                    child: Image.asset(
                      'assets/images/netpay_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Error loading NetPay logo: $error');
                        return Text(
                          title,
                          style: TextStyle(
                            color: Colors.blue[300],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  )
                : Text(
                    title,
                    style: TextStyle(
                      color: title == "PayPal" ? Colors.blue : textColor,
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
