// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb, listEquals;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:quickalert/quickalert.dart';

class TransportePage extends StatefulWidget {
  const TransportePage({super.key});

  @override
  State<TransportePage> createState() => _TransportePageState();
}

// * Modelos de datos para geocercas y rutas (mock)
class GeocercaModel {
  final String id;
  final List<gmaps.LatLng> coordinates;
  final String name;

  GeocercaModel({
    required this.id,
    required this.coordinates,
    required this.name,
  });
}

class RutaModel {
  final String id;
  final gmaps.LatLng startPoint;
  final gmaps.LatLng endPoint;
  final List<gmaps.LatLng> path;
  final String name;

  RutaModel({
    required this.id,
    required this.startPoint,
    required this.endPoint,
    required this.path,
    required this.name,
  });
}

class _TransportePageState extends State<TransportePage> {
  gmaps.GoogleMapController? _mapController;
  // * Posición inicial por defecto (fallback si no se puede obtener la ubicación)
  static const gmaps.LatLng _defaultPosition =
      gmaps.LatLng(19.4326, -99.1332); // Ciudad de México
  gmaps.LatLng _initialPosition = _defaultPosition;
  Set<gmaps.Marker> _markers = {};
  Set<gmaps.Polygon> _polygons = {};
  Set<gmaps.Polyline> _polylines = {};
  gmaps.MapType _currentMapType = gmaps.MapType.normal;
  bool _isMapReady = false;
  bool _hasAuthError = false;
  String? _errorMessage;
  
  // * Estado para controlar qué se muestra
  String? _currentView; // 'geocercas' o 'rutas' o null
  
  // * Estado para la ubicación actual
  bool _isLoadingLocation = false;
  gmaps.LatLng? _currentLocation;
  
  // * Estado para el InfoWindow personalizado
  String? _selectedMarkerId;
  gmaps.LatLng? _selectedMarkerPosition;
  bool _isMarkerTapped = false; // * Flag para prevenir que el onTap del mapa limpie el estado
  
  // * UPDATE: Unidad seleccionada para mostrar en el InfoWindow personalizado
  UnidadModel? _selectedUnidad;
  
  // * UPDATE: Flag para evitar mostrar múltiples alertas de error
  bool _errorAlertShown = false;
  
  // * UPDATE: Cache de unidades para evitar actualizaciones innecesarias
  List<UnidadModel> _lastUnidades = [];

  @override
  void initState() {
    super.initState();
    // * Obtener la ubicación actual al inicializar
    _obtenerUbicacionActual();
    // * Cargar unidades de monitoreo al inicializar
    _cargarUnidades();
  }

  /// * Carga las unidades de monitoreo desde el servicio
  /// Filtra automáticamente por cliente del token autenticado y clientes hijos
  Future<void> _cargarUnidades() async {
    try {
      debugPrint('📤 Cargando unidades de monitoreo...');
      await monitoreoBloc.cargarUnidades();
    } catch (e) {
      debugPrint('❌ Error al cargar unidades: $e');
      // * El error se manejará a través del stream de errores del bloc
    }
  }
  
  /// * Obtiene la ubicación actual del dispositivo
  Future<void> _obtenerUbicacionActual() async {
    // * Verificar que el widget esté montado antes de cualquier setState
    if (!mounted) return;
    
    if (kIsWeb) {
      // * En web, usar la posición por defecto
      debugPrint('🌐 Web: Usando posición por defecto');
      if (!mounted) return;
      setState(() {
        _initialPosition = _defaultPosition;
        _currentLocation = _defaultPosition;
        _isLoadingLocation = false;
      });
      return;
    }
    
    // * Verificar que el widget siga montado antes de actualizar el estado
    if (!mounted) return;
    setState(() {
      _isLoadingLocation = true;
    });
    
    try {
      // * Verificar si los servicios de ubicación están habilitados
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      
      // * Verificar que el widget siga montado después de la operación asíncrona
      if (!mounted) return;
      
      if (!serviceEnabled) {
        debugPrint('⚠️ Los servicios de ubicación están deshabilitados');
        _usarPosicionPorDefecto();
        return;
      }

      // * Verificar permisos de ubicación (ya deberían estar otorgados desde el login)
      geo.LocationPermission permission = await geo.Geolocator.checkPermission();
      
      // * Verificar que el widget siga montado después de la operación asíncrona
      if (!mounted) return;
      
      if (permission != geo.LocationPermission.whileInUse && 
          permission != geo.LocationPermission.always) {
        debugPrint('⚠️ Permisos de ubicación no otorgados');
        _usarPosicionPorDefecto();
        return;
      }

      // * Obtener la ubicación actual
      debugPrint('📍 Obteniendo ubicación actual...');
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // * Verificar que el widget siga montado después de obtener la ubicación
      if (!mounted) return;

      final location = gmaps.LatLng(position.latitude, position.longitude);
      debugPrint('✅ Ubicación obtenida: lat=${position.latitude}, lng=${position.longitude}');

      setState(() {
        _currentLocation = location;
        _initialPosition = location;
        _isLoadingLocation = false;
      });
      
      // * Si el mapa ya está creado, actualizar la cámara y los markers
      if (_mapController != null && mounted) {
        await _actualizarMapaConUbicacion(location);
      }
    } catch (e) {
      debugPrint('❌ Error al obtener ubicación: $e');
      // * Verificar que el widget esté montado antes de usar posición por defecto
      if (mounted) {
        _usarPosicionPorDefecto();
      }
    }
  }
  
