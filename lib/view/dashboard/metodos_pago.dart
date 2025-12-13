// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'dashboard.dart';
import 'package:flutter/services.dart';

class MetodosPagoPage extends StatefulWidget {
  const MetodosPagoPage({super.key});

  @override
  State<MetodosPagoPage> createState() => _MetodosPagoPageState();
}

class _MetodosPagoPageState extends State<MetodosPagoPage> {
  late List<TarjetaPago> _tarjetas;

  @override
  void initState() {
    super.initState();
    _tarjetas = List.from(TarjetasPagoData.tarjetas);
  }

  void _eliminarTarjetaPorCardNumber(String cardNumber) {
    setState(() {
      final index = _tarjetas.indexWhere((t) => t.cardNumber == cardNumber);
      if (index != -1) {
        _tarjetas.removeAt(index);
        // También eliminar de la lista estática usando el mismo índice
        final staticIndex = TarjetasPagoData.tarjetas.indexWhere((t) => t.cardNumber == cardNumber);
        if (staticIndex != -1) {
          TarjetasPagoData.eliminarTarjeta(staticIndex);
        }
      }
    });
  }

  Future<bool?> _mostrarDialogoConfirmacion(BuildContext context, String cardNumber) async {
    final isDark = themeBloc.isDarkMode;
    final backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Confirmar eliminación',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '¿Estás seguro de eliminar esta tarjeta?',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'No, cancelar',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF205AA8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Si, confirmar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                              // Section title
                              Text(
                                "Mis tarjetas",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Lista dinámica de tarjetas con swipe para eliminar
                              ..._tarjetas
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final tarjeta = entry.value;
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index < _tarjetas.length - 1 ? 16 : 0,
                                  ),
                                  child: Dismissible(
                                    key: Key('tarjeta_${tarjeta.cardNumber}'),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20.0),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                    confirmDismiss: (direction) async {
                                      final result = await _mostrarDialogoConfirmacion(context, tarjeta.cardNumber);
                                      return result ?? false;
                                    },
                                    onDismissed: (direction) {
                                      _eliminarTarjetaPorCardNumber(tarjeta.cardNumber);
                                    },
                                    child: _buildCard(
                                      cardNumber: tarjeta.cardNumber,
                                      cvv: tarjeta.cvv,
                                      cardholderName: tarjeta.cardholderName,
                                      gradientColors: tarjeta.gradientColors,
                                      textColor: tarjeta.textColor,
                                      cardType: tarjeta.cardType,
                                    ),
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 32),
                              // Add card button
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () {
                                    // Navigate to Nueva Tarjeta screen
                                    GoRouter.of(context)
                                        .go(RoutesName.nuevaTarjeta);
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFA6CE39), // Lime green
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    "Agregar tarjeta",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
                  // Section title
                  Text(
                    "Mis tarjetas",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Lista dinámica de tarjetas con swipe para eliminar
                  ..._tarjetas
                      .asMap()
                      .entries
                      .map((entry) {
                    final index = entry.key;
                    final tarjeta = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < _tarjetas.length - 1 ? 16 : 0,
                      ),
                      child: Dismissible(
                        key: Key('tarjeta_${tarjeta.cardNumber}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          final result = await _mostrarDialogoConfirmacion(context, tarjeta.cardNumber);
                          return result ?? false;
                        },
                        onDismissed: (direction) {
                          _eliminarTarjetaPorCardNumber(tarjeta.cardNumber);
                        },
                        child: _buildCard(
                          cardNumber: tarjeta.cardNumber,
                          cvv: tarjeta.cvv,
                          cardholderName: tarjeta.cardholderName,
                          gradientColors: tarjeta.gradientColors,
                          textColor: tarjeta.textColor,
                          cardType: tarjeta.cardType,
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 32),
                  // Add card button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        // Navigate to Nueva Tarjeta screen
                        GoRouter.of(context)
                            .go(RoutesName.nuevaTarjeta);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFA6CE39), // Lime green
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Agregar tarjeta",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () {
              if (GoRouter.of(context).canPop()) {
                GoRouter.of(context).pop();
              } else {
                GoRouter.of(context).go(RoutesName.perfil); // Fallback
              }
            },
          ),
          // Title
          Expanded(
            child: Text(
              "Métodos de pago",
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
                final textColor = isDark ? Colors.white : Colors.black;
                return UserAvatar(
                  imageUrl: user?.fotoPerfil,
                  radius: 20,
                  backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
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

  Widget _buildCard({
    required String cardNumber,
    required String cvv,
    required String cardholderName,
    required List<Color> gradientColors,
    required Color textColor,
    required String cardType,
  }) {
    return Container(
      width:
          double.infinity, // Ocupa todo el ancho disponible, igual que el botón
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Stack(
        children: [
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Card number
              Text(
                cardNumber,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              // CVV and Cardholder name
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cvv,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cardholderName,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Card logo (bottom right)
          Positioned(
            bottom: 24,
            right: 24,
            child: _buildCardLogo(cardType),
          ),
        ],
      ),
    );
  }

  Widget _buildCardLogo(String cardType) {
    if (cardType == 'mastercard') {
      // MasterCard logo from assets
      return SizedBox(
        width: 60,
        height: 40,
        child: Image.asset(
          'assets/images/master.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Mostrar un placeholder si hay error
            debugPrint('Error loading master.png: $error');
            return Container(
              width: 60,
              height: 40,
              color: Colors.white.withOpacity(0.2),
              child:
                  const Icon(Icons.credit_card, color: Colors.white, size: 24),
            );
          },
        ),
      );
    } else if (cardType == 'visa') {
      // Visa logo from assets
      return SizedBox(
        width: 60,
        height: 40,
        child: Image.asset(
          'assets/images/visa.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Mostrar un placeholder si hay error
            debugPrint('Error loading visa.png: $error');
            return Container(
              width: 40,
              height: 20,
              color: Colors.white.withOpacity(0.2),
              child:
                  const Icon(Icons.credit_card, color: Colors.white, size: 24),
            );
          },
        ),
      );
    }
    return const SizedBox.shrink();
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
          currentIndex: 2, // Configuración is selected
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
            GoRouter.of(context).go(RoutesName.dashboard);
          } else if (index == 1) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const MonederoBottomSheet(),
            );
          } else if (index == 2) {
            GoRouter.of(context).go(RoutesName.perfil);
          }
        },
      ),
      ),
    );
  }
}
