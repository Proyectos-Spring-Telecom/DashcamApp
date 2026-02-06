// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickalert/quickalert.dart';
import 'package:dashboardpro/widgets/nfc_reader_widget.dart';
import 'package:dashboardpro/model/monedero/monedero_request.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:intl/intl.dart';

class MonederosPage extends StatefulWidget {
  const MonederosPage({super.key});

  @override
  State<MonederosPage> createState() => _MonederosPageState();
}

class _MonederosPageState extends State<MonederosPage> {
  final TextEditingController _numeroSerieController = TextEditingController();
  final TextEditingController _saldoController = TextEditingController();
  final TextEditingController _idTarjetaController = TextEditingController();
  final TextEditingController _fechaActivacionController = TextEditingController();
  ClienteModel? _selectedCliente;
  PasajeroModel? _selectedPasajero;
  TipoPasajeroModel? _selectedTipoPasajero;
  DateTime? _selectedFechaActivacion;
  bool _isReadingNfc = false;

  @override
  void initState() {
    super.initState();
    // Cargar clientes, pasajeros y tipos de pasajero al iniciar
    monederoBloc.obtenerClientes();
    monederoBloc.obtenerPasajeros();
    monederoBloc.obtenerTiposPasajero();
    
    // Escuchar el estado de creación de monedero
    monederoBloc.crearMonederoStatusStream.listen((status) {
      if (status == MonederoStatus.loaded && mounted) {
        _handleRegistroExitoso();
      } else if (status == MonederoStatus.error && mounted) {
        _handleErrorRegistro();
      }
    });
  }

