// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:dashboardpro/utils/device_info_helper.dart';
import 'package:dashboardpro/utils/location_helper.dart';
import 'package:flutter/services.dart';
import 'package:quickalert/quickalert.dart';

class ResumenPage extends StatefulWidget {
  final String? amount;
  final String? selectedCardToken;
  const ResumenPage({super.key, this.amount, this.selectedCardToken});

  @override
  State<ResumenPage> createState() => _ResumenPageState();
}

class _ResumenPageState extends State<ResumenPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Cargar el wallet, monederos y las tarjetas de NetPay cuando se inicializa la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      monederoBloc.obtenerWallet().then((_) {
        _cargarTarjetasNetPay();
      });
      monederoBloc.obtenerMonederos();
    });
  }

  void _cargarTarjetasNetPay() {
    final wallet = monederoBloc.wallet;
    if (wallet != null && wallet.customerIdNetPay != null && wallet.customerIdNetPay!.isNotEmpty) {
      netPayBloc.obtenerClienteNetPay(wallet.customerIdNetPay!);
    }
  }

  /// Determina el idMetodoPago basado en el tipo de tarjeta seleccionada
  /// Obtiene el tipo de tarjeta del servicio /netpay/customers
  /// type: "credit" → idMetodoPago = 3
  /// type: "debit" → idMetodoPago = 4
  /// Si no hay tarjeta seleccionada → idMetodoPago = 1 (Efectivo)
  int _getIdMetodoPago() {
    // Si no hay tarjeta seleccionada, usar efectivo
    if (widget.selectedCardToken == null || widget.selectedCardToken!.isEmpty) {
      return 1; // Efectivo
    }

    // Obtener la tarjeta seleccionada para determinar su tipo
    final selectedCard = _getSelectedCard();
    if (selectedCard == null) {
      // Si no se encuentra la tarjeta, usar efectivo por defecto
      return 1; // Efectivo
    }

    // Determinar idMetodoPago basado en el tipo de tarjeta
    final cardType = selectedCard.card.type.toLowerCase();
    if (cardType == 'credit') {
      return 3; // Crédito
    } else if (cardType == 'debit') {
      return 4; // Débito
    }

    // Si el tipo no es reconocido, usar crédito por defecto
    debugPrint('⚠️ Tipo de tarjeta no reconocido: $cardType, usando crédito por defecto');
    return 3; // Crédito por defecto
  }

  /// Obtiene la información de la tarjeta seleccionada
  PaymentSourceModel? _getSelectedCard() {
    if (widget.selectedCardToken == null || widget.selectedCardToken!.isEmpty) {
      return null;
    }

    final customer = netPayBloc.currentCustomer;
    if (customer == null) return null;

    try {
      return customer.paymentSources.firstWhere(
        (ps) => ps.card.token == widget.selectedCardToken,
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtiene el deviceFingerPrint de la tarjeta desde el modelo PaymentSourceModel
  /// El deviceFingerPrint viene del servicio /netpay/customers en el arreglo paymentSources
  String? _getDeviceFingerPrint(PaymentSourceModel? paymentSource) {
    if (paymentSource == null) {
      debugPrint('⚠️ PaymentSource es null');
      return null;
    }
    
    // Debug: imprimir información de la tarjeta
    debugPrint('🔍 Información de la tarjeta seleccionada:');
    debugPrint('   - Token: ${paymentSource.card.token}');
    debugPrint('   - deviceFingerPrint: ${paymentSource.deviceFingerPrint}');
    debugPrint('   - deviceFingerPrint es null: ${paymentSource.deviceFingerPrint == null}');
    debugPrint('   - deviceFingerPrint está vacío: ${paymentSource.deviceFingerPrint?.isEmpty ?? true}');
    
    if (paymentSource.deviceFingerPrint != null && paymentSource.deviceFingerPrint!.isNotEmpty) {
      return paymentSource.deviceFingerPrint;
    }
    
    // Si no hay deviceFingerPrint, NO usar fallback - debe venir del servicio
    debugPrint('❌ deviceFingerPrint no disponible en paymentSource');
    return null;
  }

  /// Obtiene el idDireccion del arreglo datosTarjeta del servicio /netpay/customers
  /// Busca el registro donde tokenCard coincida con el token de la tarjeta seleccionada
  int? _getIdDireccionFromDatosTarjeta(String tokenCard) {
    final customer = netPayBloc.currentCustomer;
    if (customer == null) {
      debugPrint('⚠️ Customer es null, no se puede obtener idDireccion');
      return null;
    }

    try {
      final datoTarjeta = customer.datosTarjeta.firstWhere(
        (dt) => dt.tokenCard == tokenCard,
      );
      
      debugPrint('✅ idDireccion encontrado en datosTarjeta: ${datoTarjeta.idDireccion}');
      return datoTarjeta.idDireccion;
    } catch (e) {
      debugPrint('❌ No se encontró idDireccion en datosTarjeta para token: $tokenCard');
      debugPrint('   - datosTarjeta disponibles: ${customer.datosTarjeta.length}');
      for (var dt in customer.datosTarjeta) {
        debugPrint('     - tokenCard: ${dt.tokenCard}, idDireccion: ${dt.idDireccion}');
      }
      return null;
    }
  }

  /// Procesa la recarga
  Future<void> _procesarRecarga(BuildContext context) async {
    if (_isLoading) return;

    try {
      // Validar que hay monto
      final amount = double.tryParse(widget.amount ?? '0') ?? 0.0;
      if (amount <= 0) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          title: 'Monto inválido',
          text: 'Por favor, selecciona un monto válido para recargar.',
          confirmBtnText: 'Aceptar',
          confirmBtnColor: const Color(0xFF205AA8),
        );
        return;
      }

      // Obtener el monedero
      final wallet = monederoBloc.wallet;
      if (wallet == null || wallet.monederos.isEmpty) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          title: 'Monedero no disponible',
          text: 'No se encontró información del monedero. Por favor, intenta más tarde.',
          confirmBtnText: 'Aceptar',
          confirmBtnColor: const Color(0xFF205AA8),
        );
        return;
      }

      final numeroSerieMonedero = wallet.monederos;
      final idMetodoPago = _getIdMetodoPago();

      // Si es tarjeta, validar que hay tarjeta seleccionada
      String? tokenCardNetPay;
      String? deviceFingerPrint;
      int? idDireccion;
      
      if (idMetodoPago == 3 || idMetodoPago == 4) {
        final selectedCard = _getSelectedCard();
        if (selectedCard == null) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.warning,
            title: 'Tarjeta no seleccionada',
            text: 'Por favor, selecciona una tarjeta para realizar el pago.',
            confirmBtnText: 'Aceptar',
            confirmBtnColor: const Color(0xFF205AA8),
          );
          return;
        }

        tokenCardNetPay = selectedCard.card.token;
        deviceFingerPrint = _getDeviceFingerPrint(selectedCard);
        
        // Obtener idDireccion del arreglo datosTarjeta del servicio /netpay/customers
        // Buscar donde tokenCard coincida con el token de la tarjeta seleccionada
        idDireccion = _getIdDireccionFromDatosTarjeta(tokenCardNetPay);
        
        // Si no se encuentra en datosTarjeta, intentar en paymentSource o card como fallback
        if (idDireccion == null) {
          idDireccion = selectedCard.idDireccion ?? selectedCard.card.idDireccion;
        }
        
        // Debug: verificar información de la tarjeta
        debugPrint('🔍 Información de tarjeta para recarga:');
        debugPrint('   - Token: ${selectedCard.card.token}');
        debugPrint('   - Type: ${selectedCard.card.type}');
        debugPrint('   - deviceFingerPrint (raw): ${selectedCard.deviceFingerPrint}');
        debugPrint('   - deviceFingerPrint (obtenido): $deviceFingerPrint');
        debugPrint('   - deviceFingerPrint es null: ${deviceFingerPrint == null}');
        debugPrint('   - deviceFingerPrint está vacío: ${deviceFingerPrint?.isEmpty ?? true}');
        debugPrint('   - idDireccion (datosTarjeta): ${_getIdDireccionFromDatosTarjeta(tokenCardNetPay)}');
        debugPrint('   - idDireccion (paymentSource): ${selectedCard.idDireccion}');
        debugPrint('   - idDireccion (card): ${selectedCard.card.idDireccion}');
        debugPrint('   - idDireccion (final): $idDireccion');
        
        // Validar que el deviceFingerPrint esté disponible
        if (deviceFingerPrint == null || deviceFingerPrint.isEmpty) {
          debugPrint('❌ ERROR: deviceFingerPrint es null o vacío');
          QuickAlert.show(
            context: context,
            type: QuickAlertType.warning,
            title: 'Información de tarjeta incompleta',
            text: 'La tarjeta seleccionada no tiene la información necesaria. Por favor, intenta con otra tarjeta.',
            confirmBtnText: 'Aceptar',
            confirmBtnColor: const Color(0xFF205AA8),
          );
          return;
        }
        
        // Validar que idDireccion esté disponible (obligatorio para tarjeta)
        if (idDireccion == null) {
          debugPrint('❌ ERROR: idDireccion es null');
          QuickAlert.show(
            context: context,
            type: QuickAlertType.warning,
            title: 'Información de tarjeta incompleta',
            text: 'La tarjeta seleccionada no tiene la información de dirección necesaria. Por favor, intenta con otra tarjeta.',
            confirmBtnText: 'Aceptar',
            confirmBtnColor: const Color(0xFF205AA8),
          );
          return;
        }
        
        debugPrint('✅ Todos los campos de tarjeta están disponibles');
        debugPrint('   - tokenCardNetPay: $tokenCardNetPay');
        debugPrint('   - deviceFingerPrint: $deviceFingerPrint');
        debugPrint('   - idDireccion: $idDireccion');
      }

      // Obtener información del dispositivo
      final deviceInformation = await DeviceInfoHelper.getDeviceInformation(context);

      // Obtener ubicación actual con helper robusto (PWA iOS: solicita permisos si hace falta)
      debugPrint('📍 [Resumen] Solicitando coordenadas antes de recarga (requestPermissionIfNeeded=true)...');
      final ubicacion = await LocationHelper.getValidCoordinatesMap(
        requestPermissionIfNeeded: true,
      );

      double? latitudInicial;
      double? longitudInicial;
      if (ubicacion != null &&
          LocationHelper.isValidCoordinate(ubicacion['latitud']) &&
          LocationHelper.isValidCoordinate(ubicacion['longitud'])) {
        latitudInicial = ubicacion['latitud'];
        longitudInicial = ubicacion['longitud'];
        debugPrint('📍 [Resumen] Coordenadas válidas para recarga: lat=$latitudInicial, lng=$longitudInicial');
      } else {
        debugPrint('⚠️ [Resumen] No se obtuvieron coordenadas válidas. ubicacion=$ubicacion');
        if (!mounted) return;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          title: 'Ubicación requerida',
          text:
              'Para realizar la recarga necesitamos tu ubicación. Por favor, permite el acceso a la ubicación en la configuración del navegador o de la app e intenta de nuevo.',
          confirmBtnText: 'Aceptar',
          confirmBtnColor: const Color(0xFF205AA8),
        );
        return;
      }

      // Mostrar loading
      setState(() {
        _isLoading = true;
      });

      // Realizar la recarga con todos los campos necesarios (coordenadas ya validadas)
      final response = await monederoBloc.realizarRecarga(
        numeroSerieMonedero: numeroSerieMonedero,
        monto: amount,
        idMetodoPago: idMetodoPago,
        tokenCardNetPay: tokenCardNetPay,
        deviceFingerPrint: deviceFingerPrint,
        latitudInicial: latitudInicial,
        longitudInicial: longitudInicial,
        numeroSerieValidador: null, // NULL según requerimientos
        idDireccion: idDireccion, // Obtenido de la tarjeta seleccionada
        deviceInformation: deviceInformation,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Mostrar mensaje de éxito
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Recarga exitosa',
        text: 'Tu recarga de \$${amount.toStringAsFixed(2)} se ha procesado correctamente',
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF205AA8),
        onConfirmBtnTap: () {
          Navigator.pop(context);
          GoRouter.of(context).go(RoutesName.dashboard);
        },
      );
    } on MonederoException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Mostrar error
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error al recargar',
        text: e.message,
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF205AA8),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Mostrar error genérico
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error inesperado',
        text: 'No se pudo procesar la recarga. Por favor, intenta más tarde.',
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF205AA8),
      );
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
                      context: context, isDark: isDark, textColor: textColor, amount: widget.amount),
                  desktop: desktopView(
                      context: context, isDark: isDark, textColor: textColor, amount: widget.amount),
                  tablet: mobileView(
                      context: context, isDark: isDark, textColor: textColor, amount: widget.amount),
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
      String? amount}) {
    return Column(
      children: [
        // Header
        _buildHeader(context, textColor: textColor, isDark: isDark),
        // Content
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen de pago card
                _buildResumenPagoCard(
                    isDark: isDark, textColor: textColor),
                const SizedBox(height: 32.0),

                // Recarga section
                _buildRecargaSection(
                    isDark: isDark, textColor: textColor, amount: amount),
                const SizedBox(height: 24.0),

                // Método de pago section
                _buildMetodoPagoSection(
                    isDark: isDark, textColor: textColor),

                const Spacer(),

                // Terms and conditions text
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      "Al recargar, aceptas los Términos y Condiciones del servicio de recarga provistos por la empresa Dashcam PAY.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : () => _procesarRecarga(context),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF205AA8), // Blue
                      disabledBackgroundColor: Colors.grey[400],
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Recargar",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12.0),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            _buildCancelarRecargaBottomSheet(
                                context, isDark, textColor),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.grey[700], // Grey
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Cancelar",
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
    );
  }

  Widget desktopView(
      {required BuildContext context,
      required bool isDark,
      required Color textColor,
      String? amount}) {
    return Column(
      children: [
        // Header
        _buildHeader(context, textColor: textColor, isDark: isDark),
        // Content
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen de pago card
                  _buildResumenPagoCard(
                      isDark: isDark, textColor: textColor),
                  const SizedBox(height: 32.0),

                  // Recarga section
                  _buildRecargaSection(
                      isDark: isDark, textColor: textColor, amount: amount),
                  const SizedBox(height: 24.0),

                  // Método de pago section
                  _buildMetodoPagoSection(
                      isDark: isDark, textColor: textColor),

                  const Spacer(),

                  // Terms and conditions text
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        "Al recargar, aceptas los Términos y Condiciones del servicio de recarga provistos por la empresa Dashcam PAY.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  // Action buttons
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isLoading ? null : () => _procesarRecarga(context),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF205AA8), // Blue
                        disabledBackgroundColor: Colors.grey[400],
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              "Recargar",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              _buildCancelarRecargaBottomSheet(
                                  context, isDark, textColor),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.grey[700], // Grey
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cancelar",
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
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context,
      {Color textColor = Colors.white, bool isDark = true}) {
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
              GoRouter.of(context).go(RoutesName.seleccionarMetodoPago);
            },
          ),
          // Title
          Expanded(
            child: Text(
              "Resumen",
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

  Widget _buildResumenPagoCard(
      {required bool isDark, required Color textColor}) {
    final cardColor = isDark ? Colors.grey[800] : Colors.grey[100];

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: StreamBuilder<PasajeroWalletModel?>(
        stream: monederoBloc.walletStream,
        initialData: monederoBloc.wallet,
        builder: (context, walletSnapshot) {
          final wallet = walletSnapshot.data;
          final saldoTotal = wallet?.saldoTotalFormateado ?? '\$0.00';
          final numeroSerie = wallet?.monederos ?? 'Sin monedero';
          final nombreTipoPasajero = wallet?.nombreTipoPasajero ?? 'N/A';

          return Row(
            children: [
              // Wallet icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFA6CE39).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xFFA6CE39),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Monedero info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Monedero: $numeroSerie",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Pasajero: $nombreTipoPasajero",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
                  // Balance
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        saldoTotal,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Saldo disponible",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              );
        },
      ),
    );
  }

  Widget _buildRecargaSection(
      {required bool isDark, required Color textColor, String? amount}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recarga",
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 17.0),
        _buildMontoSeleccionadoRow(
          label: "Monto seleccionado",
          value: "\$${widget.amount ?? '50'}",
          isDark: isDark,
          textColor: textColor,
        ),
        const SizedBox(height: 12.0),
        _buildRecargaRow(
          label: "Comisión por recarga",
          value: "\$0",
          isDark: isDark,
          textColor: textColor,
        ),
      ],
    );
  }

  Widget _buildMontoSeleccionadoRow({
    required String label,
    required String value,
    required bool isDark,
    required Color textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecargaRow({
    required String label,
    required String value,
    required bool isDark,
    required Color textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMetodoPagoSection(
      {required bool isDark, required Color textColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Método de pago",
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                // Selected card chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFA6CE39), // Light green
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFA6CE39),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Mostrar la tarjeta seleccionada dinámicamente
                      StreamBuilder<NetPayCustomerModel?>(
                        stream: netPayBloc.customerStream,
                        initialData: netPayBloc.currentCustomer,
                        builder: (context, snapshot) {
                          final customer = snapshot.data;
                          final paymentSources = customer?.paymentSources ?? [];
                          
                          String lastFourDigits = '----';
                          if (widget.selectedCardToken != null && paymentSources.isNotEmpty) {
                            try {
                              final selectedCard = paymentSources.firstWhere(
                                (ps) => ps.card.token == widget.selectedCardToken,
                              );
                              lastFourDigits = selectedCard.card.lastFourDigits;
                            } catch (e) {
                              // Si no se encuentra la tarjeta, usar la primera disponible
                              if (paymentSources.isNotEmpty) {
                                lastFourDigits = paymentSources.first.card.lastFourDigits;
                              }
                            }
                          } else if (paymentSources.isNotEmpty) {
                            // Si no hay token seleccionado, usar la primera tarjeta
                            lastFourDigits = paymentSources.first.card.lastFourDigits;
                          }
                          
                          return Text(
                            "**** $lastFourDigits",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCancelarRecargaBottomSheet(
      BuildContext context, bool isDark, Color textColor) {
    final backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning icon
          Container(
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
          const SizedBox(height: 24.0),

          // Question text
          Text(
            "¿Deseas cancelar la recarga?",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32.0),

          // Si, cancelar button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                GoRouter.of(context).go(RoutesName.dashboard);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF205AA8), // Blue
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Si, cancelar",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12.0),

          // Regresar button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.grey[700], // Same as Cancelar button
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Regresar",
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
