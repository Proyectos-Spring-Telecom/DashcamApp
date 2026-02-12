// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:dashboardpro/utils/location_helper.dart';
import 'package:flutter/services.dart';
import 'package:quickalert/quickalert.dart';

class IngresarMontoPage extends StatefulWidget {
  final Map<String, dynamic>? monedero;
  const IngresarMontoPage({super.key, this.monedero});

  @override
  State<IngresarMontoPage> createState() => _IngresarMontoPageState();
}

class _IngresarMontoPageState extends State<IngresarMontoPage> {
  double _monto = 0.0;
  final List<double> _quickAmounts = [10, 20, 50, 100, 150, 200];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppTheme>(
      stream: themeBloc.themeStream,
      initialData: themeBloc.currentTheme,
      builder: (context, snapshot) {
        final isDark = snapshot.data?.data.brightness == Brightness.dark;
        final backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;

        final systemUiOverlayStyle = SystemUiOverlayStyle(
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
                      context: context, isDark: isDark, textColor: textColor),
                  desktop: desktopView(
                      context: context, isDark: isDark, textColor: textColor),
                  tablet: mobileView(
                      context: context, isDark: isDark, textColor: textColor),
                ),
              ),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(context, isDark),
          ),
        );
      },
    );
  }

  Widget mobileView({
    required BuildContext context,
    required bool isDark,
    required Color textColor,
  }) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header azul oscuro
          _buildHeader(context, textColor: Colors.white, isDark: isDark),
          // Content
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Steps indicator
                _buildStepsIndicator(isDark: isDark, textColor: textColor),
                const SizedBox(height: 24.0),
                // Panel izquierdo - Monto a Recargar
                _buildMontoPanel(isDark: isDark, textColor: textColor),
                const SizedBox(height: 24.0),
                // Panel derecho - Resumen
                _buildResumenPanel(isDark: isDark, textColor: textColor),
                const SizedBox(height: 100.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget desktopView({
    required BuildContext context,
    required bool isDark,
    required Color textColor,
  }) {
    return Column(
      children: [
        // Header azul oscuro
        _buildHeader(context, textColor: Colors.white, isDark: isDark),
        // Content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Steps indicator
                    _buildStepsIndicator(isDark: isDark, textColor: textColor),
                    const SizedBox(height: 32.0),
                    // Main content - dos paneles
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Panel izquierdo - Monto a Recargar
                        Expanded(
                          flex: 3,
                          child: _buildMontoPanel(isDark: isDark, textColor: textColor),
                        ),
                        const SizedBox(width: 24.0),
                        // Panel derecho - Resumen
                        Expanded(
                          flex: 2,
                          child: _buildResumenPanel(
                              isDark: isDark, textColor: textColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    Color textColor = Colors.white,
    bool isDark = false,
  }) {
    final paddingTop = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: paddingTop + 16.0,
        bottom: 16.0,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF205AA8), // Azul oscuro
      ),
      child: Row(
        children: [
          // Wallet icon
          const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
          const SizedBox(width: 12.0),
          // Title
          Expanded(
            child: Text(
              "Realizar Pago",
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Profile avatar
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
                  backgroundColor: Colors.white.withOpacity(0.2),
                  iconColor: Colors.white,
                  iconSize: 24,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsIndicator({
    required bool isDark,
    required Color textColor,
  }) {
    final activeStepColor = const Color(0xFF205AA8); // Blue
    final completedStepColor = const Color(0xFFA6CE39); // Green
    final inactiveStepColor = isDark ? Colors.grey[600] : Colors.grey[400];
    final activeTextColor = activeStepColor;
    final completedTextColor = completedStepColor;
    final inactiveTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Row(
      children: [
        // Step 1 - Completed
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: completedStepColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selecciona Monedero",
                          style: TextStyle(
                            color: completedTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Elige a quién recargar",
                          style: TextStyle(
                            color: inactiveTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Step 2 - Active
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: activeStepColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ingresa Monto",
                          style: TextStyle(
                            color: activeTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Define cuánto recargar",
                          style: TextStyle(
                            color: inactiveTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMontoPanel({
    required bool isDark,
    required Color textColor,
  }) {
    final cardColor = isDark ? Colors.grey[800]! : Colors.white;
    final buttonColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title con icono
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFA6CE39).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Color(0xFFA6CE39),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Monto a Recargar",
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32.0),
          // Display del monto
          Center(
            child: Text(
              "\$ ${_monto.toStringAsFixed(2)}",
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 48,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 32.0),
          // Quick amount buttons - 3 por fila
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 2.2,
            ),
            itemCount: _quickAmounts.length,
            itemBuilder: (context, index) {
              return _buildQuickAmountButton(
                amount: _quickAmounts[index],
                isDark: isDark,
                textColor: textColor,
                buttonColor: buttonColor,
              );
            },
          ),
          const SizedBox(height: 32.0),
          // Numeric keypad
          _buildNumericKeypad(isDark: isDark, textColor: textColor, buttonColor: buttonColor),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButton({
    required double amount,
    required bool isDark,
    required Color textColor,
    required Color buttonColor,
  }) {
    final isSelected = (_monto - amount).abs() < 0.001;
    return GestureDetector(
      onTap: () {
        setState(() {
          _monto = amount;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: const Color(0xFF205AA8),
                  width: 2.0,
                )
              : null,
        ),
        child: Center(
          child: Text(
            "\$${amount.toStringAsFixed(0)}",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildNumericKeypad({
    required bool isDark,
    required Color textColor,
    required Color buttonColor,
  }) {
    final keypadColor = const Color(0xFF205AA8); // Azul claro
    final keypadTextColor = Colors.white;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12.0,
      crossAxisSpacing: 12.0,
      childAspectRatio: 2.2,
      children: [
        // Row 1
        _buildKeypadButton('1', keypadColor, keypadTextColor),
        _buildKeypadButton('2', keypadColor, keypadTextColor),
        _buildKeypadButton('3', keypadColor, keypadTextColor),
        // Row 2
        _buildKeypadButton('4', keypadColor, keypadTextColor),
        _buildKeypadButton('5', keypadColor, keypadTextColor),
        _buildKeypadButton('6', keypadColor, keypadTextColor),
        // Row 3
        _buildKeypadButton('7', keypadColor, keypadTextColor),
        _buildKeypadButton('8', keypadColor, keypadTextColor),
        _buildKeypadButton('9', keypadColor, keypadTextColor),
        // Row 4
        _buildKeypadButton('00', keypadColor, keypadTextColor),
        _buildKeypadButton('0', keypadColor, keypadTextColor),
        _buildKeypadButton('', keypadColor, keypadTextColor, isBackspace: true),
      ],
    );
  }

  Widget _buildKeypadButton(String value, Color color, Color textColor,
      {bool isBackspace = false}) {
    return GestureDetector(
      onTap: () {
        if (isBackspace) {
          setState(() {
            _monto = (_monto / 10).floorToDouble();
          });
        } else {
          setState(() {
            // Convertir el monto a centavos para evitar problemas de precisión decimal
            int centavos = (_monto * 100).round();
            
            if (value == '00') {
              centavos = centavos * 100;
            } else {
              centavos = centavos * 10 + int.parse(value);
            }
            
            // Convertir de vuelta a dólares, con máximo de 999999.99
            if (centavos > 99999999) {
              centavos = 99999999;
            }
            
            _monto = centavos / 100.0;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: isBackspace
              ? const Icon(Icons.backspace, color: Colors.white, size: 24)
              : Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildResumenPanel({
    required bool isDark,
    required Color textColor,
  }) {
    final cardColor = isDark ? Colors.grey[800] : Colors.white;
    final monedero = widget.monedero ?? {};

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title y Botón Cambiar monedero en la misma línea
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Row(
                children: [
                  Icon(Icons.receipt, color: const Color(0xFF205AA8), size: 24),
                  const SizedBox(width: 12),
                  Text(
                    "Resumen",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // Botón Cambiar monedero
              TextButton.icon(
                onPressed: () {
                  GoRouter.of(context).go(RoutesName.pos);
                },
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text("Cambiar monedero"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          // Resumen details
          _buildResumenItem(
            'Saldo actual',
            '\$${(monedero['saldo'] ?? 0.0).toStringAsFixed(2)}',
            const Color(0xFFA6CE39),
            isDark: isDark,
            textColor: textColor,
          ),
          const SizedBox(height: 16.0),
          _buildResumenItem(
            'Monedero',
            '#${monedero['serie'] ?? 'N/A'}',
            textColor,
            isDark: isDark,
            textColor: textColor,
          ),
          const SizedBox(height: 16.0),
          _buildResumenItem(
            'Pasajero',
            monedero['pasajero'] ?? '—',
            textColor,
            isDark: isDark,
            textColor: textColor,
          ),
          const SizedBox(height: 16.0),
          _buildResumenItem(
            'Cliente',
            monedero['cliente'] ?? 'N/A',
            textColor,
            isDark: isDark,
            textColor: textColor,
          ),
          const SizedBox(height: 16.0),
          // Monto con tamaño más grande
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monto',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${_monto.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFFA6CE39),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32.0),
          // Botones
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _monto >= 10 && !_isLoading
                  ? () => _realizarCargo(context)
                  : null,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check, size: 20),
              label: Text(
                _isLoading ? "Procesando..." : "Recargar",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF205AA8), // Azul
                disabledBackgroundColor: Colors.grey[400],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
                  builder: (context) => _buildCancelarRecargaBottomSheet(
                      context, isDark, textColor),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }

  Widget _buildResumenItem(
    String label,
    String value,
    Color valueColor, {
    required bool isDark,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Obtiene la ubicación actual del dispositivo
  /// Retorna un Map con 'latitud' y 'longitud', o null si hay error
  /// Realiza el cargo al monedero seleccionado
  Future<void> _realizarCargo(BuildContext context) async {
    // Validaciones previas
    if (widget.monedero == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'No hay monedero seleccionado',
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF205AA8),
      );
      return;
    }

    final numeroSerieMonedero = widget.monedero!['serie']?.toString() ?? '';
    if (numeroSerieMonedero.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'El número de serie del monedero no es válido',
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF205AA8),
      );
      return;
    }

    if (_monto < 10) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'El monto debe ser mayor o igual a 10',
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF205AA8),
      );
      return;
    }

    // Mostrar confirmación antes de realizar el cargo
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Confirmar recarga',
      text: '¿Deseas realizar una recarga de \$${_monto.toStringAsFixed(2)}?',
      confirmBtnText: 'Confirmar',
      cancelBtnText: 'Cancelar',
      confirmBtnColor: const Color(0xFF205AA8),
      onConfirmBtnTap: () async {
        Navigator.pop(context); // Cerrar el QuickAlert de confirmación
        
        // Mostrar loading
        if (!mounted) return;
        setState(() {
          _isLoading = true;
        });

        try {
          // Obtener ubicación actual con helper robusto (PWA iOS: solicita permisos si hace falta)
          debugPrint('📍 [IngresarMonto] Solicitando coordenadas antes de recarga (requestPermissionIfNeeded=true)...');
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
            debugPrint('📍 [IngresarMonto] Coordenadas válidas: lat=$latitudInicial, lng=$longitudInicial');
          } else {
            debugPrint('⚠️ [IngresarMonto] No se obtuvieron coordenadas válidas. ubicacion=$ubicacion');
            if (!mounted) return;
            setState(() => _isLoading = false);
            QuickAlert.show(
              context: context,
              type: QuickAlertType.warning,
              title: 'Ubicación requerida',
              text:
                  'Para realizar la recarga necesitamos tu ubicación. Por favor, permite el acceso a la ubicación e intenta de nuevo.',
              confirmBtnText: 'Aceptar',
              confirmBtnColor: const Color(0xFF205AA8),
            );
            return;
          }

          // Realizar el cargo con las coordenadas validadas
          await monederoBloc.realizarCargo(
            numeroSerieMonedero: numeroSerieMonedero,
            monto: _monto,
            latitudInicial: latitudInicial,
            longitudInicial: longitudInicial,
          );

          if (!mounted) return;

          // Ocultar loading
          setState(() {
            _isLoading = false;
          });

          // Mostrar mensaje de éxito y navegar a transacciones
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Recarga realizada',
            text: 'Tu recarga de \$${_monto.toStringAsFixed(2)} se ha procesado correctamente',
            confirmBtnText: 'Ver transacciones',
            confirmBtnColor: const Color(0xFF205AA8),
            onConfirmBtnTap: () {
              Navigator.pop(context);
              // Refrescar transacciones para mostrar la última
              monederoBloc.obtenerTransacciones();
              GoRouter.of(context).go(RoutesName.transacciones);
            },
          );
        } on MonederoException catch (e) {
          if (!mounted) return;

          // Ocultar loading
          setState(() {
            _isLoading = false;
          });

          // Mostrar mensaje de error
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Error',
            text: e.message,
            confirmBtnText: 'Aceptar',
            confirmBtnColor: const Color(0xFF205AA8),
          );
        } catch (e) {
          if (!mounted) return;

          // Ocultar loading
          setState(() {
            _isLoading = false;
          });

          // Mostrar mensaje de error genérico
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Error',
            text: 'No se pudo realizar el cargo, intenta más tarde.',
            confirmBtnText: 'Aceptar',
            confirmBtnColor: const Color(0xFF205AA8),
          );
        }
      },
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
                GoRouter.of(context).go(RoutesName.pos);
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
                backgroundColor: Colors.grey[700],
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
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF205AA8),
          unselectedItemColor: Colors.grey[600],
          currentIndex: 0,
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

