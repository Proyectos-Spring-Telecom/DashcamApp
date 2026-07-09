// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb, listEquals;
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

/// * Tipo de lista a mostrar en BottomSheet (Zonas, Ruta o Variantes).
/// ! CAMBIO DE FLUJO: ya no hay dropdown; se usa solo para abrir la lista correspondiente.
enum MapSelectionType { none, zonas, ruta, variantes }

class _TransportePageState extends State<TransportePage> {
  gmaps.GoogleMapController? _mapController;
  /// Último recurso si GPS/permisos fallan; no se usa como cámara inicial mientras carga el GPS.
  static const gmaps.LatLng _mapFallbackIfNoGps =
      gmaps.LatLng(19.4326, -99.1332);
  static const double _zoomContextoInicial = 15.0;
  static const double _zoomCercaMarkerUsuario = 17.35;

  // ! IMPORTANTE: Sets independientes por tipo de objeto; nunca sobrescribir un set al pintar otro.
  // ? INFO: markers del mapa = _userLocationMarker ∪ _vehicleMarkers ∪ _routeMarkers
  Set<gmaps.Marker> _userLocationMarker = {};
  Set<gmaps.Marker> _vehicleMarkers = {};
  Set<gmaps.Marker> _routeMarkers = {}; // * Marcadores inicio/fin de la ruta seleccionada
  Set<gmaps.Polygon> _zonePolygons = {};
  Set<gmaps.Polyline> _routePolylines = {};
  // ! IMPORTANTE: Sets independientes para variantes (polyline + estaciones)
  Set<gmaps.Polyline> _variantPolylines = {};
  Set<gmaps.Marker> _stationMarkers = {};

  /// * Unión de todos los markers para el mapa (usuario + unidades + inicio/fin ruta + estaciones variante).
  /// ⚠️ WARNING: No asignar a este getter; actualizar solo los sets individuales.
  Set<gmaps.Marker> get _allMarkers => {
    ..._userLocationMarker,
    ..._vehicleMarkers,
    ..._routeMarkers,
    ..._stationMarkers,
  };

  /// * Unión de todas las polylines (rutas + variantes).
  /// ⚠️ WARNING: No sobrescribir un set al agregar otro tipo de objeto.
  Set<gmaps.Polyline> get _allPolylines => {..._routePolylines, ..._variantPolylines};

  /// * Estilo del mapa: oculta comercios y puntos de interés (POI) en el mapa.
  static const String _mapStyleNoPoi = '''
[
  {"featureType": "poi", "stylers": [{"visibility": "off"}]},
  {"featureType": "poi.business", "stylers": [{"visibility": "off"}]}
]
''';

  gmaps.MapType _currentMapType = gmaps.MapType.normal;
  bool _isMapReady = false;
  /// Callback `onMapCreated` ya corrió; evita overlay si el mapa aparece rápido.
  bool _onMapCreatedInvoked = false;
  /// Solo true tras un debounce si [onMapCreated] aún no llegó (carga lenta).
  bool _showMapLoadingOverlay = false;
  bool _hasAuthError = false;
  String? _errorMessage;
  
  // * Estado para controlar qué se muestra
  String? _currentView; // 'geocercas' o 'rutas' o null

  // * Ubicación actual: el mapa solo se crea una vez resuelta (GPS o [ _mapFallbackIfNoGps ]).
  bool _isLoadingLocation = true;
  gmaps.LatLng? _currentLocation;
  
  // * Estado para el InfoWindow personalizado
  String? _selectedMarkerId;
  gmaps.LatLng? _selectedMarkerPosition;
  bool _isMarkerTapped = false; // * Flag para prevenir que el onTap del mapa limpie el estado
  
  // * UPDATE: Unidad seleccionada para mostrar en el InfoWindow personalizado
  UnidadModel? _selectedUnidad;
  
  // * UPDATE: Flag para evitar mostrar múltiples alertas de error
  bool _errorAlertShown = false;

  // ! IMPORTANTE: Flag para evitar múltiples QuickAlert de error de zonas
  bool _zonasErrorAlertShown = false;
  // ! IMPORTANTE: Flag para evitar múltiples QuickAlert de error de rutas
  bool _rutasErrorAlertShown = false;
  // ! IMPORTANTE: Flag para evitar múltiples QuickAlert de error de variantes
  bool _variantesErrorAlertShown = false;
  
  // * UPDATE: Cache de unidades para evitar actualizaciones innecesarias
  List<UnidadModel> _lastUnidades = [];

  @override
  void initState() {
    super.initState();
    // * Obtener la ubicación actual al inicializar
    _obtenerUbicacionActual();
    // * Cargar unidades de monitoreo al inicializar
    _cargarUnidades();
    // ! IMPORTANTE: Cargar zonas desde API para dropdown y pintado dinámico de geocercas
    _cargarZonas();
    // ! IMPORTANTE: Cargar rutas desde API para dropdown y pintado dinámico de polylines
    _cargarRutas();
    // ! IMPORTANTE: Cargar variantes desde API para listado y pintado con estaciones
    _cargarVariantes();
  }

  /// Muestra "Cargando mapa..." solo si [onMapCreated] tarda (evita parpadeo en carga rápida).
  void _startMapLoadingOverlayDebounce() {
    final delay = kIsWeb
        ? const Duration(milliseconds: 450)
        : const Duration(milliseconds: 350);
    Future.delayed(delay, () {
      if (!mounted || _onMapCreatedInvoked) return;
      setState(() {
        _showMapLoadingOverlay = true;
      });
    });
  }

  /// * Carga las variantes desde el servicio GET /variantes/list
  /// ? INFO: Listado para BottomSheet; pintado (polyline + estaciones) al seleccionar
  Future<void> _cargarVariantes() async {
    try {
      await variantesBloc.cargarVariantes();
    } catch (e) {
    }
  }

