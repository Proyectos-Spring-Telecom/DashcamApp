// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:flutter/services.dart';
import 'package:dashboardpro/controller/auth_bloc.dart';
import 'package:dashboardpro/model/auth/user.dart';

// * UPDATE: Página para generar y mostrar código QR de pago
class PagoQRPage extends StatefulWidget {
  final int? numeroPasajes; // * UPDATE: Recibir numeroPasajes desde GoRouter

  const PagoQRPage({super.key, this.numeroPasajes});

  @override
  State<PagoQRPage> createState() => _PagoQRPageState();
}

class _PagoQRPageState extends State<PagoQRPage> {
  bool _qrLoaded = false;

  @override
  void initState() {
    super.initState();
    // * UPDATE: Cargar el QR cuando se inicializa la pantalla con numeroPasajes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_qrLoaded) {
        _qrLoaded = true;
        // * IMPORTANT: Usar numeroPasajes recibido o 1 por defecto (pago individual)
        final numeroPasajes = widget.numeroPasajes ?? 1;
        monederoBloc.obtenerQrSaldo(numeroPasajes: numeroPasajes);
      }
    });
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
                  mobile: mobileWidget(context: context, isDark: isDark, textColor: textColor),
                  desktop: desktopWidget(context: context, isDark: isDark, textColor: textColor),
                  tablet: mobileWidget(context: context, isDark: isDark, textColor: textColor),
                ),
              ),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(context, isDark),
          ),
        );
      },
    );
  }

  Widget mobileWidget({required BuildContext context, required bool isDark, required Color textColor}) {
    return Column(
      children: [
        // Header
        _buildHeader(context, textColor: textColor, isDark: isDark),
        
        // Content - centered
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // ¡Código Listo! text with underline
                  Column(
                    children: [
                      Text(
                        "¡Código Listo!",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 100,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFF205AA8), // Blue
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Instructions text
                  Text(
                    "Escanea este código QR para completar tu pago.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // QR Code container - centered
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: _buildQRCode(isDark: isDark, textColor: textColor),
                    ),
                  ),
                  
                  // Información del monedero
                  const SizedBox(height: 32),
                  _buildMonederoInfo(isDark: isDark, textColor: textColor),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        
        // Cancel button at the bottom
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: _buildCancelButton(context),
        ),
      ],
    );
  }

  Widget desktopWidget({required BuildContext context, required bool isDark, required Color textColor}) {
    return Column(
      children: [
        // Header
        _buildHeader(context, textColor: textColor, isDark: isDark),
        
        // Content - centered
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // ¡Código Listo! text with underline
                    Column(
                      children: [
                        Text(
                          "¡Código Listo!",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 100,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFF205AA8), // Blue
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Instructions text
                    Text(
                      "Escanea este código QR para completar tu pago.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // QR Code container - centered
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: _buildQRCode(isDark: isDark, textColor: textColor),
                      ),
                    ),
                    
                    // Información del monedero
                    const SizedBox(height: 32),
                    _buildMonederoInfo(isDark: isDark, textColor: textColor),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Cancel button at the bottom
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
          child: SizedBox(
            width: 500,
            child: _buildCancelButton(context),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, {Color textColor = Colors.white, bool isDark = true}) {
    final paddingTop = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: paddingTop + 16.0,
        bottom: 16.0,
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () => GoRouter.of(context).go(RoutesName.dashboard),
          ),
          
          // Title "Pagar con código QR"
          Expanded(
            child: Text(
              "Pagar con código QR",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
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

  Widget _buildQRCode({required bool isDark, required Color textColor}) {
    return StreamBuilder<MonederoStatus>(
      stream: monederoBloc.qrStatusStream,
      initialData: monederoBloc.qrStatus,
      builder: (context, statusSnapshot) {
        final status = statusSnapshot.data ?? MonederoStatus.initial;

        // Loading state
        if (status == MonederoStatus.loading) {
          return Container(
            width: 250,
            height: 250,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF205AA8),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Generando código QR...',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Error state
        if (status == MonederoStatus.error) {
          return Container(
            width: 250,
            height: 250,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      monederoBloc.qrErrorMessage ??
                          'No se pudo generar el código QR',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      // * UPDATE: Reintentar con el mismo numeroPasajes
                      final numeroPasajes = widget.numeroPasajes ?? 1;
                      monederoBloc.obtenerQrSaldo(numeroPasajes: numeroPasajes, forzarNuevo: true);
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reintentar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF205AA8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Loaded state
        return StreamBuilder<QrWalletModel?>(
          stream: monederoBloc.qrStream,
          initialData: monederoBloc.qr,
          builder: (context, qrSnapshot) {
            final qr = qrSnapshot.data;

            if (qr == null || !qr.esValido) {
              return Container(
                width: 250,
                height: 250,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay código QR disponible',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final qrBytes = qr.qrImageBytes;
            if (qrBytes == null) {
              return Container(
                width: 250,
                height: 250,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al procesar el código QR',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Image.memory(
              qrBytes,
              width: 250,
              height: 250,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 250,
                  height: 250,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al mostrar el código QR',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMonederoInfo({required bool isDark, required Color textColor}) {
    final cardColor = isDark ? Colors.grey[800] : Colors.grey[100];
    
    return StreamBuilder<QrWalletModel?>(
      stream: monederoBloc.qrStream,
      initialData: monederoBloc.qr,
      builder: (context, qrSnapshot) {
        final qr = qrSnapshot.data;
        
        if (qr == null) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Saldo disponible
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saldo disponible:',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    qr.saldoFormateado,
                    style: TextStyle(
                      color: const Color(0xFF205AA8),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Número de serie del monedero
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Número de monedero:',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    qr.numeroSerie,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () => GoRouter.of(context).go(RoutesName.dashboard),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF205AA8), // Blue color #205AA8
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Cancelar",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
          currentIndex: 0, // Monedero is selected
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

