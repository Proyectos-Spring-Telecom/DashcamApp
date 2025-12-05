// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter/services.dart';

class TransportePage extends StatefulWidget {
  const TransportePage({super.key});

  @override
  State<TransportePage> createState() => _TransportePageState();
}

class _TransportePageState extends State<TransportePage> {
  gmaps.GoogleMapController? _mapController;
  static const gmaps.LatLng _initialPosition =
      gmaps.LatLng(19.4326, -99.1332); // Ciudad de México
  Set<gmaps.Marker> _markers = {};
  String _mapType = "Mapa";
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  void _addMarkers() {
    setState(() {
      _markers = {
        gmaps.Marker(
          markerId: const gmaps.MarkerId('vehicle_1'),
          position: const gmaps.LatLng(19.4326, -99.1332),
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
              gmaps.BitmapDescriptor.hueBlue),
          infoWindow: const gmaps.InfoWindow(title: 'Vehículo 1'),
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppTheme>(
      stream: themeBloc.themeStream,
      initialData: themeBloc.currentTheme,
      builder: (context, snapshot) {
        final isDark = snapshot.data?.data.brightness == Brightness.dark;
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
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.menu, color: textColor, size: 24),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search, color: textColor, size: 24),
                  onPressed: () {
                    // Acción de búsqueda
                  },
                ),
              ],
            ),
            drawer: _buildDrawer(context, isDark),
            body: Stack(
              children: [
                // Google Maps - debe ocupar toda la pantalla
                gmaps.GoogleMap(
                  initialCameraPosition: const gmaps.CameraPosition(
                    target: _initialPosition,
                    zoom: 13,
                  ),
                  markers: _markers,
                  mapType: gmaps.MapType.normal,
                  onMapCreated: (gmaps.GoogleMapController controller) {
                    if (mounted) {
                      setState(() {
                        _mapController = controller;
                        _isMapReady = true;
                      });
                      debugPrint('✅ Google Maps controller creado exitosamente');
                      debugPrint('📍 Posición inicial: $_initialPosition');
                    }
                  },
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                ),

                // Floating card at the top-right
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 56), // Space for AppBar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: _buildMapTypeCard(
                              textColor: textColor, isDark: isDark),
                        ),
                      ),
                    ],
                  ),
                ),

                // Zoom controls and full-screen button at bottom-right
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Full-screen/Recenter button
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.fullscreen,
                                color: textColor,
                              ),
                              onPressed: _isMapReady && _mapController != null
                                  ? () {
                                      // Recenter or full-screen action
                                      _mapController!.animateCamera(
                                        gmaps.CameraUpdate.newCameraPosition(
                                          const gmaps.CameraPosition(
                                            target: _initialPosition,
                                            zoom: 13,
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Zoom controls
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.add, color: textColor),
                                  onPressed: _isMapReady && _mapController != null
                                      ? () {
                                          _mapController!.animateCamera(
                                            gmaps.CameraUpdate.zoomIn(),
                                          );
                                        }
                                      : null,
                                ),
                                Container(
                                  height: 1,
                                  color: isDark
                                      ? Colors.grey[700]
                                      : Colors.grey[300],
                                ),
                                IconButton(
                                  icon: Icon(Icons.remove, color: textColor),
                                  onPressed: _isMapReady && _mapController != null
                                      ? () {
                                          _mapController!.animateCamera(
                                            gmaps.CameraUpdate.zoomOut(),
                                          );
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapTypeCard({required Color textColor, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            _mapType,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.arrow_drop_down, color: textColor, size: 20),
        ],
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFA6CE39), // Green for active
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Activo",
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            // Menu options
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: Icon(Icons.account_balance_wallet, color: textColor),
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

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