  @override
  void dispose() {
    _numeroSerieController.dispose();
    _saldoController.dispose();
    _idTarjetaController.dispose();
    _fechaActivacionController.dispose();
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
        final cardColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;
        final inputColor = isDark ? Colors.grey[700]! : Colors.grey[200]!;

        final systemUiOverlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemUiOverlayStyle,
          child: Scaffold(
            backgroundColor: backgroundColor,
            extendBodyBehindAppBar: true,
            drawer: _buildDrawer(context, isDark, textColor),
            body: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: backgroundColor,
                child: Column(
                  children: [
                    _buildHeader(context, textColor: textColor, isDark: isDark),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                  // Campo NÚMERO DE SERIE
                  _buildField(
                    label: 'Número de Serie',
                    icon: Icons.credit_card,
                    child: TextField(
                      controller: _numeroSerieController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Número de Serie',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: inputColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    isDark: isDark,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 24.0),

                  // Campo SALDO
                  _buildField(
                    label: 'Saldo',
                    icon: Icons.account_balance_wallet,
                    child: TextField(
                      controller: _saldoController,
                      style: TextStyle(color: textColor),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Saldo',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixText: '\$ ',
                        prefixStyle: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        filled: true,
                        fillColor: inputColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    isDark: isDark,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 24.0),

                  // Campo CLIENTE (Dropdown)
                  _buildClienteDropdown(isDark: isDark, textColor: textColor, inputColor: inputColor),
                  const SizedBox(height: 24.0),

                  // Campo PASAJERO (Dropdown)
                  _buildPasajeroDropdown(isDark: isDark, textColor: textColor, inputColor: inputColor),
                  const SizedBox(height: 24.0),

                  // Campo TIPO PASAJERO (Dropdown)
                  _buildTipoPasajeroDropdown(isDark: isDark, textColor: textColor, inputColor: inputColor),
                  const SizedBox(height: 24.0),

                  // Campo FECHA DE ACTIVACIÓN
                  _buildField(
                    label: 'Fecha de Activación',
                    icon: Icons.calendar_today,
                    child: TextField(
                      controller: _fechaActivacionController,
                      style: TextStyle(color: textColor),
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Seleccionar fecha',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: inputColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ),
                      onTap: () => _selectFechaActivacion(context, isDark, textColor),
                    ),
                    isDark: isDark,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 24.0),

                  // Campo ID TARJETA (NFC)
                  _buildField(
                    label: 'ID Tarjeta',
                    icon: Icons.credit_card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _idTarjetaController,
                          style: TextStyle(color: textColor),
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'Acerca la tarjeta NFC para leer el ID',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: inputColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            suffixIcon: Icon(
                              Icons.nfc,
                              color: _idTarjetaController.text.isNotEmpty 
                                  ? const Color(0xFFA6CE39) 
                                  : Colors.grey[400],
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (!_isReadingNfc)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _idTarjetaController.text.isEmpty 
                                  ? _startNfcReading 
                                  : null,
                              icon: Icon(
                                Icons.nfc,
                                color: _idTarjetaController.text.isNotEmpty 
                                    ? Colors.grey 
                                    : const Color(0xFF205AA8),
                              ),
                              label: Text(
                                _idTarjetaController.text.isNotEmpty 
                                    ? 'ID leído: ${_idTarjetaController.text}' 
                                    : 'Leer Tarjeta NFC',
                                style: TextStyle(
                                  color: _idTarjetaController.text.isNotEmpty 
                                      ? Colors.grey 
                                      : const Color(0xFF205AA8),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: _idTarjetaController.text.isNotEmpty 
                                      ? Colors.grey 
                                      : const Color(0xFF205AA8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        if (_isReadingNfc) ...[
                          NfcReaderWidget(
                            autoStart: true,
                            onCardRead: _handleNfcCardRead,
                          ),
                        ],
                      ],
                    ),
                    isDark: isDark,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 32.0),

                  // Botón Registrar Monedero
                  StreamBuilder<MonederoStatus>(
                    stream: monederoBloc.crearMonederoStatusStream,
                    initialData: monederoBloc.crearMonederoStatus,
                    builder: (context, snapshot) {
                      final status = snapshot.data ?? MonederoStatus.initial;
                      final isLoading = status == MonederoStatus.loading;
                      
                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: isLoading ? null : _handleRegistrarMonedero,
                          style: FilledButton.styleFrom(
                            backgroundColor: isLoading 
                                ? Colors.grey 
                                : const Color(0xFF205AA8),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Registrar Monedero',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    Color textColor = Colors.black,
    bool isDark = false,
  }) {
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
          // Menu button to open drawer
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: textColor),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          // Title
          Expanded(
            child: Text(
              "Monederos",
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

  Widget _buildField({
    required String label,
    required IconData icon,
    required Widget child,
    required bool isDark,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFA6CE39),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildClienteDropdown({
    required bool isDark,
    required Color textColor,
    required Color inputColor,
  }) {
    return StreamBuilder<MonederoStatus>(
      stream: monederoBloc.clientesStatusStream,
      initialData: monederoBloc.clientesStatus,
      builder: (context, statusSnapshot) {
        final status = statusSnapshot.data ?? MonederoStatus.initial;
        
        return StreamBuilder<List<ClienteModel>>(
          stream: monederoBloc.clientesStream,
          initialData: monederoBloc.clientes,
          builder: (context, clientesSnapshot) {
            final clientes = clientesSnapshot.data ?? [];
            
            // Mostrar error si hay
            if (status == MonederoStatus.error) {
              return StreamBuilder<String?>(
                stream: monederoBloc.clientesErrorStream,
                initialData: monederoBloc.clientesErrorMessage,
                builder: (context, errorSnapshot) {
                  return _buildField(
                    label: 'Cliente',
                    icon: Icons.person,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorSnapshot.data ?? 'Error al cargar clientes',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    isDark: isDark,
                    textColor: textColor,
                  );
                },
              );
            }
            
            // Mostrar loader si está cargando
            if (status == MonederoStatus.loading) {
              return _buildField(
                label: 'Cliente',
                icon: Icons.person,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: inputColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF205AA8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Cargando clientes...',
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                isDark: isDark,
                textColor: textColor,
              );
            }
            
            // Dropdown con datos
            return _buildField(
              label: 'Cliente',
              icon: Icons.person,
              child: Container(
                decoration: BoxDecoration(
                  color: inputColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ClienteModel>(
                    value: _selectedCliente,
                    isExpanded: true,
                    style: TextStyle(color: textColor),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: textColor,
                    ),
                    hint: Text(
                      'Cliente',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    items: clientes.map((ClienteModel cliente) {
                      return DropdownMenuItem<ClienteModel>(
                        value: cliente,
                        child: Text(cliente.nombreCompleto),
                      );
                    }).toList(),
                    onChanged: (ClienteModel? newValue) {
                      setState(() {
                        _selectedCliente = newValue;
                      });
                    },
                  ),
                ),
              ),
              isDark: isDark,
              textColor: textColor,
            );
          },
        );
      },
    );
  }

  Widget _buildPasajeroDropdown({
    required bool isDark,
    required Color textColor,
    required Color inputColor,
  }) {
    return StreamBuilder<MonederoStatus>(
      stream: monederoBloc.pasajerosStatusStream,
      initialData: monederoBloc.pasajerosStatus,
      builder: (context, statusSnapshot) {
        final status = statusSnapshot.data ?? MonederoStatus.initial;
        
        return StreamBuilder<List<PasajeroModel>>(
          stream: monederoBloc.pasajerosStream,
          initialData: monederoBloc.pasajeros,
          builder: (context, pasajerosSnapshot) {
            final pasajeros = pasajerosSnapshot.data ?? [];
            
            // Mostrar error si hay
            if (status == MonederoStatus.error) {
              return StreamBuilder<String?>(
                stream: monederoBloc.pasajerosErrorStream,
                initialData: monederoBloc.pasajerosErrorMessage,
                builder: (context, errorSnapshot) {
                  return _buildField(
                    label: 'Pasajero (Opcional)',
                    icon: Icons.people,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorSnapshot.data ?? 'Error al cargar pasajeros',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    isDark: isDark,
                    textColor: textColor,
                  );
                },
              );
            }
            
            // Mostrar loader si está cargando
            if (status == MonederoStatus.loading) {
              return _buildField(
                label: 'Pasajero (Opcional)',
                icon: Icons.people,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: inputColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF205AA8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Cargando pasajeros...',
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                isDark: isDark,
                textColor: textColor,
              );
            }
            
            // Dropdown con datos
            return _buildField(
              label: 'Pasajero (Opcional)',
              icon: Icons.people,
              child: Container(
                decoration: BoxDecoration(
                  color: inputColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<PasajeroModel>(
                    value: _selectedPasajero,
                    isExpanded: true,
                    style: TextStyle(color: textColor),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: textColor,
                    ),
                    hint: Text(
                      'Pasajero',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    items: pasajeros.map((PasajeroModel pasajero) {
                      return DropdownMenuItem<PasajeroModel>(
                        value: pasajero,
                        child: Text(pasajero.nombreCompleto),
                      );
                    }).toList(),
                    onChanged: (PasajeroModel? newValue) {
                      setState(() {
                        _selectedPasajero = newValue;
                      });
                    },
                  ),
                ),
              ),
              isDark: isDark,
              textColor: textColor,
            );
          },
        );
      },
    );
  }

  Widget _buildTipoPasajeroDropdown({
    required bool isDark,
    required Color textColor,
    required Color inputColor,
  }) {
    return StreamBuilder<MonederoStatus>(
      stream: monederoBloc.tiposPasajeroStatusStream,
      initialData: monederoBloc.tiposPasajeroStatus,
      builder: (context, statusSnapshot) {
        final status = statusSnapshot.data ?? MonederoStatus.initial;
        
        return StreamBuilder<List<TipoPasajeroModel>>(
          stream: monederoBloc.tiposPasajeroStream,
          initialData: monederoBloc.tiposPasajero,
          builder: (context, tiposPasajeroSnapshot) {
            final tiposPasajero = tiposPasajeroSnapshot.data ?? [];
            
            // Mostrar error si hay
            if (status == MonederoStatus.error) {
              return StreamBuilder<String?>(
                stream: monederoBloc.tiposPasajeroErrorStream,
                initialData: monederoBloc.tiposPasajeroErrorMessage,
                builder: (context, errorSnapshot) {
                  return _buildField(
                    label: 'Tipo Pasajero',
                    icon: Icons.category,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorSnapshot.data ?? 'Error al cargar tipos de pasajero',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    isDark: isDark,
                    textColor: textColor,
                  );
                },
              );
            }
            
            // Mostrar loader si está cargando
            if (status == MonederoStatus.loading) {
              return _buildField(
                label: 'TIPO PASAJERO',
                icon: Icons.category,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: inputColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF205AA8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Cargando tipos de pasajero...',
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                isDark: isDark,
                textColor: textColor,
              );
            }
            
            // Dropdown con datos
            return _buildField(
              label: 'Tipo Pasajero',
              icon: Icons.category,
              child: Container(
                decoration: BoxDecoration(
                  color: inputColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<TipoPasajeroModel>(
                    value: _selectedTipoPasajero,
                    isExpanded: true,
                    style: TextStyle(color: textColor),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: textColor,
                    ),
                    hint: Text(
                      'Tipo Pasajero',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    items: tiposPasajero.map((TipoPasajeroModel tipoPasajero) {
                      return DropdownMenuItem<TipoPasajeroModel>(
                        value: tipoPasajero,
                        child: Text(tipoPasajero.nombre),
                      );
                    }).toList(),
                    onChanged: (TipoPasajeroModel? newValue) {
                      setState(() {
                        _selectedTipoPasajero = newValue;
                      });
                    },
                  ),
                ),
              ),
              isDark: isDark,
              textColor: textColor,
            );
          },
        );
      },
    );
  }

  Future<void> _selectFechaActivacion(BuildContext context, bool isDark, Color textColor) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFechaActivacion ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF205AA8),
              onPrimary: Colors.white,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedFechaActivacion = picked;
        _fechaActivacionController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _startNfcReading() {
    setState(() {
      _isReadingNfc = true;
    });
  }

  bool _handleNfcCardRead(String cardId) {
    if (kDebugMode) {
      debugPrint('🔵 Tarjeta NFC leída: $cardId');
    }

    if (!mounted) {
      if (kDebugMode) {
        debugPrint('⚠️ Widget no montado, ignorando');
      }
      return false;
    }

    setState(() {
      _idTarjetaController.text = cardId.trim();
      _isReadingNfc = false;
    });

    // Retornar true para indicar que se procesó correctamente
    return true;
  }

  void _handleRegistrarMonedero() {
    // Validar campos
    if (_numeroSerieController.text.trim().isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Campo requerido',
        text: 'Por favor, ingresa el número de serie',
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF205AA8),
      );
      return;
    }

    if (_saldoController.text.trim().isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Campo requerido',
        text: 'Por favor, ingresa el saldo',
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF205AA8),
      );
      return;
    }

    final saldo = double.tryParse(_saldoController.text.trim());
    if (saldo == null || saldo < 0) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Saldo inválido',
        text: 'Por favor, ingresa un saldo válido',
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF205AA8),
      );
      return;
    }

    if (_selectedFechaActivacion == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Campo requerido',
        text: 'Por favor, selecciona la fecha de activación',
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF205AA8),
      );
      return;
    }

    if (_selectedCliente == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Campo requerido',
        text: 'Por favor, selecciona un cliente',
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF205AA8),
      );
      return;
    }

    // Pasajero es opcional, no se valida

    if (_selectedTipoPasajero == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Campo requerido',
        text: 'Por favor, selecciona un tipo de pasajero',
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF205AA8),
      );
      return;
    }