  /// * Usa la posición por defecto como fallback
  void _usarPosicionPorDefecto() {
    if (mounted) {
      setState(() {
        _currentLocation = _defaultPosition;
        _initialPosition = _defaultPosition;
        _isLoadingLocation = false;
      });
      debugPrint('📍 Usando posición por defecto: $_defaultPosition');
    }
  }
  
  /// * Actualiza el mapa con la ubicación actual
  Future<void> _actualizarMapaConUbicacion(gmaps.LatLng location) async {
    if (_mapController == null || !mounted) return;
    
    try {
      // * Centrar el mapa en la ubicación actual
      await _mapController!.animateCamera(
        gmaps.CameraUpdate.newCameraPosition(
          gmaps.CameraPosition(
            target: location,
            zoom: 15.0,
          ),
        ),
      );
      
      // * Actualizar los markers con la nueva ubicación
      final context = this.context;
      if (context.mounted) {
        await _addMarkers(context);
      }
    } catch (e) {
      debugPrint('❌ Error al actualizar mapa con ubicación: $e');
    }
  }

  // * Obtener geocercas mock
  List<GeocercaModel> _getMockGeocercas() {
    return [
      GeocercaModel(
        id: 'geocerca_1',
        name: 'Zona Centro',
        coordinates: [
          const gmaps.LatLng(19.4326, -99.1332),
          const gmaps.LatLng(19.4400, -99.1332),
          const gmaps.LatLng(19.4400, -99.1200),
          const gmaps.LatLng(19.4326, -99.1200),
        ],
      ),
      GeocercaModel(
        id: 'geocerca_2',
        name: 'Zona Norte',
        coordinates: [
          const gmaps.LatLng(19.4500, -99.1500),
          const gmaps.LatLng(19.4600, -99.1500),
          const gmaps.LatLng(19.4600, -99.1400),
          const gmaps.LatLng(19.4500, -99.1400),
        ],
      ),
    ];
  }

  // * Obtener rutas mock
  List<RutaModel> _getMockRutas() {
    return [
      RutaModel(
        id: 'ruta_1',
        name: 'Ruta Principal',
        startPoint: const gmaps.LatLng(19.4326, -99.1332),
        endPoint: const gmaps.LatLng(19.4500, -99.1500),
        path: [
          const gmaps.LatLng(19.4326, -99.1332),
          const gmaps.LatLng(19.4380, -99.1400),
          const gmaps.LatLng(19.4450, -99.1450),
          const gmaps.LatLng(19.4500, -99.1500),
        ],
      ),
    ];
  }

