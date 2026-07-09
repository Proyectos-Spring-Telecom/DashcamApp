


import 'package:dashboardpro/dashboardpro.dart';
import 'package:flutter/services.dart';
import 'package:dashboardpro/core/env_config.dart';
import 'package:dashboardpro/core/env_loader.dart';
import 'package:dashboardpro/services/html_stub.dart' if (dart.library.html) 'dart:html' as html;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await loadAppEnv();

  // Inyectar script de Google Maps en web (--dart-define=GOOGLE_MAPS_API_KEY o .env)
  if (kIsWeb) {
    await _ensureGoogleMapsScriptLoaded();
  }

  // Inicializar el tema con la apariencia del sistema después de que el binding esté listo
  themeBloc.initializeWithSystemBrightness();
  
  // Inicializar el AuthBloc (carga el token y usuario si existen)
  await authBloc.initialize();
  
  runApp(const MyApp());
}

Future<void> _ensureGoogleMapsScriptLoaded() async {
  final key = EnvConfig.googleMapsApiKey;
  if (key.isEmpty) {
    return;
  }

  final existingScript = html.document.querySelector(
    'script[data-google-maps-sdk="1"]',
  );

  if (existingScript != null) {
    // Ya existe un script de maps en el DOM (por hot restart o carga previa).
    return;
  }

  final completer = Completer<void>();
  final script = html.ScriptElement()
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$key&libraries=places'
    ..setAttribute('data-google-maps-sdk', '1')
    ..setAttribute('async', '')
    ..setAttribute('defer', '');

  script.onLoad.listen((_) {
    if (!completer.isCompleted) completer.complete();
  });

  script.onError.listen((_) {
    if (!completer.isCompleted) {
      completer.completeError(
        Exception('No se pudo cargar Google Maps JavaScript API'),
      );
    }
  });

  html.document.head?.append(script);

  try {
    await completer.future.timeout(const Duration(seconds: 15));
  } catch (e) {
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  GoRouter? _router;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Detectar la apariencia del sistema después de que el widget esté montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateThemeFromSystem();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Liberar recursos de los blocs antes de destruir el widget
    authBloc.dispose();
    themeBloc.dispose();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // Escuchar cambios en la apariencia del sistema
    _updateThemeFromSystem();
  }

  void _updateThemeFromSystem() {
    try {
      // Usar PlatformDispatcher directamente
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final isDark = brightness == Brightness.dark;
      
      // Solo actualizar si es diferente al actual
      if (themeBloc.isDarkMode != isDark) {
        themeBloc.toggleDarkMode(isDark);
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    // Crear el router una sola vez para evitar que se recree en cada cambio de tema
    _router ??= AppRoutes.router(context: context);
    
    return StreamBuilder<AppTheme>(
      stream: themeBloc.themeStream,
      initialData: themeBloc.currentTheme,
      builder: (context, snapshot) {
        final isDark = snapshot.data?.data.brightness == Brightness.dark;
        
        // Configurar modo edge-to-edge con status bar transparente
        final systemUiOverlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Status bar transparente para edge-to-edge
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark, // iOS
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // Android
          systemNavigationBarColor: Colors.transparent, // Navigation bar transparente
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        );
        
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemUiOverlayStyle,
          child: MaterialApp.router(
            routerConfig: _router!,
            title: 'Monedero Digital',
            theme: snapshot.data!.data,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}