    if (_idTarjetaController.text.trim().isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Campo requerido',
        text: 'Por favor, lee el ID de la tarjeta NFC',
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF205AA8),
      );
      return;
    }

    // Crear el request
    final request = MonederoRequest(
      numeroSerie: _numeroSerieController.text.trim(),
      saldo: saldo,
      fechaActivacion: _selectedFechaActivacion!,
      estatus: 1, // Estatus activo
      idPasajero: _selectedPasajero?.id, // Opcional
      idCliente: _selectedCliente!.id,
      idTipoPasajero: _selectedTipoPasajero!.id,
      idCard: _idTarjetaController.text.trim(),
    );

    // Llamar al BLoC para crear el monedero
    monederoBloc.crearMonedero(request);
  }

  void _handleRegistroExitoso() {
    final response = monederoBloc.crearMonederoResponse;
    if (response != null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Monedero creado',
        text: response.message.isEmpty 
            ? 'El monedero se creó exitosamente.' 
            : response.message,
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF205AA8),
        onConfirmBtnTap: () {
          Navigator.pop(context);
          _limpiarFormulario();
        },
      );
    }
  }

  void _handleErrorRegistro() {
    final errorMessage = monederoBloc.crearMonederoErrorMessage;
    if (errorMessage != null && mounted) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error al crear monedero',
        text: errorMessage,
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF205AA8),
      );
    }
  }

  void _limpiarFormulario() {
    setState(() {
      _numeroSerieController.clear();
      _saldoController.clear();
      _fechaActivacionController.clear();
      _idTarjetaController.clear();
      _selectedCliente = null;
      _selectedPasajero = null;
      _selectedTipoPasajero = null;
      _selectedFechaActivacion = null;
      _isReadingNfc = false;
    });
  }

  Widget _buildDrawer(BuildContext context, bool isDark, Color textColor) {
    return Drawer(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20.0),
              child: StreamBuilder<User?>(
                stream: authBloc.userStream,
                builder: (context, userSnapshot) {
                  final user = userSnapshot.data ?? authBloc.currentUser;
                  return Column(
                    children: [
                      UserAvatar(
                        imageUrl: user?.fotoPerfil,
                        radius: 40,
                        backgroundColor:
                            isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        iconColor: textColor,
                        iconSize: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.nombre ?? 'Usuario',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.userName ?? '',
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                  );
                },
              ),
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
                            "Movilidad Inteligente",
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
                      // Solo mostrar si es Cajero
                      if (isCajero)
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
                  color: const Color(0xFF205AA8),
                  fontSize: 16,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await authBloc.logout();
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
}

