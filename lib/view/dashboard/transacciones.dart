// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TransaccionesPage extends StatefulWidget {
  const TransaccionesPage({super.key});

  @override
  State<TransaccionesPage> createState() => _TransaccionesPageState();
}

class _TransaccionesPageState extends State<TransaccionesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _tipoFiltro = 'Todos'; // Todos, Recarga, Débito
  bool _filtroAlDia = false; // Filtro para mostrar solo transacciones del día actual

  @override
  void initState() {
    super.initState();
    // Cargar transacciones al iniciar
    monederoBloc.obtenerTransacciones();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
    return Column(
      children: [
        _buildHeader(context, textColor: textColor, isDark: isDark),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Búsqueda y filtros
                    _buildSearchAndFilters(isDark: isDark, textColor: textColor),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
              // Lista de transacciones
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _buildTransaccionesList(isDark: isDark, textColor: textColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget desktopView({
    required BuildContext context,
    required bool isDark,
    required Color textColor,
  }) {
    return Column(
      children: [
        _buildHeader(context, textColor: textColor, isDark: isDark),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Búsqueda y filtros
                      _buildSearchAndFilters(isDark: isDark, textColor: textColor),
                      const SizedBox(height: 24.0),
                    ],
                  ),
                ),
              ),
              // Lista de transacciones
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: _buildTransaccionesList(isDark: isDark, textColor: textColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
              "Transacciones",
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

  Widget _buildSearchAndFilters({
    required bool isDark,
    required Color textColor,
  }) {
    final cardColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de búsqueda
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Buscar por pasajero, cliente o serie...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16.0),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
        ),
        const SizedBox(height: 16.0),
        // Filtros de tipo y fecha
        Center(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
            _buildFilterChip('Todos', _tipoFiltro == 'Todos', () {
              setState(() {
                _tipoFiltro = 'Todos';
              });
            }, isDark: isDark, textColor: textColor),
            _buildFilterChip('Recarga', _tipoFiltro == 'Recarga', () {
              setState(() {
                _tipoFiltro = 'Recarga';
              });
            }, isDark: isDark, textColor: textColor),
            _buildFilterChip('Débito', _tipoFiltro == 'Débito', () {
              setState(() {
                _tipoFiltro = 'Débito';
              });
            }, isDark: isDark, textColor: textColor),
            _buildFilterChip('Al día', _filtroAlDia, () {
              setState(() {
                _filtroAlDia = !_filtroAlDia;
              });
            }, isDark: isDark, textColor: textColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    required bool isDark,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF205AA8)
                  : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF205AA8)
                    : (isDark ? Colors.grey[700]! : Colors.grey[400]!),
              ),
            ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : textColor,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTransaccionesList({
    required bool isDark,
    required Color textColor,
  }) {
    return StreamBuilder<MonederoStatus>(
      stream: monederoBloc.transaccionesStatusStream,
      initialData: monederoBloc.transaccionesStatus,
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
                    'Cargando transacciones...',
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
                    monederoBloc.transaccionesErrorMessage ??
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
                      monederoBloc.obtenerTransacciones();
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

        // Loaded state
        return StreamBuilder<List<TransaccionModel>>(
          stream: monederoBloc.transaccionesStream,
          initialData: monederoBloc.transacciones,
          builder: (context, transaccionesSnapshot) {
            final transacciones = transaccionesSnapshot.data ?? [];

            // Ordenar transacciones por fecha descendente (más recientes primero)
            final transaccionesOrdenadas = List<TransaccionModel>.from(transacciones);
            transaccionesOrdenadas.sort((a, b) {
              // Si ambas tienen fecha, comparar (descendente: más reciente primero)
              if (a.fechaHora != null && b.fechaHora != null) {
                return b.fechaHora!.compareTo(a.fechaHora!);
              }
              // Si solo a tiene fecha, va primero
              if (a.fechaHora != null && b.fechaHora == null) return -1;
              // Si solo b tiene fecha, va primero
              if (a.fechaHora == null && b.fechaHora != null) return 1;
              // Si ninguna tiene fecha, usar ID como criterio de desempate (mayor ID primero)
              return b.id.compareTo(a.id);
            });

            // Filtrar transacciones ordenadas
            final searchTerm = _searchController.text.toLowerCase();
            final ahora = DateTime.now();
            final hoy = DateTime(ahora.year, ahora.month, ahora.day);
            
            var filteredTransacciones = transaccionesOrdenadas.where((transaccion) {
              // Filtro por tipo
              if (_tipoFiltro == 'Recarga' && !transaccion.esRecarga) {
                return false;
              }
              if (_tipoFiltro == 'Débito' && !transaccion.esDebito) {
                return false;
              }

              // Filtro por fecha (Al día)
              if (_filtroAlDia) {
                if (transaccion.fechaHora == null) {
                  return false;
                }
                // Convertir a hora local si viene en UTC
                final fechaLocal = transaccion.fechaHora!.isUtc 
                    ? transaccion.fechaHora!.toLocal() 
                    : transaccion.fechaHora!;
                // Verificar si la fecha corresponde al día actual
                final fechaTransaccion = DateTime(fechaLocal.year, fechaLocal.month, fechaLocal.day);
                if (fechaTransaccion.year != hoy.year ||
                    fechaTransaccion.month != hoy.month ||
                    fechaTransaccion.day != hoy.day) {
                  return false;
                }
              }

              // Filtro por búsqueda
              if (searchTerm.isNotEmpty) {
                final serie = transaccion.numeroSerieMonedero?.toLowerCase() ?? '';
                final pasajero = transaccion.nombrePasajeroCompleto?.toLowerCase() ?? '';
                final cliente = transaccion.clienteNombre?.toLowerCase() ?? '';
                return serie.contains(searchTerm) ||
                    pasajero.contains(searchTerm) ||
                    cliente.contains(searchTerm);
              }

              return true;
            }).toList();

            // Las transacciones ya están ordenadas por fecha descendente
            // El filtrado mantiene el orden original

            // Lista vacía
            if (filteredTransacciones.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        searchTerm.isNotEmpty || _tipoFiltro != 'Todos' || _filtroAlDia
                            ? 'No se encontraron transacciones'
                            : 'No hay transacciones disponibles',
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

            return RefreshIndicator(
              onRefresh: () async {
                await monederoBloc.refreshTransacciones();
              },
              color: const Color(0xFF205AA8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (filteredTransacciones.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        '${filteredTransacciones.length} transacción${filteredTransacciones.length != 1 ? 'es' : ''} encontrada${filteredTransacciones.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredTransacciones.length + (monederoBloc.hasMorePages ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Si estamos en el último elemento y hay más páginas, mostrar loading
                        if (index == filteredTransacciones.length) {
                          // Cargar más transacciones cuando se acerca al final
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (monederoBloc.hasMorePages && !monederoBloc.isLoadingMore) {
                              monederoBloc.cargarMasTransacciones();
                            }
                          });
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Column(
                                children: [
                                  const CircularProgressIndicator(
                                    color: Color(0xFF205AA8),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Cargando más transacciones...',
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

                        final transaccion = filteredTransacciones[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < filteredTransacciones.length - 1 ? 12.0 : 0,
                          ),
                          child: _buildTransaccionCard(
                            transaccion: transaccion,
                            isDark: isDark,
                            textColor: textColor,
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
  }

  Widget _buildTransaccionCard({
    required TransaccionModel transaccion,
    required bool isDark,
    required Color textColor,
  }) {
    final cardColor = isDark ? Colors.grey[800] : Colors.grey[100];
    final isRecarga = transaccion.esRecarga;
    final tipoColor = isRecarga ? const Color(0xFFA6CE39) : Colors.red;
    final tipoTexto = isRecarga ? 'Recarga' : 'Débito';
    final iconData = isRecarga ? Icons.arrow_upward : Icons.arrow_downward;

    // Formatear fecha y hora usando el formato estándar
    String fechaHoraTexto = DateFormatter.formatDateTimeFromDateTime(transaccion.fechaHora);

    // Formatear monto
    final montoTexto = transaccion.monto != null
        ? '\$${transaccion.monto!.toStringAsFixed(2)}'
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información de la transacción (lado izquierdo)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  icon: Icons.credit_card,
                  label: 'Serie:',
                  value: transaccion.numeroSerieMonedero ?? 'N/A',
                  textColor: textColor,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.person,
                  label: 'Pasajero:',
                  value: transaccion.nombrePasajeroCompleto ?? 'Sin asignar',
                  textColor: textColor,
                ),
                const SizedBox(height: 8),
                if (transaccion.clienteNombre != null && transaccion.clienteNombre!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildInfoRow(
                      icon: Icons.business,
                      label: 'Cliente:',
                      value: transaccion.clienteNombre!,
                      textColor: textColor,
                    ),
                  ),
                _buildInfoRow(
                  icon: Icons.access_time,
                  label: 'Fecha y hora:',
                  value: fechaHoraTexto,
                  textColor: textColor,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Columna con label y monto (lado derecho)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Tipo de transacción con label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tipoColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tipoColor, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(iconData, color: tipoColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      tipoTexto,
                      style: TextStyle(
                        color: tipoColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Monto
              Text(
                montoTexto,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color textColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
              children: [
                TextSpan(
                  text: '$label ',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