  // * Mostrar geocercas en el mapa
  void _onMarkerTapped() {
    debugPrint('📍 Marker tocado - user_location');
    final position = _currentLocation ?? _initialPosition;
    debugPrint('📍 Posición actual: $position');
    
    setState(() {
      _isMarkerTapped = true;
      _selectedMarkerId = 'user_location';
      _selectedMarkerPosition = position;
      _selectedUnidad = null; // * Limpiar unidad seleccionada
      debugPrint('✅ InfoWindow personalizado activado');
    });
    
    // * Resetear el flag después de un breve delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isMarkerTapped = false;
          debugPrint('🔄 Flag _isMarkerTapped reseteado');
        });
      }
    });
  }

  /// * UPDATE: Maneja el tap en el marker de una unidad
  void _onUnidadMarkerTapped(UnidadModel unidad) {
    debugPrint('🚗 Marker de unidad tocado - ${unidad.codigo}');
    final position = gmaps.LatLng(unidad.posicion.lat, unidad.posicion.lng);
    
    setState(() {
      _isMarkerTapped = true;
      _selectedMarkerId = 'unidad_${unidad.id}';
      _selectedMarkerPosition = position;
      _selectedUnidad = unidad; // * Guardar la unidad seleccionada
      debugPrint('✅ InfoWindow personalizado activado para unidad ${unidad.codigo}');
    });
    
    // * Resetear el flag después de un breve delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isMarkerTapped = false;
          debugPrint('🔄 Flag _isMarkerTapped reseteado');
        });
      }
    });
  }

  void _showGeocercas() {
    final geocercas = _getMockGeocercas();
    final polygons = <gmaps.Polygon>{};
    
    for (var geocerca in geocercas) {
      polygons.add(
        gmaps.Polygon(
          polygonId: gmaps.PolygonId(geocerca.id),
          points: geocerca.coordinates,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          strokeWidth: 2,
          geodesic: false,
        ),
      );
    }

    setState(() {
      _polygons = polygons;
      _polylines = {};
      _markers = {}; // Limpiar marcadores de rutas
      _currentView = 'geocercas';
    });

    _adjustCameraToFit(geocercas: geocercas);
  }

  // * Mostrar rutas en el mapa
  void _showRutas() {
    final rutas = _getMockRutas();
    final polylines = <gmaps.Polyline>{};
    final markers = <gmaps.Marker>{};

    for (var ruta in rutas) {
      // * Agregar polyline
      polylines.add(
        gmaps.Polyline(
          polylineId: gmaps.PolylineId(ruta.id),
          points: ruta.path,
          color: Colors.blue,
          width: 4,
          geodesic: false,
        ),
      );

      // * Agregar marcador de inicio
      markers.add(
        gmaps.Marker(
          markerId: gmaps.MarkerId('${ruta.id}_start'),
          position: ruta.startPoint,
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueGreen,
          ),
          infoWindow: gmaps.InfoWindow(
            title: 'Inicio: ${ruta.name}',
          ),
        ),
      );

      // * Agregar marcador de fin
      markers.add(
        gmaps.Marker(
          markerId: gmaps.MarkerId('${ruta.id}_end'),
          position: ruta.endPoint,
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueRed,
          ),
          infoWindow: gmaps.InfoWindow(
            title: 'Fin: ${ruta.name}',
          ),
        ),
      );
    }

    setState(() {
      _polylines = polylines;
      _polygons = {};
      _markers = markers;
      _currentView = 'rutas';
    });

    _adjustCameraToFit(rutas: rutas);
  }

  // * Ocultar todo
  void _hideAll() {
    setState(() {
      _polygons = {};
      _polylines = {};
      _markers = {};
      _currentView = null;
    });
    
    // * Restaurar marcadores originales del vehículo
    if (_mapController != null) {
      final context = this.context;
      if (context.mounted) {
        _addMarkers(context);
      }
    }
  }

  // * Ajustar cámara para mostrar geocercas o rutas
  Future<void> _adjustCameraToFit({
    List<GeocercaModel>? geocercas,
    List<RutaModel>? rutas,
  }) async {
    if (_mapController == null) return;

    final allPoints = <gmaps.LatLng>[];

    if (geocercas != null) {
      for (var geocerca in geocercas) {
        allPoints.addAll(geocerca.coordinates);
      }
    }

    if (rutas != null) {
      for (var ruta in rutas) {
        allPoints.add(ruta.startPoint);
        allPoints.add(ruta.endPoint);
        allPoints.addAll(ruta.path);
      }
    }

    if (allPoints.isEmpty) return;

    // * Calcular bounds
    double minLat = allPoints.first.latitude;
    double maxLat = allPoints.first.latitude;
    double minLng = allPoints.first.longitude;
    double maxLng = allPoints.first.longitude;

    for (var point in allPoints) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    final center = gmaps.LatLng(
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
    );

    // * Calcular zoom aproximado basado en la distancia
    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    double zoom = 13.0;
    if (maxDiff > 0.1) {
      zoom = 10.0;
    } else if (maxDiff > 0.05) {
      zoom = 12.0;
    } else if (maxDiff > 0.01) {
      zoom = 14.0;
    } else {
      zoom = 16.0;
    }

    await _mapController!.animateCamera(
      gmaps.CameraUpdate.newCameraPosition(
        gmaps.CameraPosition(
          target: center,
          zoom: zoom,
        ),
      ),
    );
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

  /// * UPDATE: Agrega markers al mapa incluyendo:
  /// - Marker del usuario (ubicación actual)
  /// - Markers dinámicos de las unidades de monitoreo
  Future<void> _addMarkers(BuildContext context) async {
    if (!mounted) return;
    
    // * Usar la ubicación actual si está disponible, sino usar la posición inicial
    final position = _currentLocation ?? _initialPosition;
    
    // * Obtener información del usuario logueado
    final user = authBloc.currentUser;
    final nombreCompleto = user != null
        ? '${user.nombre} ${user.apellidoPaterno}${user.apellidoMaterno != null && user.apellidoMaterno!.isNotEmpty ? ' ${user.apellidoMaterno}' : ''}'
        : 'Usuario';
    final rolNombre = user?.rol?.nombre ?? 'N/A';
    
    // * Construir el snippet con la información del usuario
    final snippet = '$nombreCompleto\n'
        'Rol: $rolNombre\n'
        'Estatus: ✓ Activo';
    
    // * Set para almacenar todos los markers (usuario + unidades)
    final Set<gmaps.Marker> allMarkers = {};
    
    try {
      // * Cargar la imagen original para el marker del usuario
      final ByteData data = await rootBundle.load('assets/images/marker_dash.png');
      final Uint8List originalBytes = data.buffer.asUint8List();
      
      // * Definir tamaño del marcador según la plataforma
      final int markerSize = kIsWeb ? 96 : 130;
      
      // * Redimensionar la imagen
      final Uint8List resizedBytes = await _resizeMarkerImage(originalBytes, markerSize);
      
      // * Convertir bytes redimensionados a BitmapDescriptor
      final customIcon = gmaps.BitmapDescriptor.fromBytes(resizedBytes);
      
      // * Agregar marker del usuario
      allMarkers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('user_location'),
          position: position,
          icon: customIcon,
          infoWindow: const gmaps.InfoWindow(),
          anchor: const Offset(0.5, 1.0),
          onTap: _onMarkerTapped,
        ),
      );
      
      debugPrint('✅ Marcador del usuario cargado exitosamente');
      debugPrint('📍 Posición del marcador: $position');
      debugPrint('👤 Usuario: $nombreCompleto');
    } catch (e, stackTrace) {
      debugPrint('❌ Error al cargar el marcador personalizado: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      // * Si falla, usar el marcador por defecto como respaldo
      allMarkers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('user_location'),
          position: position,
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
              gmaps.BitmapDescriptor.hueBlue),
          infoWindow: const gmaps.InfoWindow(),
          onTap: _onMarkerTapped,
        ),
      );
      debugPrint('⚠️ Usando marcador por defecto como respaldo');
    }
    
    // * UPDATE: Agregar markers dinámicos de las unidades de monitoreo
    final unidades = monitoreoBloc.unidadesConPosicionValida;
    debugPrint('🚗 Agregando ${unidades.length} unidades al mapa');
    
    for (var unidad in unidades) {
      try {
        // * UPDATE: Crear marker para cada unidad usando InfoWindow personalizado
        // * Deshabilitar InfoWindow nativo para usar solo el personalizado
        allMarkers.add(
          gmaps.Marker(
            markerId: gmaps.MarkerId('unidad_${unidad.id}'),
            position: gmaps.LatLng(unidad.posicion.lat, unidad.posicion.lng),
            icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
              unidad.estaEnRuta 
                  ? gmaps.BitmapDescriptor.hueGreen // * Verde para unidades en ruta
                  : gmaps.BitmapDescriptor.hueOrange, // * Naranja para otras unidades
            ),
            // * UPDATE: Usar InfoWindow vacío y onTap para activar el InfoWindow personalizado
            infoWindow: const gmaps.InfoWindow(),
            onTap: () => _onUnidadMarkerTapped(unidad),
          ),
        );
        debugPrint('✅ Marker agregado para unidad ${unidad.id} (${unidad.codigo})');
      } catch (e) {
        debugPrint('❌ Error al agregar marker para unidad ${unidad.id}: $e');
      }
    }
    
    // * Actualizar los markers en el estado
    if (mounted) {
      setState(() {
        _markers = allMarkers;
      });
      debugPrint('✅ Total de markers en el mapa: ${allMarkers.length}');
      debugPrint('   - Marker del usuario: 1');
      debugPrint('   - Markers de unidades: ${unidades.length}');
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
        // * Si aún se está cargando la ubicación, esperar un poco más
        if (_isLoadingLocation) {
          debugPrint('⏳ Esperando ubicación actual...');
          await Future.delayed(const Duration(milliseconds: 500));
        }
        
        // * Centrar el mapa en la ubicación actual (o posición inicial)
        final targetPosition = _currentLocation ?? _initialPosition;
        await controller.animateCamera(
          gmaps.CameraUpdate.newCameraPosition(
            gmaps.CameraPosition(
              target: targetPosition,
              zoom: 15.0,
            ),
          ),
        );
        
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
        debugPrint('📍 Ubicación actual: ${_currentLocation ?? "No disponible"}');
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
            body: StreamBuilder<List<UnidadModel>>(
              stream: monitoreoBloc.unidadesStream,
              initialData: monitoreoBloc.unidades,
              builder: (context, unidadesSnapshot) {
                // * UPDATE: Actualizar markers solo si las unidades cambiaron
                final unidades = unidadesSnapshot.data ?? [];
                final unidadesChanged = unidades.length != _lastUnidades.length ||
                    !listEquals(unidades.map((u) => u.id).toList(), 
                                _lastUnidades.map((u) => u.id).toList());
                
                if (unidadesChanged && _mapController != null && mounted) {
                  _lastUnidades = List.from(unidades);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_mapController != null && mounted) {
                      _addMarkers(context);
                    }
                  });
                }
                
                return StreamBuilder<MonitoreoStatus>(
                  stream: monitoreoBloc.statusStream,
                  initialData: monitoreoBloc.status,
                  builder: (context, statusSnapshot) {
                    return StreamBuilder<String?>(
                      stream: monitoreoBloc.errorStream,
                      initialData: monitoreoBloc.errorMessage,
                      builder: (context, errorSnapshot) {
                        // * ERROR HANDLING: Mostrar QuickAlert si hay error
                        final errorMessage = errorSnapshot.data;
                        if (errorMessage != null && 
                            errorMessage.isNotEmpty && 
                            mounted && 
                            !_errorAlertShown) {
                          _errorAlertShown = true;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.error,
                                title: 'Error',
                                text: errorMessage,
                                confirmBtnText: 'Aceptar',
                                confirmBtnColor: const Color(0xFF205AA8),
                                onConfirmBtnTap: () {
                                  monitoreoBloc.limpiarError();
                                  _errorAlertShown = false; // * Permitir mostrar alerta nuevamente
                                },
                              );
                            }
                          });
                        } else if (errorMessage == null || errorMessage.isEmpty) {
                          // * Resetear flag cuando no hay error
                          _errorAlertShown = false;
                        }
                        
                        return Column(
                          children: [
                            // Header personalizado igual que en dashboard
                            _buildHeader(context, isDark: isDark),
                            // Mapa
                            Expanded(
                              child: _buildMapView(isDark),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
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
              target: _defaultPosition,
              zoom: 13,
              tilt: 0,
            ),
            markers: _markers,
            polygons: _polygons,
            polylines: _polylines,
            mapType: _currentMapType,
            onMapCreated: _onMapCreated,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false, // * Deshabilitar controles nativos para usar personalizados
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
              // * Cerrar InfoWindow personalizado si el usuario mueve el mapa
              // * PERO NO si se acaba de tocar el marker
              if (_selectedMarkerId != null && !_isMarkerTapped) {
                debugPrint('🗺️ Cámara movida - cerrando InfoWindow');
                setState(() {
                  _selectedMarkerId = null;
                  _selectedMarkerPosition = null;
                  _selectedUnidad = null; // * UPDATE: Limpiar unidad seleccionada
                });
              } else if (_isMarkerTapped) {
                debugPrint('🚫 Ignorando movimiento de cámara porque el marker fue tocado');
              }
            },
            onTap: (gmaps.LatLng position) {
              // * Cerrar InfoWindow personalizado si se toca el mapa
              // * PERO NO si se acaba de tocar el marker (para evitar que se cierre inmediatamente)
              if (_selectedMarkerId != null && !_isMarkerTapped) {
                debugPrint('🗺️ Mapa tocado - cerrando InfoWindow');
                setState(() {
                  _selectedMarkerId = null;
                  _selectedMarkerPosition = null;
                  _selectedUnidad = null; // * UPDATE: Limpiar unidad seleccionada
                });
              } else if (_isMarkerTapped) {
                debugPrint('🚫 Ignorando tap del mapa porque el marker fue tocado');
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
          // * Controles de zoom personalizados (esquina inferior derecha)
          if (_isMapReady && !_hasAuthError)
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildCustomZoomControls(isDark),
            ),
          // * FAB para mostrar geocercas o rutas (esquina inferior izquierda)
          if (_isMapReady && !_hasAuthError)
            Positioned(
              bottom: 20,
              left: 20,
              child: _buildMapOptionsFAB(isDark),
            ),
          // * InfoWindow personalizado
          if (_selectedMarkerId != null && _selectedMarkerPosition != null) ...[
            Builder(
              builder: (context) {
                debugPrint('🔍 Renderizando InfoWindow en el Stack');
                debugPrint('📍 _selectedMarkerId: $_selectedMarkerId');
                debugPrint('📍 _selectedMarkerPosition: $_selectedMarkerPosition');
                return _buildCustomInfoWindow(context, isDark);
              },
            ),
          ],
        ],
      ),
    );
  }
  
  /// * UPDATE: Construye el InfoWindow personalizado con la información del usuario o unidad
  /// * Diseño basado en la imagen: gradiente azul, layout horizontal con foto de perfil
  /// * Ahora soporta tanto información del usuario como de unidades
  Widget _buildCustomInfoWindow(BuildContext context, bool isDark) {
    debugPrint('🎨 Construyendo InfoWindow personalizado');
    debugPrint('📍 _selectedMarkerId: $_selectedMarkerId');
    debugPrint('📍 _selectedMarkerPosition: $_selectedMarkerPosition');
    
    // * UPDATE: Determinar si es una unidad o el usuario
    final bool esUnidad = _selectedUnidad != null;
    
    // * Información del usuario (si no es unidad)
    final user = esUnidad ? null : authBloc.currentUser;
    final nombreCompleto = esUnidad 
        ? _selectedUnidad!.codigo
        : (user != null
            ? '${user.nombre} ${user.apellidoPaterno}${user.apellidoMaterno != null && user.apellidoMaterno!.isNotEmpty ? ' ${user.apellidoMaterno}' : ''}'
            : 'Usuario');
    final rolNombre = esUnidad 
        ? _selectedUnidad!.modelo
        : (user?.rol?.nombre ?? 'N/A');
    
    return Positioned(
      top: 80,
      left: 20,
      right: 20,
      child: Material(
        elevation: 8,
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            // * No cerrar al tocar el InfoWindow
            debugPrint('👆 InfoWindow tocado - no cerrar');
          },
          child: CustomPaint(
            painter: _InfoWindowTailPainter(),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF205AA8), // * Azul principal de los botones
                    const Color(0xFF205AA8).withOpacity(0.9), // * Ligeramente más oscuro
                    const Color(0xFF1A4A8F), // * Azul más oscuro para el degradado
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // * Sección izquierda: Texto (2/3 del ancho)
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // * Nombre completo (arriba, grande, bold, blanco)
                        Text(
                          nombreCompleto,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        // * Rol (debajo del nombre, más pequeño, blanco)
                        Text(
                          rolNombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // * UPDATE: Ocupación de pasajero (solo para unidades)
                        if (esUnidad) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Ocupación de pasajeros: ${_selectedUnidad!.diferencia} personas',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        // * UPDATE: Divider debajo del Rol (color #A6CE39 según especificación)
                        Divider(
                          color: const Color(0xFFA6CE39),
                          height: 1,
                          thickness: 1,
                        ),
                        const SizedBox(height: 8),
                        // * UPDATE: Estatus dinámico (Activo para usuario, Estado para unidad)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // * Punto de color según el tipo
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: esUnidad 
                                    ? (_selectedUnidad!.estaEnRuta 
                                        ? const Color(0xFFA6CE39) // * Verde si está en ruta
                                        : Colors.orange) // * Naranja si no está en ruta
                                    : const Color(0xFFA6CE39), // * Verde para usuario
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              esUnidad 
                                  ? _selectedUnidad!.estado.toUpperCase()
                                  : 'Activo',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        // * UPDATE: Información adicional para unidades
                        if (esUnidad) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Conductor: ${_selectedUnidad!.conductor}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Velocidad: ${_selectedUnidad!.velocidad}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // * UPDATE: Sección derecha: Foto de perfil (usuario) o icono de vehículo (unidad)
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        height: 130,
                        color: Colors.white.withOpacity(0.2), // * Fondo semitransparente
                        child: esUnidad
                            ? _buildUnidadIcon()
                            : (user?.fotoPerfil != null && user!.fotoPerfil!.isNotEmpty
                                ? Image.network(
                                    user.fotoPerfil!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildDefaultAvatar();
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                  )
                                : _buildDefaultAvatar()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// * Construye el avatar por defecto si no hay foto de perfil
  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.white.withOpacity(0.2),
      child: const Center(
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  /// * UPDATE: Construye el icono de vehículo para unidades
  Widget _buildUnidadIcon() {
    return Container(
      color: Colors.white.withOpacity(0.2),
      child: Center(
        child: Icon(
          Icons.directions_bus, // * Icono de autobús/vehículo
          color: Colors.white,
          size: 60,
        ),
      ),
    );
  }

  // * Construir controles de zoom personalizados
  Widget _buildCustomZoomControls(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
          // * Botón zoom in
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                if (_mapController != null) {
                  await _mapController!.animateCamera(
                    gmaps.CameraUpdate.zoomIn(),
                  );
                }
              },
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF205AA8),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          // * Divisor
          Container(
            height: 1,
            color: Colors.grey[300],
          ),
          // * Botón zoom out
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                if (_mapController != null) {
                  await _mapController!.animateCamera(
                    gmaps.CameraUpdate.zoomOut(),
                  );
                }
              },
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF205AA8),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
                ),
                child: const Icon(
                  Icons.remove,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // * Construir FAB con opciones para geocercas y rutas
  Widget _buildMapOptionsFAB(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // * Botón para ocultar todo
        if (_currentView != null)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: _hideAll,
              backgroundColor: isDark ? Colors.grey[800] : Colors.white,
              child: Icon(
                Icons.close,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        // * Botón principal
        FloatingActionButton(
          onPressed: () {
            _showMapOptionsBottomSheet(isDark);
          },
          backgroundColor: const Color(0xFF205AA8),
          child: const Icon(Icons.layers, color: Colors.white),
        ),
      ],
    );
  }

  // * Mostrar bottom sheet con opciones
  void _showMapOptionsBottomSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Opciones del mapa',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                Icons.shape_line,
                color: _currentView == 'geocercas'
                    ? const Color(0xFF205AA8)
                    : (isDark ? Colors.white : Colors.black),
              ),
              title: Text(
                'Mostrar zonas',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              trailing: _currentView == 'geocercas'
                  ? const Icon(Icons.check, color: Color(0xFF205AA8))
                  : null,
              onTap: () {
                Navigator.pop(context);
                _showGeocercas();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.route,
                color: _currentView == 'rutas'
                    ? const Color(0xFF205AA8)
                    : (isDark ? Colors.white : Colors.black),
              ),
              title: Text(
                'Mostrar variantes',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              trailing: _currentView == 'rutas'
                  ? const Icon(Icons.check, color: Color(0xFF205AA8))
                  : null,
              onTap: () {
                Navigator.pop(context);
                _showRutas();
              },
            ),
            if (_currentView != null) ...[
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.visibility_off,
                  color: isDark ? Colors.white : Colors.black,
                ),
                title: Text(
                  'Ocultar todo',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _hideAll();
                },
              ),
            ],
            const SizedBox(height: 10),
          ],
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

/// * CustomPainter para dibujar la cola triangular del InfoWindow
class _InfoWindowTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A4A8F) // * Color del degradado más oscuro
      ..style = PaintingStyle.fill;

    // * Dibujar triángulo apuntando hacia abajo en el centro inferior
    final path = Path();
    final tailWidth = 16.0;
    final tailHeight = 12.0;
    final centerX = size.width / 2;
    final bottomY = size.height;

    path.moveTo(centerX - tailWidth / 2, bottomY);
    path.lineTo(centerX, bottomY + tailHeight);
    path.lineTo(centerX + tailWidth / 2, bottomY);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
