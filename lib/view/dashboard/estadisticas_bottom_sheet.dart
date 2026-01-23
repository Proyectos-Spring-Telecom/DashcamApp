// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:dashboardpro/view/dashboard/detalles_viaje_bottom_sheet.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dashboardpro/widgets/routes/app_routes.dart' as app_routes;

class EstadisticasBottomSheet extends StatefulWidget {
  const EstadisticasBottomSheet({super.key});

  @override
  State<EstadisticasBottomSheet> createState() =>
      _EstadisticasBottomSheetState();
}

class _EstadisticasBottomSheetState extends State<EstadisticasBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  bool _transaccionesLoaded = false;
  ScrollController? _registrosScrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
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

  void _onScroll() {
    if (_registrosScrollController != null &&
        _registrosScrollController!.hasClients) {
      if (_registrosScrollController!.position.pixels >=
          _registrosScrollController!.position.maxScrollExtent - 200) {
        // Cargar más cuando faltan 200px para llegar al final
        _loadMoreTransacciones();
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _registrosScrollController?.removeListener(_onScroll);
    _registrosScrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return StreamBuilder<AppTheme>(
      stream: themeBloc.themeStream,
      initialData: themeBloc.currentTheme,
      builder: (context, snapshot) {
        final isDark = snapshot.data?.data.brightness == Brightness.dark;
        final backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;

        return Container(
          height: screenHeight * 0.85,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Tabs
              _buildTabs(),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGeneralTab(textColor: textColor),
                    _buildQRCodesTab(textColor: textColor, isDark: isDark),
                    _buildGoalsTab(textColor: textColor, isDark: isDark),
                    _buildOperacionesTab(textColor: textColor, isDark: isDark),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem('General', 0),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabItem('Códigos QR', 1),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabItem('Viajes', 2),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabItem('Registros', 3),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
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
              color: isSelected ? Colors.white : Colors.grey[600],
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralTab({Color textColor = Colors.white}) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
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
        ),
      ),
    );
  }

  Widget _buildQRCodesTab(
      {Color textColor = Colors.white, bool isDark = true}) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Código QR section
            _buildCodigoQRSection(textColor: textColor, isDark: isDark),
            const SizedBox(height: 24.0),

            // Mis códigos section
            _buildMisCodigosSection(textColor: textColor, isDark: isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCodigoQRSection(
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
              Navigator.of(context).pop(); // Close bottom sheet first
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
        // List of QR codes
        _buildCodigoItem(
          code: "1234567VBDFFJGRTH",
          date: "01-Mayo-2025",
          amount: "-\$ 15",
          type: "Débito",
          textColor: textColor,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildCodigoItem(
          code: "1234567VBDFFJGRTH",
          date: "01-Mayo-2025",
          amount: "-\$ 15",
          type: "Débito",
          textColor: textColor,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildCodigoItem(
          code: "1234567VBDFFJGRTH",
          date: "01-Mayo-2025",
          amount: "-\$ 15",
          type: "Débito",
          textColor: textColor,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildCodigoItem(
          code: "1234567VBDFFJGRTH",
          date: "01-Mayo-2025",
          amount: "-\$ 15",
          type: "Débito",
          textColor: textColor,
          isDark: isDark,
        ),
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

  Widget _buildGoalsTab({Color textColor = Colors.white, bool isDark = true}) {
    final cardColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
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
        ),
      ),
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

  Widget _buildOperacionesTab(
      {Color textColor = Colors.white, bool isDark = true}) {
    // Inicializar scroll controller para scroll infinito
    if (_registrosScrollController == null) {
      _registrosScrollController = ScrollController();
      _registrosScrollController!.addListener(_onScroll);
    }

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
                        Expanded(
                          child: Center(
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
                        Expanded(
                          child: Center(
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
                        Expanded(
                          child: Center(
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
                          child: ListView.builder(
                            controller: _registrosScrollController,
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
      // Si la fecha es UTC, mostrarla en UTC sin convertir a hora local
      // Esto asegura que "2026-01-07T13:36:40.000Z" se muestre como "01:36 PM"
      DateTime fechaParaMostrar = transaccion.fechaHora!;
      
      // Extraer los componentes de fecha y hora (usar UTC si la fecha es UTC)
      int year, month, day, hour, minute;
      
      if (fechaParaMostrar.isUtc) {
        // Usar componentes UTC directamente
        year = fechaParaMostrar.year;
        month = fechaParaMostrar.month;
        day = fechaParaMostrar.day;
        hour = fechaParaMostrar.hour;
        minute = fechaParaMostrar.minute;
      } else {
        // Convertir a local y usar esos componentes
        final fechaLocal = fechaParaMostrar.toLocal();
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
              String month = expenseData[group.x.toInt()].month;
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
}

class MonthlyData {
  final String month;
  final double expenses;
  final double recharges;

  MonthlyData(this.month, this.expenses, this.recharges);
}

class ExpenseCategory {
  final String month;
  final double category1;
  final double category2;
  final double category3;

  ExpenseCategory(this.month, this.category1, this.category2, this.category3);
}
