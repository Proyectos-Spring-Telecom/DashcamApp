// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:quickalert/quickalert.dart';
import 'package:dashboardpro/widgets/nfc_reader_widget.dart';

class POSPage extends StatefulWidget {
  const POSPage({super.key});

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedMonederoId;
  bool _nfcCardProcessed = false; // Flag para saber si NFC ya procesó una tarjeta

  @override
  void initState() {
    super.initState();
    // Resetear el flag de NFC cuando se entra a POS
    _nfcCardProcessed = false;
    // Cargar monederos al iniciar
    monederoBloc.obtenerMonederos();
  }
  

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Convierte MonederoModel a Map para compatibilidad con el código existente
  Map<String, dynamic> _monederoToMap(MonederoModel monedero) {
    return {
      'id': monedero.id.toString(),
      'serie': monedero.numeroSerie,
      'pasajero': monedero.nombrePasajeroCompleto,
      'cliente': monedero.clienteNombre ?? '',
      'saldo': monedero.saldo,
      'idCard': monedero.idCard ?? '',
    };
  }

  /// Maneja la lectura de tarjeta NFC
  /// Busca un monedero con idCard igual al ID de la tarjeta leída
  /// Retorna true si se encontró el monedero, false si no
  bool _handleNfcCardRead(String cardId) {
    if (kDebugMode) {
      debugPrint('🔵 Tarjeta NFC leída: $cardId');
      debugPrint('🔵 Buscando monedero con idCard: $cardId');
    }

    if (!mounted || _nfcCardProcessed) {
      if (kDebugMode) {
        debugPrint('⚠️ Widget no montado o tarjeta ya procesada, ignorando');
      }
      return false;
    }

    // Obtener la lista de monederos
    final monederos = monederoBloc.monederos;
    
    if (monederos.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ No hay monederos disponibles');
      }
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Sin monederos',
        text: 'No hay monederos disponibles para buscar.',
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF205AA8),
      );
      return false; // Permitir que continúe la lectura
    }
    
    // Buscar monedero por idCard (comparar sin espacios y en mayúsculas para mayor flexibilidad)
    final cardIdNormalized = cardId.trim().toUpperCase();
    MonederoModel? monederoEncontrado;
    
    try {
      monederoEncontrado = monederos.firstWhere(
        (monedero) => monedero.idCard != null && 
                      monedero.idCard!.trim().toUpperCase() == cardIdNormalized,
      );
    } catch (e) {
      // Monedero no encontrado
      if (kDebugMode) {
        debugPrint('❌ Monedero con idCard $cardId no encontrado');
      }
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Monedero no encontrado',
        text: 'No se encontró un monedero con el ID de tarjeta: $cardId',
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF205AA8),
        onConfirmBtnTap: () {
          Navigator.pop(context);
          // NO marcar como procesada, permitir que la sesión NFC continúe
        },
      );
      // Retornar false para indicar que no se encontró, permitir que continúe la lectura
      return false;
    }

    if (monederoEncontrado == null) return false;

    if (kDebugMode) {
      debugPrint('✅ Monedero encontrado: ${monederoEncontrado.numeroSerie}');
    }

    // Convertir a Map
    final selectedMonedero = _monederoToMap(monederoEncontrado);
    final numeroSerie = monederoEncontrado.numeroSerie; // Guardar el valor para usar en el callback
    
    if (!mounted) return false;
    
    // Marcar como procesada antes de navegar para evitar múltiples navegaciones
    _nfcCardProcessed = true;
    
    // Mostrar mensaje de éxito
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Monedero encontrado',
      text: 'Monedero: $numeroSerie',
      confirmBtnText: 'Continuar',
      confirmBtnColor: const Color(0xFF205AA8),
      onConfirmBtnTap: () {
        Navigator.pop(context); // Cerrar el QuickAlert
        
        if (kDebugMode) {
          debugPrint('🚀 Navegando a Ingresar Monto con monedero: $numeroSerie');
        }
        
        // Navegar a Ingresar Monto después de cerrar el alert
        if (mounted) {
          GoRouter.of(context).go(
            RoutesName.ingresarMonto,
            extra: selectedMonedero,
          );
        }
      },
    );
    
    // Retornar true para indicar que se encontró el monedero
    return true;
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
            drawer: _buildDrawer(context, isDark),
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
          // Header
          _buildHeader(context, textColor: textColor, isDark: isDark),
          // Content
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Steps indicator
                _buildStepsIndicator(isDark: isDark, textColor: textColor),
                const SizedBox(height: 16.0),

                // Search field
                _buildSearchField(isDark: isDark, textColor: textColor),
                const SizedBox(height: 24.0),

                // NFC Reader Widget (inicia automáticamente)
                // Solo mostrar si no se ha procesado una tarjeta NFC
                if (!_nfcCardProcessed)
                  NfcReaderWidget(
                    autoStart: true,
                    onCardRead: (cardId) => _handleNfcCardRead(cardId) ?? false,
                  )
                else
                  const SizedBox.shrink(),
                const SizedBox(height: 24.0),

                // Monederos grid
                _buildMonederosGrid(isDark: isDark, textColor: textColor),
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
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          _buildHeader(context, textColor: textColor, isDark: isDark),
          // Content
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Steps indicator
                  _buildStepsIndicator(isDark: isDark, textColor: textColor),
                  const SizedBox(height: 16.0),

                  // Search field
                  _buildSearchField(isDark: isDark, textColor: textColor),
                  const SizedBox(height: 24.0),

                  // NFC Reader Widget (inicia automáticamente)
                  // Solo mostrar si no se ha procesado una tarjeta NFC
                  if (!_nfcCardProcessed)
                    NfcReaderWidget(
                      autoStart: true,
                      onCardRead: (cardId) => _handleNfcCardRead(cardId) ?? false,
                    )
                  else
                    const SizedBox.shrink(),
                  const SizedBox(height: 24.0),

                  // Monederos grid
                  _buildMonederosGrid(isDark: isDark, textColor: textColor),
                  const SizedBox(height: 100.0),
                ],
              ),
            ),
          ),
        ],
      ),
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
              "Realizar Pago",
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

  Widget _buildStepsIndicator({
    required bool isDark,
    required Color textColor,
  }) {
    final activeStepColor = const Color(0xFF205AA8); // Blue
    final inactiveStepColor = isDark ? Colors.grey[600] : Colors.grey[400];
    final activeTextColor = activeStepColor;
    final inactiveTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Row(
      children: [
        // Step 1 - Active
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
                        '1',
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
                          "Selecciona Monedero",
                          style: TextStyle(
                            color: activeTextColor,
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
        // Step 2 - Inactive but clickeable
        Expanded(
          child: GestureDetector(
            onTap: _selectedMonederoId != null
                ? () {
                    final monederos = monederoBloc.monederos;
                    final selectedMonederoModel = monederos.firstWhere(
                      (m) => m.id.toString() == _selectedMonederoId,
                    );
                    final selectedMonedero = _monederoToMap(selectedMonederoModel);
                    GoRouter.of(context).go(
                      RoutesName.ingresarMonto,
                      extra: selectedMonedero,
                    );
                  }
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: inactiveStepColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '2',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
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
                              color: inactiveTextColor,
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
        ),
      ],
    );
  }

  Widget _buildMonederoSection({
    required bool isDark,
    required Color textColor,
  }) {
    return Row(
      children: [
        // Wallet icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFA6CE39).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            color: Color(0xFFA6CE39),
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        // Monedero label
        Text(
          "Monedero",
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField({
    required bool isDark,
    required Color textColor,
  }) {
    final fieldColor = isDark ? Colors.grey[800] : Colors.grey[100];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textColor, fontSize: 16),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Buscar pasajero, cliente o serie...",
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonederosGrid({
    required bool isDark,
    required Color textColor,
  }) {
    return StreamBuilder<MonederoStatus>(
      stream: monederoBloc.statusStream,
      initialData: monederoBloc.status,
      builder: (context, statusSnapshot) {
        final status = statusSnapshot.data ?? MonederoStatus.initial;

        // Loading state
        if (status == MonederoStatus.loading) {
          return Center(
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
                    'Cargando monederos...',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Error state
        if (status == MonederoStatus.error) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    monederoBloc.errorMessage ??
                        'No se pudo obtener la información. Intenta más tarde.',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      monederoBloc.obtenerMonederos();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF205AA8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Loaded state - obtener monederos del stream
        return StreamBuilder<List<MonederoModel>>(
          stream: monederoBloc.monederosStream,
          initialData: monederoBloc.monederos,
          builder: (context, monederosSnapshot) {
            final monederos = monederosSnapshot.data ?? [];
            
            // Convertir MonederoModel a Map para compatibilidad
            final monederosMap = monederos.map((m) => _monederoToMap(m)).toList();

            // Lista vacía
            if (monederosMap.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay monederos disponibles',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Filtrar monederos basado en la búsqueda
            final searchTerm = _searchController.text.toLowerCase();
            final filteredMonederos = monederosMap.where((monedero) {
              final serie = monedero['serie']?.toString().toLowerCase() ?? '';
              final pasajero = monedero['pasajero']?.toString().toLowerCase() ?? '';
              final cliente = monedero['cliente']?.toString().toLowerCase() ?? '';
              return serie.contains(searchTerm) ||
                  pasajero.contains(searchTerm) ||
                  cliente.contains(searchTerm);
            }).toList();

            // Si no hay resultados después de filtrar
            if (filteredMonederos.isEmpty && searchTerm.isNotEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No se encontraron monederos',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Grid de monederos responsivo
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Calcular el número de columnas según el ancho disponible
                    final screenWidth = constraints.maxWidth;
                    int crossAxisCount;
                    double spacing;
                    double cardMainAxisExtent;

                    // Grid responsivo. El "espacio vacío" dentro de la card venía de que el Grid
                    // imponía una altura muy grande por `childAspectRatio`.
                    // Usamos `mainAxisExtent` para controlar explícitamente la altura de cada tile.
                    if (screenWidth > 1200) {
                      crossAxisCount = 4;
                      spacing = kIsWeb ? 18.0 : 20.0;
                    } else if (screenWidth > 900) {
                      crossAxisCount = 3;
                      spacing = kIsWeb ? 16.0 : 18.0;
                    } else if (screenWidth > 600) {
                      crossAxisCount = 2;
                      spacing = kIsWeb ? 14.0 : 16.0;
                    } else {
                      crossAxisCount = 2;
                      spacing = 16.0;
                    }

                    // Aumentar altura base para acomodar el nuevo campo ID Tarjeta
                    final baseHeight = kIsWeb ? 190.0 : 210.0;
                    final heightBump = screenWidth > 900
                        ? 0.0
                        : (screenWidth > 600 ? 8.0 : 15.0);
                    cardMainAxisExtent = baseHeight + heightBump;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        mainAxisExtent: cardMainAxisExtent,
                      ),
                      itemCount: filteredMonederos.length + (monederoBloc.hasMorePagesMonederos ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Si estamos en el último elemento y hay más páginas, mostrar loading
                        if (index == filteredMonederos.length) {
                          // Cargar más monederos cuando se acerca al final
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (monederoBloc.hasMorePagesMonederos && !monederoBloc.isLoadingMoreMonederos) {
                              monederoBloc.cargarMasMonederos();
                            }
                          });
                          // Calcular cuántos items de carga mostrar en el grid
                          final loadingItemsCount = crossAxisCount;
                          return Container(
                            height: cardMainAxisExtent,
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  color: Color(0xFF205AA8),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Cargando más monederos...',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final monedero = filteredMonederos[index];
                        final isSelected = _selectedMonederoId == monedero['id'];
                        return _buildMonederoCard(
                          monedero: monedero,
                          isSelected: isSelected,
                          isDark: isDark,
                          textColor: textColor,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24.0),
                // Continuar button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _selectedMonederoId != null
                        ? () {
                            final selectedMonedero = filteredMonederos.firstWhere(
                              (m) => m['id'] == _selectedMonederoId,
                            );
                            GoRouter.of(context).go(
                              RoutesName.ingresarMonto,
                              extra: selectedMonedero,
                            );
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF205AA8),
                      disabledBackgroundColor: Colors.grey[400],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Continuar",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMonederoCard({
    required Map<String, dynamic> monedero,
    required bool isSelected,
    required bool isDark,
    required Color textColor,
  }) {
    final cardColor = isSelected
        ? (isDark ? Colors.blue[900] : Colors.blue[50])
        : (isDark ? Colors.grey[800] : Colors.grey[100]);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMonederoId = monedero['id'];
        });
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Ajustar padding y spacing según el tamaño de la tarjeta y si es web
          final cardWidth = constraints.maxWidth;
          final padding = kIsWeb 
              ? (cardWidth > 300 ? 10.0 : 8.0)  // Padding más reducido
              : (cardWidth > 300 ? 14.0 : 12.0);
          final bottomPadding = kIsWeb
              ? (cardWidth > 300 ? 6.0 : 4.0)
              : (cardWidth > 300 ? 8.0 : 6.0);
          
          // Espaciado más compacto para optimizar espacio
          final spacingSmall = kIsWeb ? 2.0 : 4.0;  // Más compacto
          final spacingMedium = kIsWeb ? 1.0 : 1.5; // Más compacto
          // Margen entre el texto de "Cliente" y la etiqueta de "Saldo" - reducido
          final spacingSaldo = kIsWeb ? 20.0 : 24.0;
          
          return Container(
            padding: EdgeInsets.fromLTRB(padding, padding, padding, bottomPadding),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: const Color(0xFF205AA8),
                      width: 2.0,
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
            // Serie
            Text(
              "Serie: ${monedero['serie']}",
              style: TextStyle(
                color: textColor,
                fontSize: kIsWeb ? 12 : 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacingSmall),
            // ID Card
            if (monedero['idCard'] != null && monedero['idCard'].toString().isNotEmpty) ...[
              Text(
                "ID Tarjeta: ${monedero['idCard']}",
                style: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontSize: kIsWeb ? 10 : 11,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: spacingSmall),
            ],
            // Pasajero
            Text(
              "Pasajero:",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: kIsWeb ? 10 : 11,
              ),
            ),
            SizedBox(height: spacingMedium),
            Text(
              monedero['pasajero'] ?? 'Monedero sin asignar',
              style: TextStyle(
                color: monedero['pasajero'] != null ? textColor : Colors.grey[600],
                fontSize: kIsWeb ? 11 : 12,
                fontWeight: FontWeight.w500,
                fontStyle: monedero['pasajero'] == null ? FontStyle.italic : FontStyle.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacingSmall),
            // Cliente
            Text(
              "Cliente:",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: kIsWeb ? 10 : 11,
              ),
            ),
            SizedBox(height: spacingMedium),
            // Cliente texto - sin Flexible para evitar conflictos
            Text(
              monedero['cliente'],
              style: TextStyle(
                color: textColor,
                fontSize: kIsWeb ? 11 : 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Espaciado dinámico antes del saldo
            SizedBox(height: kIsWeb ? 16.0 : 20.0),
            // Saldo
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: kIsWeb ? 3.0 : 5.0,
              ),
              decoration: BoxDecoration(
                // Chip completo (incluye "Saldo" + monto) con el mismo estilo que "Activo" del drawer
                color: const Color(0xFFA6CE39).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFA6CE39), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.account_balance_wallet, color: Color(0xFFA6CE39), size: 14),
                      SizedBox(width: 4),
                      Text(
                        "Saldo",
                        style: TextStyle(
                          color: Color(0xFFA6CE39),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "\$${monedero['saldo'].toStringAsFixed(2)}",
                    style: TextStyle(
                      color: const Color(0xFFA6CE39),
                      fontSize: kIsWeb ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
              ],
            ),
          );
        },
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
          onTap: (index) async {
            if (index == 0) {
              GoRouter.of(context).go(RoutesName.dashboard);
            } else if (index == 1) {
              // Verificar si el usuario es Cajero
              final user = authBloc.currentUser;
              final isCajero = user?.rol?.nombre.toLowerCase() == 'cajero';
              
              if (isCajero) {
                // Si es Cajero, mostrar alert de advertencia
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.warning,
                  title: '¡Ops!',
                  text: 'No tienes acceso a esta información.',
                  confirmBtnText: 'Aceptar',
                  confirmBtnColor: const Color(0xFF205AA8),
                );
              } else {
                // Si no es Cajero, abrir el bottomsheet normalmente
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const MonederoBottomSheet(),
                );
              }
            } else if (index == 2) {
              GoRouter.of(context).go(RoutesName.perfil);
            }
          },
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
}

