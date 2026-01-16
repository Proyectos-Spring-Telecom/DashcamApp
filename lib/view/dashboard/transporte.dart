// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:ui' as ui;

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
  gmaps.MapType _currentMapType = gmaps.MapType.normal;
  bool _isMapReady = false;
  bool _hasAuthError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  /// Redimensiona la imagen del marcador según la plataforma
  Future<Uint8List> _resizeMarkerImage(Uint8List imageBytes, int targetSize) async {
    final codec = await ui.instantiateImageCodec(imageBytes, targetWidth: targetSize);
    final frame = await codec.getNextFrame();
    final resizedImage = frame.image;
    
    final byteData = await resizedImage.toByteData(format: ui.ImageByteFormat.png);
    resizedImage.dispose();
    
    return byteData!.buffer.asUint8List();
  }

  Future<void> _addMarkers(BuildContext context) async {
    if (!mounted) return;
    
    try {
      // Cargar la imagen original
      final ByteData data = await rootBundle.load('assets/images/marker_dash.png');
      final Uint8List originalBytes = data.buffer.asUint8List();
      
      // Definir tamaño del marcador según la plataforma
      // Web: más grande (96px) - Mobile: más pequeño (60px)
      // Aumentado un 20% desde los valores originales (80px -> 96px, 50px -> 60px)
      final int markerSize = kIsWeb ? 96 : 130;
      
      // Redimensionar la imagen
      final Uint8List resizedBytes = await _resizeMarkerImage(originalBytes, markerSize);
      
      // Convertir bytes redimensionados a BitmapDescriptor
      final customIcon = gmaps.BitmapDescriptor.fromBytes(resizedBytes);
      
      if (mounted) {
        setState(() {
          _markers = {
            gmaps.Marker(
              markerId: const gmaps.MarkerId('vehicle_1'),
              position: const gmaps.LatLng(19.4326, -99.1332),
              icon: customIcon,
              infoWindow: const gmaps.InfoWindow(title: 'Vehículo 1'),
              anchor: const Offset(0.5, 1.0), // Ancla el marcador desde el centro inferior
            ),
          };
        });
        debugPrint('✅ Marcador personalizado cargado exitosamente');
        debugPrint('📦 Tamaño del marcador: ${markerSize}px');
        debugPrint('🌐 Plataforma: ${kIsWeb ? "Web" : "Mobile"}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error al cargar el marcador personalizado: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      // Si falla, usar el marcador por defecto como respaldo
      if (mounted) {
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
        debugPrint('⚠️ Usando marcador por defecto como respaldo');
      }
    }
  }

  Future<void> _onMapCreated(gmaps.GoogleMapController controller) async {
    if (mounted) {
      _mapController = controller;
      
      // En web, puede tomar más tiempo cargar el mapa
      final delayDuration = kIsWeb 
          ? const Duration(milliseconds: 1500) 
          : const Duration(milliseconds: 800);
      
      await Future.delayed(delayDuration);
      
      if (mounted) {
        // Cargar los marcadores después de que el mapa esté creado
        final context = this.context;
        if (context.mounted) {
          await _addMarkers(context);
        }
        
        setState(() {
          _isMapReady = true;
        });
        debugPrint('✅ Google Maps controller creado exitosamente');
        debugPrint('📍 Posición inicial: $_initialPosition');
        debugPrint('🗺️ Tipo de mapa: $_currentMapType');
        debugPrint('🌐 Plataforma: ${kIsWeb ? "Web" : "Mobile"}');
        
        // En web, no intentar aplicar estilo del mapa ya que puede causar problemas
        if (!kIsWeb) {
          try {
            await controller.setMapStyle(null);
          } catch (e) {
            debugPrint('⚠️ Error al aplicar estilo del mapa: $e');
          }
        }
        
        // Timeout para web: si después de 5 segundos no se carga, marcar como listo
        if (kIsWeb) {
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted && !_isMapReady) {
              debugPrint('⚠️ Timeout: Marcando mapa como listo después de 5 segundos (Web)');
              setState(() {
                _isMapReady = true;
              });
            }
          });
        }
        
        // Verificar si el mapa se renderizó correctamente después de un tiempo
        // Si el mapa muestra solo el fondo café sin calles, hay un problema de autorización
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && !_hasAuthError) {
            // Detectar posible error de autorización
            // Nota: Google Maps no proporciona un callback directo para esto,
            // pero podemos mostrar instrucciones si el usuario reporta el problema
            if (!kIsWeb) {
              debugPrint('⚠️ Verificando estado del mapa después de la inicialización...');
              debugPrint('📍 Si el mapa muestra solo un fondo café, verifica la autorización de la API key en Google Cloud Console');
              debugPrint('🔑 API Key: AIzaSyC3vvrNAZOxtjzm0LmdDzSW9gXT1ZZbEYQ');
              debugPrint('📱 SHA-1 necesario: A8:A9:8A:1C:5E:41:89:4D:74:DD:DF:F3:79:90:2B:CD:58:49:81:62');
              debugPrint('📦 Package: com.trueuly.dashboardpro');
            } else {
              debugPrint('🌐 En web, asegúrate de que la API key tenga habilitada la "Maps JavaScript API" en Google Cloud Console');
            }
          }
        });
      }
    }
  }
  
  void _checkMapAuthorization() {
    // Este método puede ser llamado manualmente si se detecta un problema
    // Por ahora, los logs mostrarán las instrucciones necesarias
    if (mounted) {
      setState(() {
        _hasAuthError = true;
        _errorMessage = 'La API key de Google Maps necesita estar configurada con la restricción SHA-1 en Google Cloud Console.\n\n'
            'SHA-1 necesario:\n'
            'A8:A9:8A:1C:5E:41:89:4D:74:DD:DF:F3:79:90:2B:CD:58:49:81:62\n\n'
            'Package: com.trueuly.dashboardpro\n\n'
            'Ve a Google Cloud Console > APIs & Services > Credentials y agrega esta restricción a tu API key.';
      });
    }
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
            backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            extendBodyBehindAppBar: false,
            drawer: _buildDrawer(context, isDark),
            body: Column(
              children: [
                // Header personalizado igual que en dashboard
                _buildHeader(context, isDark: isDark),
                // Mapa
                Expanded(
                  child: _buildMapView(isDark),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, {bool isDark = true}) {
    final paddingTop = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 24.0,
        top: paddingTop + 8.0,
        bottom: 8.0,
      ),
      child: Row(
        children: [
          // Hamburger menu - sin padding extra para alineación
          Builder(
            builder: (context) => IconButton(
              icon:
                  Icon(Icons.menu, color: isDark ? Colors.white : Colors.black),
              padding: EdgeInsets.zero, // Eliminar padding interno
              constraints:
                  const BoxConstraints(), // Eliminar constraints mínimos
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          const SizedBox(width: 8), // Espacio entre menú y texto

          // Title centrado - Transporte
          Expanded(
            child: Center(
              child: Text(
                "Transporte",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Profile avatar
          GestureDetector(
            onTap: () {
              // Navegar a perfil de usuario
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
                  iconColor: isDark ? Colors.white : Colors.black,
                  iconSize: 20,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Google Map - Ocupa todo el espacio disponible
          gmaps.GoogleMap(
            initialCameraPosition: const gmaps.CameraPosition(
              target: _initialPosition,
              zoom: 13,
              tilt: 0,
            ),
            markers: _markers,
            mapType: _currentMapType,
            onMapCreated: _onMapCreated,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            compassEnabled: true,
            mapToolbarEnabled: false,
            myLocationEnabled: false,
            buildingsEnabled: true,
            trafficEnabled: false,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,
            minMaxZoomPreference: const gmaps.MinMaxZoomPreference(3, 20),
            padding: EdgeInsets.zero,
            liteModeEnabled: false,
            onCameraMoveStarted: () {
              // Si el usuario puede interactuar con el mapa, está funcionando
              if (!_isMapReady && mounted) {
                setState(() {
                  _isMapReady = true;
                });
              }
            },
          ),
          // Loading indicator while map initializes
          if (!_isMapReady && !_hasAuthError)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF205AA8),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando mapa...',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Error message overlay (solo se mostrará si hay error de autorización)
          if (_hasAuthError && _errorMessage != null)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: isDark ? Colors.black.withOpacity(0.85) : Colors.white.withOpacity(0.95),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Error de autorización del mapa',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            _hasAuthError = false;
                            _errorMessage = null;
                            _isMapReady = false;
                          });
                          // Reintentar inicialización
                          if (_mapController != null) {
                            _onMapCreated(_mapController!);
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF205AA8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                          leading: Icon(Icons.account_balance_wallet, color: textColor),
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

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
