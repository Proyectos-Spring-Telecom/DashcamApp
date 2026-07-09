// Project imports:
import 'package:dashboardpro/utils/secure_log.dart';
import 'package:dashboardpro/dashboardpro.dart';
import 'package:dashboardpro/utils/solo_letras_input.dart';
import 'package:dashboardpro/utils/email_validation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:quickalert/quickalert.dart';

class NuevaTarjetaPage extends StatefulWidget {
  const NuevaTarjetaPage({super.key});

  @override
  State<NuevaTarjetaPage> createState() => _NuevaTarjetaPageState();
}

class _NuevaTarjetaPageState extends State<NuevaTarjetaPage> {
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _mesController = TextEditingController();
  final TextEditingController _anoController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _codigoPostalController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _calleController = TextEditingController();
  bool _direccionHabilitada = false;
  String? _municipioSeleccionado;
  String? _coloniaSeleccionada;
  bool _procesandoAsignacion = false; // Flag para prevenir múltiples ejecuciones
  bool _mostradoMensajeExito = false; // Flag para prevenir mostrar múltiples veces el mensaje
  bool _mostradoMensajeError = false; // Flag para prevenir mostrar múltiples veces el error
  bool _validandoErrorAsignacion = false; // Evita programar múltiples callbacks de error
  String? _ultimoTokenProcesado; // Evita reintentar asignar el mismo token en bucle
  bool _mostradoInfoTokenizacion = false; // Evita repetir QuickAlert info en fallback de red

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _numeroController.dispose();
    _mesController.dispose();
    _anoController.dispose();
    _cvvController.dispose();
    _codigoPostalController.dispose();
    _estadoController.dispose();
    _calleController.dispose();
    super.dispose();
  }

  // Lista de municipios (se llena desde el servicio)
  List<String> _municipios = [];

  // Lista de colonias (se llena desde el servicio)
  List<String> _colonias = [];

  @override
  void initState() {
    super.initState();
    // Listener para actualizar el estado cuando se consulta el código postal
    direccionBloc.codigoPostalStream.listen((codigoPostal) {
      if (codigoPostal != null && mounted) {
        setState(() {
          _direccionHabilitada = true;
          _estadoController.text = codigoPostal.estado;
          _municipios = [codigoPostal.municipio];
          _municipioSeleccionado = codigoPostal.municipio;
          _colonias = codigoPostal.colonias;
          // Si solo hay una colonia, seleccionarla automáticamente
          if (_colonias.length == 1) {
            _coloniaSeleccionada = _colonias.first;
          } else {
            _coloniaSeleccionada = null;
          }
        });
      }
    });

    // Listener para mostrar errores
    direccionBloc.errorStream.listen((error) {
      if (error != null && mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: error,
          confirmBtnText: 'Aceptar',
          confirmBtnColor: Colors.red,
        );
      }
    });
  }

  // Buscar dirección por código postal usando el servicio
  Future<void> _buscarDireccion() async {
    final codigoPostal = _codigoPostalController.text.trim();
    if (codigoPostal.length == 5) {
      await direccionBloc.consultarPorCodigoPostal(codigoPostal);
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Código postal inválido',
        text: 'El código postal debe tener 5 dígitos',
        confirmBtnText: 'Aceptar',
        confirmBtnColor: Colors.orange,
      );
    }
  }

  // Formatear número de tarjeta con espacios cada 4 dígitos
  String _formatearNumeroTarjeta(String numero) {
    // Remover todos los espacios existentes
    numero = numero.replaceAll(' ', '');
    // Agregar espacios cada 4 dígitos
    String formateado = '';
    for (int i = 0; i < numero.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formateado += ' ';
      }
      formateado += numero[i];
    }
    return formateado;
  }

  // Obtener nombre completo
  String _obtenerNombreCompleto() {
    final nombres = _nombresController.text.trim();
    final apellidos = _apellidosController.text.trim();
    if (nombres.isEmpty && apellidos.isEmpty) {
      return '';
    }
    return '$nombres $apellidos'.trim();
  }

  // Obtener fecha de expiración formateada
  String _obtenerFechaExpiracion() {
    final mes = _mesController.text.trim();
    final ano = _anoController.text.trim();
    if (mes.isEmpty || ano.isEmpty) {
      return '';
    }
    return '$mes/${ano.length == 2 ? ano : ano.length == 4 ? ano.substring(2) : ano}';
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
                // Card preview
                _buildCardPreview(textColor: textColor, isDark: isDark),
                const SizedBox(height: 24),
                // Form fields
                _buildFormFields(textColor: textColor, isDark: isDark),
                const SizedBox(height: 24),
                // Save button
                _buildSaveButton(),
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
                  // Card preview
                  _buildCardPreview(textColor: textColor, isDark: isDark),
                  const SizedBox(height: 24),
                  // Form fields
                  _buildFormFields(textColor: textColor, isDark: isDark),
                  const SizedBox(height: 24),
                  // Save button
                  _buildSaveButton(),
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
              if (GoRouter.of(context).canPop()) {
                GoRouter.of(context).pop();
              } else {
                GoRouter.of(context).go(RoutesName.metodosPago);
              }
            },
          ),
          // Title
          Expanded(
            child: Text(
              "Agregar método de pago",
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

  Widget _buildCardPreview({Color textColor = Colors.white, bool isDark = true}) {
    // Colores ajustados para modo oscuro/claro
    // Modo oscuro: tarjeta oscura con texto blanco
    // Modo claro: tarjeta azul oscuro (estilo tarjeta de crédito real) con texto blanco
    final cardColor = isDark 
        ? const Color(0xFF1A1A1A) 
        : const Color(0xFF205AA8); // Azul para modo claro
    final stripeColor = isDark 
        ? Colors.grey[600] 
        : Colors.white.withOpacity(0.3); // Stripe más claro para modo claro
    final cardTextColor = Colors.white; // Siempre blanco para buena legibilidad
    
    // Obtener valores actuales
    final numeroTarjeta = _numeroController.text.isEmpty 
        ? "1234 5678 9999 0000" 
        : _formatearNumeroTarjeta(_numeroController.text);
    final nombreCompleto = _obtenerNombreCompleto().isEmpty 
        ? "NOMBRE COMPLETO" 
        : _obtenerNombreCompleto().toUpperCase();
    final fechaExp = _obtenerFechaExpiracion().isEmpty 
        ? "MM/AA" 
        : _obtenerFechaExpiracion();
    final cvv = _cvvController.text.isEmpty ? "***" : _cvvController.text;
    
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Light grey stripe at top
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: stripeColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Spacer(),
          // Card number
          Text(
            numeroTarjeta,
            style: TextStyle(
              color: cardTextColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          // Fecha, CVV and Cardholder name row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fechaExp,
                      style: TextStyle(
                        color: cardTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      nombreCompleto,
                      style: TextStyle(
                        color: cardTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // CVV a la derecha
              Text(
                "CVV $cvv",
                style: TextStyle(
                  color: cardTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields({Color textColor = Colors.white, bool isDark = true}) {
    final labelColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final fillColor = isDark ? Colors.grey[900] : Colors.grey[100];
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final focusedBorderColor = isDark ? Colors.grey[600]! : Colors.grey[400]!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre(s)
        Text(
          "Nombre(s)",
          style: TextStyle(
            color: labelColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nombresController,
          style: TextStyle(color: textColor),
          inputFormatters: soloLetrasInputFormatters,
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        const SizedBox(height: 16),
        // Apellido(s)
        Text(
          "Apellido(s)",
          style: TextStyle(
            color: labelColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _apellidosController,
          style: TextStyle(color: textColor),
          inputFormatters: soloLetrasInputFormatters,
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        const SizedBox(height: 16),
        // Correo electrónico
        Text(
          "Correo electrónico",
          style: TextStyle(
            color: labelColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _correoController,
          style: TextStyle(color: textColor),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            hintText: "ejemplo@correo.com",
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        const SizedBox(height: 16),
        // Teléfono
        Text(
          "Teléfono",
          style: TextStyle(
            color: labelColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _telefonoController,
          style: TextStyle(color: textColor),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            hintText: "1234567890",
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        const SizedBox(height: 16),
        // Número de tarjeta
        Text(
          "Número de tarjeta",
          style: TextStyle(
            color: labelColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _numeroController,
          style: TextStyle(color: textColor),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            hintText: "1234 5678 9012 3456",
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: (value) {
            // Formatear mientras se escribe
            final formatted = _formatearNumeroTarjeta(value);
            if (formatted != value) {
              _numeroController.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
            setState(() {});
          },
        ),
        const SizedBox(height: 16),
        // Mes y Año de expiración row
        Row(
          children: [
            // Mes de expiración
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mes de expiración",
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _mesController,
                    style: TextStyle(color: textColor),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: fillColor,
                      hintText: "MM",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: focusedBorderColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Año de expiración
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Año de expiración",
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _anoController,
                    style: TextStyle(color: textColor),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: fillColor,
                      hintText: "AA",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: focusedBorderColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // CVV
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CVV",
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _cvvController,
                    style: TextStyle(color: textColor),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: fillColor,
                      hintText: "***",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: focusedBorderColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16        ),
        const SizedBox(height: 24),
        // Título de dirección de la tarjeta
        Text(
          "Dirección de la tarjeta",
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Código postal y botón Buscar
        StreamBuilder<DireccionStatus>(
          stream: direccionBloc.statusStream,
          initialData: direccionBloc.status,
          builder: (context, statusSnapshot) {
            final direccionStatus = statusSnapshot.data ?? DireccionStatus.initial;
            final isLoading = direccionStatus == DireccionStatus.loading;

            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _codigoPostalController,
                    style: TextStyle(color: textColor),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: fillColor,
                      hintText: "12345",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      labelText: "Código postal",
                      labelStyle: TextStyle(
                        color: labelColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                    onEditingComplete: () {
                      // Consultar cuando el usuario termine de escribir
                      if (_codigoPostalController.text.trim().length == 5) {
                        _buscarDireccion();
                      }
                    },
                    onSubmitted: (value) {
                      // Consultar cuando el usuario presione enter
                      if (value.trim().length == 5) {
                        _buscarDireccion();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: FilledButton(
                    onPressed: (_codigoPostalController.text.trim().length == 5 &&
                            !isLoading)
                        ? _buscarDireccion
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF205AA8),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey[400],
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Buscar",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
        // Campos de dirección (solo se muestran después de buscar)
        if (_direccionHabilitada) ...[
          const SizedBox(height: 16),
          // Estado (solo lectura)
          Text(
            "Estado",
            style: TextStyle(
              color: labelColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _estadoController,
            style: TextStyle(color: textColor),
            readOnly: true,
            enabled: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          // Municipio (Dropdown)
          Text(
            "Municipio",
            style: TextStyle(
              color: labelColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.0),
            ),
            child: DropdownButtonFormField<String>(
              value: _municipioSeleccionado,
              decoration: InputDecoration(
                filled: true,
                fillColor: fillColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
                ),
              ),
              dropdownColor: fillColor,
              style: TextStyle(color: textColor),
              icon: Icon(Icons.arrow_drop_down, color: textColor),
              items: _municipios.map((String municipio) {
                return DropdownMenuItem<String>(
                  value: municipio,
                  child: Text(municipio),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _municipioSeleccionado = newValue;
                  // Limpiar colonia cuando cambia el municipio
                  _coloniaSeleccionada = null;
                });
              },
              hint: Text(
                'Selecciona un municipio',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Colonia (Dropdown)
          Text(
            "Colonia",
            style: TextStyle(
              color: labelColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.0),
            ),
            child: DropdownButtonFormField<String>(
              value: _coloniaSeleccionada,
              decoration: InputDecoration(
                filled: true,
                fillColor: fillColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
                ),
              ),
              dropdownColor: fillColor,
              style: TextStyle(color: textColor),
              icon: Icon(Icons.arrow_drop_down, color: textColor),
              items: _colonias.map((String colonia) {
                return DropdownMenuItem<String>(
                  value: colonia,
                  child: Text(colonia),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _coloniaSeleccionada = newValue;
                });
              },
              hint: Text(
                'Selecciona una colonia',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Calle y número exterior
          Text(
            "Calle y número exterior",
            style: TextStyle(
              color: labelColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _calleController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor,
              hintText: "Calle, número, edificio, etc.",
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSaveButton() {
    return StreamBuilder<TokenizationStatus>(
      stream: netPayTokenizationBloc.statusStream,
      initialData: netPayTokenizationBloc.status,
      builder: (context, statusSnapshot) {
        final status = statusSnapshot.data ?? TokenizationStatus.initial;
        
        // También verificar el estado de asignación
        return StreamBuilder<NetPayStatus>(
          stream: netPayBloc.statusStream,
          initialData: netPayBloc.currentStatus,
          builder: (context, assignStatusSnapshot) {
            final assignStatus = assignStatusSnapshot.data ?? NetPayStatus.idle;
            
            // El botón debe estar deshabilitado durante tokenización, creación de cliente o asignación
            final isLoading = status == TokenizationStatus.loading || 
                            assignStatus == NetPayStatus.tokenizing ||
                            assignStatus == NetPayStatus.creating ||
                            assignStatus == NetPayStatus.assigning;
            
            // Mensajes más descriptivos para mejor UX
            final buttonText = assignStatus == NetPayStatus.creating
                ? 'Creando cuenta...'
                : assignStatus == NetPayStatus.assigning 
                    ? 'Guardando tarjeta...'
                    : status == TokenizationStatus.loading
                        ? 'Procesando tarjeta...'
                        : 'Guardar tarjeta';

            return StreamBuilder<String?>(
              stream: netPayTokenizationBloc.errorStream,
              initialData: netPayTokenizationBloc.errorMessage,
              builder: (context, errorSnapshot) {
                final error = errorSnapshot.data;

                return Column(
                  children: [
                    if (error != null &&
                        status == TokenizationStatus.error &&
                        _esErrorFallbackRedTokenizacion(error) &&
                        !_mostradoInfoTokenizacion)
                      Builder(
                        builder: (_) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted || _mostradoInfoTokenizacion) return;
                            _mostradoInfoTokenizacion = true;
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.info,
                              title: 'Servicio temporalmente no disponible',
                              text:
                                  'No pudimos conectar con el servicio de tokenizacion de tarjetas. Verifica tu conexion e intenta nuevamente en unos momentos.',
                              confirmBtnText: 'Aceptar',
                            );
                          });
                          return const SizedBox.shrink();
                        },
                      ),
                    // Botón de guardar
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isLoading ? null : _handlePayment,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF205AA8),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey[400],
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                buttonText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    // Manejar éxito de tokenización y asignación
                    StreamBuilder<CardTokenResponse?>(
                      stream: netPayTokenizationBloc.tokenStream,
                      builder: (context, tokenSnapshot) {
                        final tokenResponse = tokenSnapshot.data;
                        if (status == TokenizationStatus.success && 
                            tokenResponse != null && 
                            !_procesandoAsignacion &&
                            _ultimoTokenProcesado != tokenResponse.token &&
                            !_mostradoMensajeExito) {
                          // Ejecutar la asignación después de tokenizar (solo una vez)
                          _procesandoAsignacion = true;
                          _ultimoTokenProcesado = tokenResponse.token;
                          _mostradoMensajeExito = false; // Aún no se ha mostrado el éxito
                          _mostradoMensajeError = false; // Resetear flag de error
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && _procesandoAsignacion) {
                              _handleTokenizationSuccess(tokenResponse);
                            }
                          });
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    // Manejar estado de asignación
                    StreamBuilder<String?>(
                      stream: netPayBloc.errorStream,
                      builder: (context, assignErrorSnapshot) {
                        final assignError = assignErrorSnapshot.data;
                        
                        if (assignStatus == NetPayStatus.success && !_mostradoMensajeExito) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            // Solo mostrar el éxito si ya se completó la tokenización y no se ha mostrado antes
                            if (mounted && 
                                status == TokenizationStatus.success && 
                                _procesandoAsignacion && 
                                !_mostradoMensajeExito) {
                              _procesandoAsignacion = false; // Resetear flag
                              _mostradoMensajeExito = true; // Marcar como mostrado
                              _mostradoMensajeError = false; // Resetear flag de error
                              // Limpiar datos sensibles ahora que todo terminó exitosamente
                              _clearSensitiveData();
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.success,
                                title: '¡Éxito!',
                                text: 'Tarjeta agregada correctamente',
                                confirmBtnText: 'Aceptar',
                                onConfirmBtnTap: () {
                                  Navigator.pop(context);
                                  // Forzar recarga de tarjetas después de agregar una nueva
                                  final wallet = monederoBloc.wallet;
                                  if (wallet != null && wallet.customerIdNetPay != null && wallet.customerIdNetPay!.isNotEmpty) {
                                    // Forzar recarga para obtener la nueva tarjeta
                                    netPayBloc.obtenerClienteNetPay(wallet.customerIdNetPay!, forceRefresh: true);
                                  }
                                  // Navegar a métodos de pago
                                  if (mounted) {
                                    GoRouter.of(context).go(RoutesName.metodosPago);
                                  }
                                },
                              );
                            }
                          });
                        }
                        
                        // Solo mostrar error si no hay una respuesta exitosa en progreso
                        // Esperar un momento para ver si llega una respuesta exitosa después de un timeout
                        if (assignStatus == NetPayStatus.error && 
                            assignError != null && 
                            status == TokenizationStatus.success &&
                            !_mostradoMensajeError &&
                            !_mostradoMensajeExito &&
                            !_validandoErrorAsignacion &&
                            assignStatus != NetPayStatus.assigning) {
                          // Bloquear inmediatamente para evitar loop de callbacks en cada rebuild
                          _validandoErrorAsignacion = true;
                          // Esperar un poco antes de mostrar el error por si hay una respuesta exitosa pendiente
                          WidgetsBinding.instance.addPostFrameCallback((_) async {
                            // Esperar 1 segundo para ver si llega una respuesta exitosa
                            await Future.delayed(const Duration(milliseconds: 1000));
                            
                            // Verificar nuevamente el estado después de la espera
                            final currentAssignStatus = netPayBloc.currentStatus;
                            
                            if (mounted && 
                                _procesandoAsignacion && 
                                !_mostradoMensajeError &&
                                !_mostradoMensajeExito &&
                                currentAssignStatus != NetPayStatus.success &&
                                currentAssignStatus != NetPayStatus.assigning) {
                              _procesandoAsignacion = false; // Resetear flag
                              _mostradoMensajeError = true; // Marcar como mostrado
                              // Mejorar el mensaje de error si es un 504 de NetPay o timeout
                              String mensajeError = assignError;
                              if (assignError.contains('504') || assignError.contains('Netpay')) {
                                mensajeError = 'El servicio de pagos no está disponible en este momento. Por favor, intenta nuevamente más tarde.';
                              } else if (assignError.contains('Tiempo de espera') || 
                                        assignError.contains('timeout') ||
                                        assignError.contains('conexión') ||
                                        assignError.contains('internet')) {
                                mensajeError = 'La conexión está tardando demasiado. Por favor, verifica tu conexión a internet e intenta nuevamente.';
                              }
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.error,
                                title: 'Error',
                                text: mensajeError,
                                confirmBtnText: 'Aceptar',
                              );
                              netPayBloc.limpiar();
                            }

                            // Liberar el lock; si hay un nuevo intento se reseteará también en _resetProcessingFlags
                            _validandoErrorAsignacion = false;
                          });
                        }
                        
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  /// Maneja el proceso de pago/tokenización
  Future<void> _handlePayment() async {
    // Resetear flags al iniciar un nuevo proceso
    _resetProcessingFlags();
    
    // Validar campos requeridos
    if (!_validateForm()) {
      return;
    }

    try {
      // Crear request de tokenización
      final nombreCompleto = '${_nombresController.text.trim()} ${_apellidosController.text.trim()}'.trim();
      
      // Asegurar que el año tenga 2 dígitos (ya está limitado a 2 en el TextField)
      String year = _anoController.text.trim().padLeft(2, '0');

      // Preparar datos de dirección
      final direccionCompleta = _calleController.text.trim();
      final estado = _estadoController.text.trim();
      final municipio = _municipioSeleccionado ?? '';
      final colonia = _coloniaSeleccionada ?? '';
      final codigoPostal = _codigoPostalController.text.trim();
      
      // Construir ciudad (municipio, colonia)
      String? ciudad;
      if (municipio.isNotEmpty && colonia.isNotEmpty) {
        ciudad = '$municipio, $colonia';
      } else if (municipio.isNotEmpty) {
        ciudad = municipio;
      } else if (colonia.isNotEmpty) {
        ciudad = colonia;
      }

      final request = CardTokenRequest(
        cardNumber: _numeroController.text.replaceAll(' ', ''),
        cardholderName: nombreCompleto,
        expirationMonth: _mesController.text.trim().padLeft(2, '0'),
        expirationYear: year,
        cvv: _cvvController.text.trim(),
        street: direccionCompleta.isNotEmpty ? direccionCompleta : null,
        city: ciudad,
        state: estado.isNotEmpty ? estado : null,
        postalCode: codigoPostal.isNotEmpty ? codigoPostal : null,
        country: 'MX', // México
      );

      // Tokenizar la tarjeta
      await netPayTokenizationBloc.tokenizeCard(request);
    } catch (e) {
      // El error ya se maneja en el BLoC
    }
  }

  /// Valida el formulario antes de procesar el pago
  bool _validateForm() {
    // Validar nombres
    if (_nombresController.text.trim().isEmpty) {
      _showError('Por favor ingresa tu nombre');
      return false;
    }
    if (!isSoloLetras(_nombresController.text.trim())) {
      _showError('El nombre solo puede contener letras (sin números ni caracteres especiales)');
      return false;
    }

    // Validar apellidos
    if (_apellidosController.text.trim().isEmpty) {
      _showError('Por favor ingresa tus apellidos');
      return false;
    }
    if (!isSoloLetras(_apellidosController.text.trim())) {
      _showError('Los apellidos solo pueden contener letras (sin números ni caracteres especiales)');
      return false;
    }

    // Validar correo
    if (_correoController.text.trim().isEmpty) {
      _showError('Por favor ingresa tu correo electrónico');
      return false;
    }
    if (!isValidEmail(_correoController.text.trim())) {
      _showError('Por favor ingresa un correo electrónico válido');
      return false;
    }

    // Validar teléfono
    if (_telefonoController.text.trim().length != 10) {
      _showError('Por favor ingresa un teléfono válido de 10 dígitos');
      return false;
    }

    // Validar número de tarjeta
    final cardNumber = _numeroController.text.replaceAll(' ', '');
    if (cardNumber.isEmpty || !CardValidator.isValidCardNumber(cardNumber)) {
      _showError('Por favor ingresa un número de tarjeta válido');
      return false;
    }

    // Validar mes
    if (_mesController.text.trim().isEmpty || !CardValidator.isValidMonth(_mesController.text.trim())) {
      _showError('Por favor ingresa un mes válido');
      return false;
    }

    // Validar año
    if (_anoController.text.trim().isEmpty || !CardValidator.isValidYear(_anoController.text.trim())) {
      _showError('Por favor ingresa un año válido');
      return false;
    }

    // Validar fecha de expiración
    if (!CardValidator.isExpirationDateValid(_mesController.text.trim(), _anoController.text.trim())) {
      _showError('La fecha de expiración no es válida o está vencida');
      return false;
    }

    // Validar CVV
    final cardType = CardValidator.detectCardType(cardNumber);
    if (_cvvController.text.trim().isEmpty || 
        !CardValidator.isValidCVV(_cvvController.text.trim(), cardType)) {
      _showError('Por favor ingresa un código CVV válido');
      return false;
    }

    return true;
  }

  /// Muestra un error
  void _showError(String message) {
    // El error se mostrará a través del StreamBuilder
    // Usar un método público o mostrar directamente
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Maneja el éxito de la tokenización y ejecuta la asignación del token
  Future<void> _handleTokenizationSuccess(CardTokenResponse response) async {
    // Verificar nuevamente para prevenir múltiples ejecuciones
    if (_procesandoAsignacion == false) {
      return;
    }
    
    if (kDebugMode) {
      SecureLog.d('✅ Tokenización completada exitosamente');
      SecureLog.dToken('✅ Token', response.token);
    }

    // Obtener wallet para conseguir customerIdNetPay
    final wallet = monederoBloc.wallet;
    if (wallet == null) {
      _procesandoAsignacion = false; // Resetear flag
      _clearSensitiveData();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'No se pudo obtener la información del wallet. Por favor, intenta nuevamente.',
        confirmBtnText: 'Aceptar',
      );
      return;
    }

    // Obtener datos del usuario
    final user = authBloc.currentUser;
    if (user == null) {
      _procesandoAsignacion = false; // Resetear flag
      _mostradoMensajeExito = false;
      _mostradoMensajeError = false;
      _clearSensitiveData();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'No se pudo obtener la información del usuario. Por favor, inicia sesión nuevamente.',
        confirmBtnText: 'Aceptar',
      );
      return;
    }

    // Preparar datos del formulario
    final nombre = _nombresController.text.trim().isNotEmpty 
        ? _nombresController.text.trim() 
        : user.nombre;
    
    // Separar apellidos si vienen juntos (ej: "Pérez García")
    final apellidosCompletos = _apellidosController.text.trim().isNotEmpty
        ? _apellidosController.text.trim()
        : '${user.apellidoPaterno} ${user.apellidoMaterno ?? ""}'.trim();
    final partesApellidos = apellidosCompletos.split(' ');
    final apellidoPaterno = partesApellidos.isNotEmpty ? partesApellidos.first : user.apellidoPaterno;
    final apellidoMaterno = partesApellidos.length > 1 
        ? partesApellidos.skip(1).join(' ') 
        : (user.apellidoMaterno ?? '');
    
    final email = _correoController.text.trim().isNotEmpty
        ? _correoController.text.trim()
        : wallet.correoUsuario; // Usar email del wallet si no hay en formulario
    final telefono = _telefonoController.text.trim().isNotEmpty
        ? _telefonoController.text.trim()
        : user.telefono ?? '';

    // Validar que tenemos los datos mínimos requeridos
    if (nombre.isEmpty || apellidoPaterno.isEmpty || email.isEmpty || telefono.isEmpty) {
      _procesandoAsignacion = false; // Resetear flag
      _mostradoMensajeExito = false;
      _mostradoMensajeError = false;
      _clearSensitiveData();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Faltan datos requeridos. Por favor completa todos los campos del formulario.',
        confirmBtnText: 'Aceptar',
      );
      return;
    }

    String customerId;

    // Verificar si customerIdNetPay es null - Si es null, crear cliente primero
    if (wallet.customerIdNetPay == null || wallet.customerIdNetPay!.isEmpty) {

      try {
        // Crear cliente en NetPay
        customerId = await netPayBloc.crearClienteNetPay(
          firstName: nombre,
          lastName: apellidoPaterno,
          email: email,
          phone: telefono,
          token: response.token,
          idPasajero: wallet.idPasajero,
        );


        // Actualizar el wallet para obtener el nuevo customerIdNetPay
        // Esto es importante para que en futuras operaciones ya tenga el customerId
        await monederoBloc.obtenerWallet();
        
        // Verificar que el wallet ahora tiene el customerIdNetPay
        final updatedWallet = monederoBloc.wallet;
        if (updatedWallet == null || updatedWallet.customerIdNetPay == null || updatedWallet.customerIdNetPay!.isEmpty) {
          // Continuar con el customerId recibido del servicio
        } else {
          // Usar el customerId del wallet actualizado
          customerId = updatedWallet.customerIdNetPay!;
        }
      } catch (e) {
        _procesandoAsignacion = false; // Resetear flag en caso de error
        _mostradoMensajeExito = false;
        _mostradoMensajeError = false;
        _clearSensitiveData();
        if (mounted && !_mostradoMensajeError && !_mostradoMensajeExito) {
          _mostradoMensajeError = true;
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Error al crear cliente',
            text: e.toString().replaceAll('Exception: ', ''),
            confirmBtnText: 'Aceptar',
          );
        }
        return;
      }
    } else {
      // Si ya existe customerIdNetPay, usarlo directamente
      customerId = wallet.customerIdNetPay!;
    }

    // Preparar datos para la asignación
    final tokenCard = response.token;
    final cvv2 = _cvvController.text.trim();

    // Preparar dirección si está disponible
    DireccionData? direccion;
    if (_direccionHabilitada && 
        _estadoController.text.trim().isNotEmpty &&
        _codigoPostalController.text.trim().isNotEmpty &&
        _calleController.text.trim().isNotEmpty) {
      final municipio = _municipioSeleccionado ?? '';
      final colonia = _coloniaSeleccionada ?? '';
      String? ciudad;
      if (municipio.isNotEmpty && colonia.isNotEmpty) {
        ciudad = '$municipio, $colonia';
      } else if (municipio.isNotEmpty) {
        ciudad = municipio;
      } else if (colonia.isNotEmpty) {
        ciudad = colonia;
      }
      
      if (ciudad != null) {
        direccion = DireccionData(
          ciudad: ciudad,
          pais: 'MX',
          cp: _codigoPostalController.text.trim(),
          estado: _estadoController.text.trim(),
          calle: _calleController.text.trim(),
          calleEsquina: null, // No tenemos este campo en el formulario
          colonia: colonia.isNotEmpty ? colonia : null,
        );
      }
    }

      // Ejecutar la asignación del token
    try {
      await netPayBloc.asignarTokenTarjeta(
        customerId: customerId,
        tokenCard: tokenCard,
        cvv2: cvv2,
        nombre: nombre,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
        email: email,
        telefono: telefono,
        direccion: direccion,
        idDireccion: null,
      );

      // NO limpiar datos sensibles aquí - se limpiarán después de mostrar el éxito
      // El éxito o error se manejará en el listener del stream
      // El flag se reseteará cuando se muestre el mensaje de éxito/error
    } catch (e) {
      _procesandoAsignacion = false; // Resetear flag en caso de error
      _mostradoMensajeExito = false;
      _mostradoMensajeError = false;
      // Solo limpiar datos sensibles si el widget sigue montado
      if (mounted) {
        _clearSensitiveData();
      }
      if (mounted && !_mostradoMensajeError && !_mostradoMensajeExito) {
        _mostradoMensajeError = true;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Error al asignar la tarjeta. Por favor, intenta nuevamente.',
          confirmBtnText: 'Aceptar',
        );
      }
    }
  }

  /// Limpia todos los datos sensibles del formulario
  /// 
  /// IMPORTANTE: Esto debe ejecutarse inmediatamente después de tokenizar
  /// Solo se ejecuta si el widget sigue montado para evitar errores de disposed controllers
  void _clearSensitiveData() {
    // Verificar que el widget sigue montado antes de limpiar
    if (!mounted) {
      return;
    }
    
    // Verificar que los controllers no estén disposed antes de usarlos
    try {
      if (_numeroController.hasListeners || _numeroController.text.isNotEmpty) {
        _numeroController.clear();
      }
      if (_mesController.hasListeners || _mesController.text.isNotEmpty) {
        _mesController.clear();
      }
      if (_anoController.hasListeners || _anoController.text.isNotEmpty) {
        _anoController.clear();
      }
      if (_cvvController.hasListeners || _cvvController.text.isNotEmpty) {
        _cvvController.clear();
      }
    } catch (e) {
      // Si los controllers ya están disposed, ignorar el error
    }
    
    // Resetear el BLoC
    netPayTokenizationBloc.reset();
  }
  
  /// Resetea los flags de procesamiento (llamar cuando se inicia un nuevo intento)
  void _resetProcessingFlags() {
    _procesandoAsignacion = false;
    _mostradoMensajeExito = false;
    _mostradoMensajeError = false;
    _validandoErrorAsignacion = false;
    _ultimoTokenProcesado = null;
    _mostradoInfoTokenizacion = false;
  }

  bool _esErrorFallbackRedTokenizacion(String error) {
    final msg = error.toLowerCase();
    return msg.contains('netpayjs no esta cargado') ||
        msg.contains('netpayjs no se pudo cargar') ||
        msg.contains('tiempo de espera agotado') ||
        msg.contains('timeout') ||
        msg.contains('conexion') ||
        msg.contains('internet') ||
        msg.contains('network');
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