  /// * Carga las rutas desde el servicio GET /rutas/list
  /// ? INFO: Filtra estatus === 1 y ruta !== null; el dropdown NO pinta hasta que el usuario seleccione
  Future<void> _cargarRutas() async {
    try {
      await rutasBloc.cargarRutas();
    } catch (e) {
    }
  }

  /// * Carga las zonas desde el servicio GET /zonas/list
  /// ? INFO: Filtra estatus === 1 y geocerca !== null; el dropdown NO pinta hasta que el usuario seleccione
  Future<void> _cargarZonas() async {
    try {
      await zonasBloc.cargarZonas();
    } catch (e) {
      // * El error se expone por zonasBloc.errorStream y se muestra con QuickAlert
    }
  }

  /// * Carga las unidades de monitoreo desde el servicio
  /// Filtra automáticamente por cliente del token autenticado y clientes hijos
  Future<void> _cargarUnidades() async {
    try {
      await monitoreoBloc.cargarUnidades();
    } catch (e) {
      // * El error se manejará a través del stream de errores del bloc
    }
  }
  
  /// * Obtiene la ubicación actual del dispositivo (web y móvil; en web usa la API de geolocalización del navegador)
  Future<void> _obtenerUbicacionActual() async {
    // * Verificar que el widget esté montado antes de cualquier setState
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // * En móvil: verificar si los servicios de ubicación están habilitados. En web se omite (el navegador gestiona).
      if (!kIsWeb) {
        bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
        if (!mounted) return;
        if (!serviceEnabled) {
          _usarPosicionPorDefecto();
          return;
        }
      }

      // * Verificar permisos de ubicación (web: el navegador solicita; móvil: ya pueden estar otorgados desde el login)
      geo.LocationPermission permission = await geo.Geolocator.checkPermission();
      if (!mounted) return;

      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (!mounted) return;
      }
      if (permission == geo.LocationPermission.deniedForever) {
        _usarPosicionPorDefecto();
        return;
      }
      if (permission != geo.LocationPermission.whileInUse &&
          permission != geo.LocationPermission.always) {
        _usarPosicionPorDefecto();
        return;
      }

      // * Obtener la ubicación actual (web: usa navigator.geolocation del navegador)
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // * Verificar que el widget siga montado después de obtener la ubicación
      if (!mounted) return;

      final location = gmaps.LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = location;
        _isLoadingLocation = false;
      });
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _startMapLoadingOverlayDebounce();
        });
      }
      // * Si el mapa ya está creado, actualizar la cámara y los markers
      if (_mapController != null && mounted) {
        await _actualizarMapaConUbicacion(location);
      }
    } catch (e) {
      // * Verificar que el widget esté montado antes de usar posición por defecto
      if (mounted) {
        _usarPosicionPorDefecto();
      }
    }
  }
  
  /// * Último recurso: sin GPS / permisos; no sustituye la lógica de "ubicación actual" en ruta normal.
  void _usarPosicionPorDefecto() {
    if (mounted) {
      setState(() {
        _currentLocation = _mapFallbackIfNoGps;
        _isLoadingLocation = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _startMapLoadingOverlayDebounce();
      });
    }
  }
  
  /// * Pequeño acercamiento tras mostrar el marker del usuario (mejor lectura del entorno).
  Future<void> _acercarCamaraAlMarkerUsuario(gmaps.LatLng target) async {
    if (_mapController == null || !mounted) return;
    await Future.delayed(const Duration(milliseconds: 220));
    if (_mapController == null || !mounted) return;
    try {
      await _mapController!.animateCamera(
        gmaps.CameraUpdate.newCameraPosition(
          gmaps.CameraPosition(
            target: target,
            zoom: _zoomCercaMarkerUsuario,
          ),
        ),
      );
    } catch (e) {
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
            zoom: _zoomContextoInicial,
          ),
        ),
      );
      
      // * Actualizar los markers con la nueva ubicación
      final context = this.context;
      if (context.mounted) {
        await _addMarkers(context);
        await _acercarCamaraAlMarkerUsuario(location);
      }
    } catch (e) {
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

  // * Obtener rutas mock (lista estática para dropdown; TODO: reemplazar por API)
  List<RutaModel> _getMockRutas() {
    return [
      RutaModel(
        id: 'ruta_1',
        name: 'Ruta Cuernavaca',
        startPoint: const gmaps.LatLng(19.4326, -99.1332),
        endPoint: const gmaps.LatLng(19.4500, -99.1500),
        path: [
          const gmaps.LatLng(19.4326, -99.1332),
          const gmaps.LatLng(19.4380, -99.1400),
          const gmaps.LatLng(19.4450, -99.1450),
          const gmaps.LatLng(19.4500, -99.1500),
        ],
      ),
      RutaModel(
        id: 'ruta_2',
        name: 'Ruta Sur',
        startPoint: const gmaps.LatLng(19.4200, -99.1400),
        endPoint: const gmaps.LatLng(19.4100, -99.1300),
        path: [
          const gmaps.LatLng(19.4200, -99.1400),
          const gmaps.LatLng(19.4150, -99.1350),
          const gmaps.LatLng(19.4100, -99.1300),
        ],
      ),
    ];
  }

  // * Mostrar geocercas en el mapa
  void _onMarkerTapped() {
    if (_currentLocation == null) return;
    final position = _currentLocation!;
    
    setState(() {
      _isMarkerTapped = true;
      _selectedMarkerId = 'user_location';
      _selectedMarkerPosition = position;
      _selectedUnidad = null; // * Limpiar unidad seleccionada
    });
    
    // * Resetear el flag después de un breve delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isMarkerTapped = false;
        });
      }
    });
  }

  /// * UPDATE: Maneja el tap en el marker de una unidad
  void _onUnidadMarkerTapped(UnidadModel unidad) {
    final position = gmaps.LatLng(unidad.posicion.lat, unidad.posicion.lng);
    
    setState(() {
      _isMarkerTapped = true;
      _selectedMarkerId = 'unidad_${unidad.id}';
      _selectedMarkerPosition = position;
      _selectedUnidad = unidad; // * Guardar la unidad seleccionada
    });
    
    // * Resetear el flag después de un breve delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isMarkerTapped = false;
        });
      }
    });
  }

  /// * Pinta geocercas en el mapa.
  /// ! IMPORTANTE: Si [singleId] se proporciona (flujo dropdown), pinta la zona dinámica desde API:
  ///    1. Limpiar geocercas previas  2. Leer geocerca.features[0].geometry.coordinates
  ///    3. Convertir GeoJSON [lng, lat] → LatLng(lat, lng)  4. Construir Polygon  5. Pintar y ajustar cámara
  /// ? INFO: Sin singleId se usa mock (retrocompatibilidad).
  void _showGeocercas({String? singleId}) {
    // * Flujo dinámico: usuario seleccionó una zona en el dropdown (datos desde API)
    if (singleId != null) {
      final zone = zonasBloc.zonaPorId(singleId);
      if (zone == null || !zone.tieneGeocercaValida) {
        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Zona no disponible',
            text: 'La zona no se encontró o no tiene geocerca válida para pintar.',
            confirmBtnText: 'Aceptar',
            confirmBtnColor: const Color(0xFF205AA8),
          );
        }
        return;
      }
      // * GeoJSON: coordinates[0] = anillo exterior, cada punto es [lng, lat] → LatLng(lat, lng)
      final rawCoords = zone.getExteriorRingCoordinates();
      if (rawCoords.isEmpty) {
        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Geocerca inválida',
            text: 'No se pudieron leer las coordenadas de la zona.',
            confirmBtnText: 'Aceptar',
            confirmBtnColor: const Color(0xFF205AA8),
          );
        }
        return;
      }
      final points = rawCoords
          .map((p) => gmaps.LatLng(p[1], p[0]))
          .toList(); // [lng, lat] → LatLng(lat, lng)

      final polygonId = gmaps.PolygonId(zone.id.toString());
      final polygon = gmaps.Polygon(
        polygonId: polygonId,
        points: points,
        fillColor: Colors.blue.withOpacity(0.3),
        strokeColor: Colors.blue,
        strokeWidth: 2,
        geodesic: false,
      );

      // ! IMPORTANTE: Solo actualizar zonas; no tocar markers ni polylines
      setState(() {
        _zonePolygons = {polygon};
        _currentView = 'geocercas';
      });

      _adjustCameraToFit(latLngPoints: points);
      return;
    }

    // * Flujo mock: sin singleId (retrocompatibilidad)
    final allGeocercas = _getMockGeocercas();
    if (allGeocercas.isEmpty) return;

    final polygons = <gmaps.Polygon>{};
    for (var geocerca in allGeocercas) {
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

    // ! IMPORTANTE: Solo actualizar zonas; no tocar markers ni polylines
    setState(() {
      _zonePolygons = polygons;
      _currentView = 'geocercas';
    });

    _adjustCameraToFit(geocercas: allGeocercas);
  }

  /// * Pinta variantes (rutas) en el mapa.
  /// ? INFO: [singleId] opcional: si se proporciona, pinta esa ruta desde API (flujo dropdown). Sin singleId usa mock (Variantes).
  /// * UPDATE: Marcadores inicio/fin usan marker_inicio.png y marker_fin.png.
  Future<void> _showRutas({String? singleId}) async {
    // * Cargar iconos personalizados para inicio y fin de ruta
    gmaps.BitmapDescriptor? inicioIcon;
    gmaps.BitmapDescriptor? finIcon;
    try {
      final double dpr = mounted ? MediaQuery.devicePixelRatioOf(context) : 1.0;
      final double width = mounted ? MediaQuery.sizeOf(context).width : 600;
      // Web: tamaño proporcional (48 - 10% = 43). Móvil nativo: más pequeños si pantalla estrecha.
      final int markerSize = kIsWeb ? 30 : (width < 600 ? 72 : 130);
      // * Mismo tamaño que "mi posición" (60% del base) para homogeneidad
      final int routeMarkerSize = (markerSize * 0.6).round();
      final dataInicio = await rootBundle.load('assets/images/marker_inicio.png');
      final bytesInicio = dataInicio.buffer.asUint8List();
      inicioIcon = gmaps.BitmapDescriptor.fromBytes(
        await _resizeMarkerImage(bytesInicio, routeMarkerSize, pixelRatio: dpr),
      );
      final dataFin = await rootBundle.load('assets/images/marker_fin.png');
      final bytesFin = dataFin.buffer.asUint8List();
      finIcon = gmaps.BitmapDescriptor.fromBytes(
        await _resizeMarkerImage(bytesFin, routeMarkerSize, pixelRatio: dpr),
      );
    } catch (e) {
    }

    // * Flujo dinámico: usuario seleccionó una ruta en el dropdown (datos desde API)
    if (singleId != null) {
      final rutaApi = rutasBloc.rutaPorId(singleId);
      if (rutaApi == null) {
        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Ruta no disponible',
            text: 'La ruta no se encontró.',
            confirmBtnText: 'Aceptar',
            confirmBtnColor: const Color(0xFF205AA8),
          );
        }
        return;
      }
      if (!rutaApi.tieneRutaValida) {
        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Ruta sin datos',
            text: 'La ruta no tiene coordenadas para pintar.',
            confirmBtnText: 'Aceptar',
            confirmBtnColor: const Color(0xFF205AA8),
          );
        }
        return;
      }

      // * Convertir coordenadas API [lng, lat] → LatLng(lat, lng)
      final path = rutaApi.ruta
          .map((p) => gmaps.LatLng(p[1], p[0]))
          .toList();
      final startPoint = gmaps.LatLng(rutaApi.puntoInicioLat, rutaApi.puntoInicioLng);
      final endPoint = gmaps.LatLng(rutaApi.puntoFinLat, rutaApi.puntoFinLng);

      // ! IMPORTANTE: Polyline azul como FAB; si la API no envía "ruta", dibujar línea inicio→fin
      final polylinePoints = path.isNotEmpty ? path : [startPoint, endPoint];
      final polylineId = gmaps.PolylineId(rutaApi.id.toString());
      final polylines = <gmaps.Polyline>{
        gmaps.Polyline(
          polylineId: polylineId,
          points: polylinePoints,
          color: const Color(0xFF205AA8), // * Azul igual que botones flotantes
          width: 3,
          geodesic: false,
          patterns: [
            gmaps.PatternItem.dash(20),
            gmaps.PatternItem.gap(15),
          ],
        ),
      };

      // ! IMPORTANTE: Solo actualizar polylines y markers de ruta (inicio/fin); no tocar usuario, unidades ni zonas
      final routeMarkers = <gmaps.Marker>{
        gmaps.Marker(
          markerId: gmaps.MarkerId('${rutaApi.id}_start'),
          position: startPoint,
          icon: inicioIcon ?? gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueGreen,
          ),
          infoWindow: gmaps.InfoWindow(
            title: 'Inicio: ${rutaApi.nombre}',
          ),
        ),
        gmaps.Marker(
          markerId: gmaps.MarkerId('${rutaApi.id}_end'),
          position: endPoint,
          icon: finIcon ?? gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueRed,
          ),
          infoWindow: gmaps.InfoWindow(
            title: 'Fin: ${rutaApi.nombre}',
          ),
        ),
      };

      if (!mounted) return;
      setState(() {
        _routePolylines = polylines;
        _routeMarkers = routeMarkers;
        _currentView = 'rutas';
      });

      final allPoints = [startPoint, endPoint, ...path];
      _adjustCameraToFit(latLngPoints: allPoints);
      return;
    }

    // * Flujo mock: Variantes (sin singleId)
    final allRutas = _getMockRutas();
    if (allRutas.isEmpty) return;

    final polylines = <gmaps.Polyline>{};
    final markers = <gmaps.Marker>{};

    for (var ruta in allRutas) {
      polylines.add(
        gmaps.Polyline(
          polylineId: gmaps.PolylineId(ruta.id),
          points: ruta.path,
          color: const Color(0xFF205AA8), // * Azul igual que botones flotantes
          width: 3,
          geodesic: false,
          patterns: [
            gmaps.PatternItem.dash(20),
            gmaps.PatternItem.gap(15),
          ],
        ),
      );
      markers.add(
        gmaps.Marker(
          markerId: gmaps.MarkerId('${ruta.id}_start'),
          position: ruta.startPoint,
          icon: inicioIcon ?? gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueGreen,
          ),
          infoWindow: gmaps.InfoWindow(
            title: 'Inicio: ${ruta.name}',
          ),
        ),
      );
      markers.add(
        gmaps.Marker(
          markerId: gmaps.MarkerId('${ruta.id}_end'),
          position: ruta.endPoint,
          icon: finIcon ?? gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueRed,
          ),
          infoWindow: gmaps.InfoWindow(
            title: 'Fin: ${ruta.name}',
          ),
        ),
      );
    }

    if (!mounted) return;
    // ! IMPORTANTE: Solo actualizar polylines y markers de ruta; no tocar usuario, unidades ni zonas
    setState(() {
      _routePolylines = polylines;
      _routeMarkers = markers;
      _currentView = 'rutas';
    });

    _adjustCameraToFit(rutas: allRutas);
  }

  /// * Pinta la variante seleccionada en el mapa: polyline + estaciones (markers).
  /// ? INFO: Solo actualiza _variantPolylines y _stationMarkers; no toca zonas, rutas, unidades ni usuario.
  /// ⚠️ WARNING: No sobrescribir otros sets del mapa.
  /// * UPDATE: Marcadores de estaciones usan imagen marker_variante.png.
  Future<void> _showVariantes({String? singleId}) async {
    if (singleId == null) return;
    final variante = variantesBloc.variantePorId(singleId);
    if (variante == null) {
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Variante no disponible',
          text: 'La variante no se encontró.',
          confirmBtnText: 'Aceptar',
          confirmBtnColor: const Color(0xFF205AA8),
        );
      }
      return;
    }
    if (!variante.tieneRecorridoValido) {
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Variante sin datos',
          text: 'La variante no tiene coordenadas para pintar.',
          confirmBtnText: 'Aceptar',
          confirmBtnColor: const Color(0xFF205AA8),
        );
      }
      return;
    }

    // * Icono variante (estaciones): 30% del base; inicio y fin: 60% del base (homogéneo con "mi posición")
    gmaps.BitmapDescriptor? varianteIcon;
    gmaps.BitmapDescriptor? inicioIcon;
    gmaps.BitmapDescriptor? finIcon;
    final double dpr = mounted ? MediaQuery.devicePixelRatioOf(context) : 1.0;
    final double width = mounted ? MediaQuery.sizeOf(context).width : 600;
    // Web: tamaño proporcional (48 - 10% = 43). Móvil nativo: más pequeños si pantalla estrecha.
    final int markerSize = kIsWeb ? 30 : (width < 600 ? 72 : 130);
    final int variantMarkerSize = (markerSize * 0.3).round(); // * Solo para marker_variante (estaciones)
    final int variantInicioFinSize = (markerSize * 0.6).round();
    try {
      final dataVar = await rootBundle.load('assets/images/marker_variante.png');
      varianteIcon = gmaps.BitmapDescriptor.fromBytes(
        await _resizeMarkerImage(dataVar.buffer.asUint8List(), variantMarkerSize, pixelRatio: dpr),
      );
    } catch (e) {
    }
    try {
      final dataInicio = await rootBundle.load('assets/images/marker_inicio.png');
      inicioIcon = gmaps.BitmapDescriptor.fromBytes(
        await _resizeMarkerImage(dataInicio.buffer.asUint8List(), variantInicioFinSize, pixelRatio: dpr),
      );
    } catch (e) {
    }
    try {
      final dataFin = await rootBundle.load('assets/images/marker_fin.png');
      finIcon = gmaps.BitmapDescriptor.fromBytes(
        await _resizeMarkerImage(dataFin.buffer.asUint8List(), variantInicioFinSize, pixelRatio: dpr),
      );
    } catch (e) {
    }

    // ? INFO: puntoInicio y puntoFin del JSON (coordenadas); polyline = inicio + recorridoDetallado + fin
    final startPoint = gmaps.LatLng(variante.puntoInicioLat, variante.puntoInicioLng);
    final endPoint = gmaps.LatLng(variante.puntoFinLat, variante.puntoFinLng);
    final estacionPoints = variante.recorridoDetallado
        .map((e) => gmaps.LatLng(e.lat, e.lng))
        .toList();
    final polylinePoints = [startPoint, ...estacionPoints, endPoint];

    final polylineId = gmaps.PolylineId('variante_${variante.id}');
    final polylines = <gmaps.Polyline>{
      gmaps.Polyline(
        polylineId: polylineId,
        points: polylinePoints,
        color: const Color(0xFF205AA8),
        width: 3,
        geodesic: false,
        patterns: [
          gmaps.PatternItem.dash(20),
          gmaps.PatternItem.gap(15),
        ],
      ),
    };

    // ! IMPORTANTE: Pintar puntoInicio, estaciones (recorridoDetallado) y puntoFin
    final stationMarkers = <gmaps.Marker>{};
    // * Marcador puntoInicio (del JSON puntoInicio.coordenadas)
    stationMarkers.add(
      gmaps.Marker(
        markerId: gmaps.MarkerId('variante_${variante.id}_inicio'),
        position: startPoint,
        icon: inicioIcon ?? gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueGreen,
        ),
        infoWindow: gmaps.InfoWindow(title: 'Inicio: ${variante.nombreVariante}'),
      ),
    );
    // * Marcadores de estaciones (recorridoDetallado)
    for (var i = 0; i < variante.recorridoDetallado.length; i++) {
      final e = variante.recorridoDetallado[i];
      final position = gmaps.LatLng(e.lat, e.lng);
      final title = e.nombre != null && e.nombre!.isNotEmpty
          ? e.nombre!
          : 'Estación ${i + 1}';
      stationMarkers.add(
        gmaps.Marker(
          markerId: gmaps.MarkerId('variante_${variante.id}_estacion_$i'),
          position: position,
          icon: varianteIcon ?? gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueOrange,
          ),
          infoWindow: gmaps.InfoWindow(title: title),
        ),
      );
    }
    // * Marcador puntoFin (del JSON puntoFin.coordenadas)
    stationMarkers.add(
      gmaps.Marker(
        markerId: gmaps.MarkerId('variante_${variante.id}_fin'),
        position: endPoint,
        icon: finIcon ?? gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueRed,
        ),
        infoWindow: gmaps.InfoWindow(title: 'Fin: ${variante.nombreVariante}'),
      ),
    );

    if (!mounted) return;
    setState(() {
      _variantPolylines = polylines;
      _stationMarkers = stationMarkers;
      _currentView = 'variantes';
    });

    final allPoints = [startPoint, endPoint, ...estacionPoints];
    _adjustCameraToFit(latLngPoints: allPoints);
  }

  /// * Ocultar geocercas/variantes/rutas y restaurar vista por defecto.
  /// ? INFO: Solo limpia zonas, rutas y variantes; usuario y unidades siguen visibles.
  void _hideAll() {
    setState(() {
      _zonePolygons = {};
      _routePolylines = {};
      _routeMarkers = {};
      _variantPolylines = {};
      _stationMarkers = {};
      _currentView = null;
    });

    if (_mapController != null && _currentLocation != null) {
      final context = this.context;
      if (context.mounted) {
        _addMarkers(context);
        final targetPosition = _currentLocation!;
        _mapController!.animateCamera(
          gmaps.CameraUpdate.newCameraPosition(
            gmaps.CameraPosition(
              target: targetPosition,
              zoom: _zoomCercaMarkerUsuario,
            ),
          ),
        );
      }
    }
  }

  // * Ajustar cámara para mostrar geocercas, rutas o puntos de un polígono (zonas dinámicas)
  /// ? INFO: [latLngPoints] se usa al pintar geocerca dinámica desde API (GeoJSON → LatLng)
  Future<void> _adjustCameraToFit({
    List<GeocercaModel>? geocercas,
    List<RutaModel>? rutas,
    List<gmaps.LatLng>? latLngPoints,
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

    if (latLngPoints != null && latLngPoints.isNotEmpty) {
      allPoints.addAll(latLngPoints);
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

  /// Redimensiona la imagen del marcador.
  /// [targetSize] = tamaño lógico deseado (px).
  /// [pixelRatio] = device pixel ratio (ej. 2 en móvil) para generar imagen nítida en pantallas alta densidad.
  /// Se genera la imagen a targetSize * pixelRatio (máx 256) para evitar pixelado en web/móvil.
  Future<Uint8List> _resizeMarkerImage(
    Uint8List imageBytes,
    int targetSize, {
    double pixelRatio = 1.0,
  }) async {
    final int renderSize = (targetSize * pixelRatio).round().clamp(targetSize, 256);
    final codec = await ui.instantiateImageCodec(imageBytes, targetWidth: renderSize);
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
    if (!mounted || _currentLocation == null) return;

    final position = _currentLocation!;
    
    // ! IMPORTANTE: Actualizar solo _userLocationMarker y _vehicleMarkers; no tocar _routeMarkers, zonas ni polylines
    final Set<gmaps.Marker> userMarkers = {};
    final Set<gmaps.Marker> vehicleMarkers = {};
    gmaps.BitmapDescriptor? busIcon;

    try {
      final double dpr = MediaQuery.devicePixelRatioOf(context);
      final double width = MediaQuery.sizeOf(context).width;
      // Web: tamaño proporcional (48 - 10% = 43). Móvil nativo: más pequeños si pantalla estrecha.
      final int markerSize = kIsWeb ? 30 : (width < 600 ? 72 : 130);
      final ByteData data = await rootBundle.load('assets/images/marker_dash.png');
      final Uint8List originalBytes = data.buffer.asUint8List();
      // * Marcador de "mi posición" 60% del tamaño base
      final int userMarkerSize = (markerSize * 0.6).round();
      final Uint8List resizedBytes = await _resizeMarkerImage(originalBytes, userMarkerSize, pixelRatio: dpr);
      final customIcon = gmaps.BitmapDescriptor.fromBytes(resizedBytes);

      try {
        final ByteData busData = await rootBundle.load('assets/images/marker_bus.png');
        final Uint8List busOriginalBytes = busData.buffer.asUint8List();
        final Uint8List busResizedBytes = await _resizeMarkerImage(busOriginalBytes, userMarkerSize, pixelRatio: dpr);
        busIcon = gmaps.BitmapDescriptor.fromBytes(busResizedBytes);
      } catch (e) {
      }

      userMarkers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('user_location'),
          position: position,
          icon: customIcon,
          infoWindow: const gmaps.InfoWindow(),
          anchor: const Offset(0.5, 1.0),
          onTap: _onMarkerTapped,
        ),
      );
    } catch (e, stackTrace) {
      userMarkers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('user_location'),
          position: position,
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
              gmaps.BitmapDescriptor.hueBlue),
          infoWindow: const gmaps.InfoWindow(),
          onTap: _onMarkerTapped,
        ),
      );
    }

    final unidades = monitoreoBloc.unidadesConPosicionValida;

    for (var unidad in unidades) {
      try {
        vehicleMarkers.add(
          gmaps.Marker(
            markerId: gmaps.MarkerId('unidad_${unidad.id}'),
            position: gmaps.LatLng(unidad.posicion.lat, unidad.posicion.lng),
            icon: busIcon ?? gmaps.BitmapDescriptor.defaultMarkerWithHue(
              unidad.estaEnRuta
                  ? gmaps.BitmapDescriptor.hueGreen
                  : gmaps.BitmapDescriptor.hueOrange,
            ),
            infoWindow: const gmaps.InfoWindow(),
            onTap: () => _onUnidadMarkerTapped(unidad),
          ),
        );
      } catch (e) {
      }
    }

    if (mounted) {
      setState(() {
        _userLocationMarker = userMarkers;
        _vehicleMarkers = vehicleMarkers;
      });
    }
  }

  Future<void> _onMapCreated(gmaps.GoogleMapController controller) async {
    if (!mounted) return;
    _mapController = controller;
    // Listo para UI: sin [Future.delayed] artificial; el overlay depende de [_showMapLoadingOverlay].
    setState(() {
      _onMapCreatedInvoked = true;
      _showMapLoadingOverlay = false;
      _isMapReady = true;
    });

    if (mounted) {
        final current = _currentLocation;
        if (current == null) return;
        // * Cámara sobre la misma [LatLng] que se usó al crear el mapa (siempre resuelta vía GPS o fallback)
        final targetPosition = current;
        try {
          await controller.animateCamera(
            gmaps.CameraUpdate.newCameraPosition(
              gmaps.CameraPosition(
                target: targetPosition,
                zoom: _zoomContextoInicial,
              ),
            ),
          );
        } catch (e) {
        }

        // Cargar los marcadores después de que el mapa esté creado
        final context = this.context;
        if (context.mounted) {
          await _addMarkers(context);
          await _acercarCamaraAlMarkerUsuario(targetPosition);
        }


        // Aplicar estilo para ocultar comercios/POI en el mapa (web y móvil)
        if (mounted) {
          try {
            await controller.setMapStyle(_mapStyleNoPoi);
          } catch (e) {
          }
        }

        // Verificar si el mapa se renderizó correctamente después de un tiempo
        // Si el mapa muestra solo el fondo café sin calles, hay un problema de autorización
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && !_hasAuthError) {
            // Detectar posible error de autorización
            // Nota: Google Maps no proporciona un callback directo para esto,
            // pero podemos mostrar instrucciones si el usuario reporta el problema
            if (!kIsWeb) {
            } else {
            }
          }
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
                        
                        return StreamBuilder<String?>(
                          stream: zonasBloc.errorStream,
                          initialData: zonasBloc.errorMessage,
                          builder: (context, zonasErrorSnapshot) {
                            // ! IMPORTANTE: QuickAlert para errores del servicio de zonas
                            final zonasErrorMessage = zonasErrorSnapshot.data;
                            if (zonasErrorMessage != null &&
                                zonasErrorMessage.isNotEmpty &&
                                mounted &&
                                !_zonasErrorAlertShown) {
                              _zonasErrorAlertShown = true;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    title: 'Error al cargar zonas',
                                    text: zonasErrorMessage,
                                    confirmBtnText: 'Aceptar',
                                    confirmBtnColor: const Color(0xFF205AA8),
                                    onConfirmBtnTap: () {
                                      zonasBloc.limpiarError();
                                      _zonasErrorAlertShown = false;
                                    },
                                  );
                                }
                              });
                            } else if (zonasErrorMessage == null ||
                                zonasErrorMessage.isEmpty) {
                              _zonasErrorAlertShown = false;
                            }

                            return StreamBuilder<String?>(
                              stream: rutasBloc.errorStream,
                              initialData: rutasBloc.errorMessage,
                              builder: (context, rutasErrorSnapshot) {
                                final rutasErrorMessage = rutasErrorSnapshot.data;
                                if (rutasErrorMessage != null &&
                                    rutasErrorMessage.isNotEmpty &&
                                    mounted &&
                                    !_rutasErrorAlertShown) {
                                  _rutasErrorAlertShown = true;
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) {
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.error,
                                        title: 'Error al cargar rutas',
                                        text: rutasErrorMessage,
                                        confirmBtnText: 'Aceptar',
                                        confirmBtnColor: const Color(0xFF205AA8),
                                        onConfirmBtnTap: () {
                                          rutasBloc.limpiarError();
                                          _rutasErrorAlertShown = false;
                                        },
                                      );
                                    }
                                  });
                                } else if (rutasErrorMessage == null ||
                                    rutasErrorMessage.isEmpty) {
                                  _rutasErrorAlertShown = false;
                                }

                                return StreamBuilder<String?>(
                                  stream: variantesBloc.errorStream,
                                  initialData: variantesBloc.errorMessage,
                                  builder: (context, variantesErrorSnapshot) {
                                    // ! IMPORTANTE: QuickAlert para errores del servicio de variantes
                                    final variantesErrorMessage = variantesErrorSnapshot.data;
                                    if (variantesErrorMessage != null &&
                                        variantesErrorMessage.isNotEmpty &&
                                        mounted &&
                                        !_variantesErrorAlertShown) {
                                      _variantesErrorAlertShown = true;
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        if (mounted) {
                                          QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.error,
                                            title: 'Error al cargar variantes',
                                            text: variantesErrorMessage,
                                            confirmBtnText: 'Aceptar',
                                            confirmBtnColor: const Color(0xFF205AA8),
                                            onConfirmBtnTap: () {
                                              variantesBloc.limpiarError();
                                              _variantesErrorAlertShown = false;
                                            },
                                          );
                                        }
                                      });
                                    } else if (variantesErrorMessage == null ||
                                        variantesErrorMessage.isEmpty) {
                                      _variantesErrorAlertShown = false;
                                    }

                                    return Column(
                                      children: [
                                        _buildHeader(context, isDark: isDark),
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

          // Title centrado - Movilidad Inteligente
          Expanded(
            child: Center(
              child: Text(
                "Movilidad Inteligente",
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
          if (_isLoadingLocation && _currentLocation == null)
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
                      'Obteniendo tu ubicación...',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!_isLoadingLocation && _currentLocation != null)
            gmaps.GoogleMap(
              key: ValueKey<Object>(
                '${_currentLocation!.latitude},${_currentLocation!.longitude}',
              ),
              initialCameraPosition: gmaps.CameraPosition(
                target: _currentLocation!,
                zoom: _zoomContextoInicial,
                tilt: 0,
              ),
              // ? INFO: Unión de todos los markers (usuario + unidades + rutas + estaciones variante)
              markers: _allMarkers,
              polygons: _zonePolygons,
              // ? INFO: Unión de polylines (rutas + variantes)
              polylines: _allPolylines,
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
                // Respaldo (p. ej. web): el mapa es interactivo aunque falle un edge case del callback
                if ((!_isMapReady || !_onMapCreatedInvoked) && mounted) {
                  setState(() {
                    _isMapReady = true;
                    _onMapCreatedInvoked = true;
                    _showMapLoadingOverlay = false;
                  });
                }
                // * Cerrar InfoWindow personalizado si el usuario mueve el mapa
                // * PERO NO si se acaba de tocar el marker
                if (_selectedMarkerId != null && !_isMarkerTapped) {
                  setState(() {
                    _selectedMarkerId = null;
                    _selectedMarkerPosition = null;
                    _selectedUnidad = null; // * UPDATE: Limpiar unidad seleccionada
                  });
                } else if (_isMarkerTapped) {
                }
              },
              onTap: (gmaps.LatLng position) {
                // * Cerrar InfoWindow personalizado si se toca el mapa
                // * PERO NO si se acaba de tocar el marker (para evitar que se cierre inmediatamente)
                if (_selectedMarkerId != null && !_isMarkerTapped) {
                  setState(() {
                    _selectedMarkerId = null;
                    _selectedMarkerPosition = null;
                    _selectedUnidad = null; // * UPDATE: Limpiar unidad seleccionada
                  });
                } else if (_isMarkerTapped) {
                }
              },
            ),
          // ! CAMBIO DE FLUJO: eliminación del dropdown; listas se abren directamente desde "Opciones del mapa".
          // Carga: solo si [onMapCreated] tarda más que el debounce (no cubrir carga rápida)
          if (_showMapLoadingOverlay && !_hasAuthError)
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
                            _onMapCreatedInvoked = false;
                            _showMapLoadingOverlay = false;
                            _isMapReady = false;
                          });
                          _startMapLoadingOverlayDebounce();
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
                        // * UPDATE: Información adicional para pasajero (mi ubicación): Correo, Teléfono, Último Acceso
                        if (!esUnidad && user != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Correo: ${user.userName.isNotEmpty ? user.userName : 'N/A'}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Teléfono: ${user.telefono != null && user.telefono!.isNotEmpty ? user.telefono : 'N/A'}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Último Acceso: ${user.ultimoLogin != null && user.ultimoLogin!.isNotEmpty ? user.ultimoLogin : 'N/A'}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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

  /// * Abre directamente el BottomSheet con la lista (zonas, rutas o variantes).
  /// ! CAMBIO DE FLUJO: acceso directo a listas desde "Opciones del mapa"; no hay dropdown.
  /// ⚠️ WARNING: no modificar lógica del mapa; solo UX de apertura del modal.
  void _showListBottomSheet(bool isDark, MapSelectionType type) {
    final isZonas = type == MapSelectionType.zonas;
    final isRuta = type == MapSelectionType.ruta;
    final isVariantes = type == MapSelectionType.variantes;
    if (isRuta && rutasBloc.rutas.isEmpty) {
      rutasBloc.cargarRutas();
    }
    if (isVariantes && variantesBloc.variantes.isEmpty) {
      variantesBloc.cargarVariantes();
    }
    final items = isZonas
        ? zonasBloc.zonas.map((z) => MapEntry(z.id.toString(), z.nombre)).toList()
        : isRuta
            ? rutasBloc.rutas.map((r) => MapEntry(r.id.toString(), r.nombre)).toList()
            : variantesBloc.variantes.map((v) => MapEntry(v.id.toString(), v.nombreVariante)).toList();
    final searchHint = isRuta ? 'Buscar ruta...' : (isVariantes ? 'Buscar variante...' : null);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _DropdownSelectionModalContent(
        isDark: isDark,
        isZonas: isZonas,
        isRuta: isRuta,
        searchHint: searchHint,
        items: items,
        onSelect: (String id) {
          Navigator.pop(context);
          if (isZonas) {
            _showGeocercas(singleId: id);
          } else if (isRuta) {
            _showRutas(singleId: id);
          } else {
            _showVariantes(singleId: id);
          }
        },
      ),
    );
  }

  // * Construir FAB con opciones para geocercas y rutas
  Widget _buildMapOptionsFAB(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // * Botón para ocultar todo (visible solo si hay algo pintado en el mapa)
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

  // * Mostrar bottom sheet con opciones del mapa.
  /// ? UX: al seleccionar Zonas/Ruta/Variantes se cierra este sheet y se abre directamente la lista correspondiente.
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
            // ? UX: acceso directo a listas; al tap se cierra este sheet y se abre la lista (zonas/rutas/variantes).
            ListTile(
              leading: Icon(
                Icons.shape_line,
                color: isDark ? Colors.white : Colors.black,
              ),
              title: Text(
                'Zonas',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showListBottomSheet(isDark, MapSelectionType.zonas);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.add_road,
                color: isDark ? Colors.white : Colors.black,
              ),
              title: Text(
                'Ruta',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showListBottomSheet(isDark, MapSelectionType.ruta);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.route,
                color: isDark ? Colors.white : Colors.black,
              ),
              title: Text(
                'Variantes',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showListBottomSheet(isDark, MapSelectionType.variantes);
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
    // No llamar a [GoogleMapController.dispose]: lo gestiona el propio [GoogleMap]
    // (en web, dispose manual dispara: Maps cannot be retrieved before calling buildView).
    _mapController = null;
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

/// * Contenido del modal de selección con búsqueda (Zonas, Ruta o Variantes).
/// ? INFO: Lista estática (mock); preparado para reemplazar por API.
class _DropdownSelectionModalContent extends StatefulWidget {
  final bool isDark;
  final bool isZonas;
  /// true cuando la lista es de rutas (icono add_road); false para variantes (icono route).
  final bool isRuta;
  /// Hint del campo de búsqueda. Si null, se usa "Buscar zona..." o "Buscar variante..." según isZonas.
  final String? searchHint;
  final List<MapEntry<String, String>> items;
  final void Function(String id) onSelect;

  const _DropdownSelectionModalContent({
    required this.isDark,
    required this.isZonas,
    required this.isRuta,
    this.searchHint,
    required this.items,
    required this.onSelect,
  });

  @override
  State<_DropdownSelectionModalContent> createState() =>
      _DropdownSelectionModalContentState();
}

class _DropdownSelectionModalContentState
    extends State<_DropdownSelectionModalContent> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ! IMPORTANTE: Altura mínima para mostrar al menos ~10 ítems (ListTile ~56px)
  static const double _minListHeight = 10 * 56.0;

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((e) => e.value.toLowerCase().contains(_query))
        .toList();
    // * Color en modo oscuro: #2E2E2E (fondo del modal y borde del TextField)
    const Color darkBgColor = Color(0xFF2E2E2E);
    final bgColor = widget.isDark ? darkBgColor : Colors.white;
    final textColor = widget.isDark ? Colors.white : Colors.black;
    final screenHeight = MediaQuery.of(context).size.height;
    // ! IMPORTANTE: maxHeight debe ser >= minHeight (BoxConstraints normalizados)
    final maxModalHeight = screenHeight * 0.6;
    final desiredMinHeight = _minListHeight + 120;
    final minModalHeight = desiredMinHeight.clamp(0.0, maxModalHeight);
    // Altura de la lista: ~10 ítems visibles, sin exceder el espacio disponible en el modal
    final listHeight = _minListHeight.clamp(0.0, maxModalHeight - 120);

    return Container(
      constraints: BoxConstraints(
        minHeight: minModalHeight,
        maxHeight: maxModalHeight,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.grey[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.searchHint ??
                    (widget.isZonas ? 'Buscar zona...' : 'Buscar variante...'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.isDark ? darkBgColor : Colors.grey[400]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.isDark ? darkBgColor : Colors.grey[400]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.isDark ? darkBgColor : const Color(0xFF205AA8),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: widget.isDark ? Colors.grey[800] : Colors.grey[100],
              ),
              style: TextStyle(color: textColor),
            ),
          ),
          // ? INFO: Lista con altura fija (~10 ítems); scroll si hay más
          SizedBox(
            height: listHeight,
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final entry = filtered[index];
                return ListTile(
                  leading: Icon(
                    widget.isZonas
                        ? Icons.shape_line
                        : (widget.isRuta ? Icons.add_road : Icons.route),
                    color: const Color(0xFF205AA8),
                  ),
                  title: Text(
                    entry.value,
                    style: TextStyle(color: textColor),
                  ),
                  onTap: () => widget.onSelect(entry.key),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
