
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:dashboardpro/dashboardpro.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:dashboardpro/controller/auth_bloc.dart';
import 'package:dashboardpro/services/html_stub.dart' if (dart.library.html) 'dart:html' as html;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inyectar script de Google Maps en web con la clave desde --dart-define (valor de android/local.properties)
  if (kIsWeb) {
    const key = String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');
    if (key.isNotEmpty) {
      final script = html.ScriptElement()
        ..src =
            'https://maps.googleapis.com/maps/api/js?key=$key&libraries=places&loading=async'
        ..setAttribute('async', '')
        ..setAttribute('defer', '');
      script.onError.listen((_) {
        // ignore: avoid_print
        print('Error al cargar Google Maps JavaScript API');
      });
      html.document.head?.append(script);
    }
  }

  // Inicializar Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Si no hay configuración de Firebase, la app puede continuar
    // Para producción, asegúrate de tener google-services.json configurado
    debugPrint('Firebase initialization error: $e');
  }
  
  // Inicializar el tema con la apariencia del sistema después de que el binding esté listo
  themeBloc.initializeWithSystemBrightness();
  
  // Inicializar el AuthBloc (carga el token y usuario si existen)
  await authBloc.initialize();
  
  runApp(const MyApp());
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
      debugPrint('🌓 Apariencia del sistema detectada: ${isDark ? "Oscuro" : "Claro"}');
      
      // Solo actualizar si es diferente al actual
      if (themeBloc.isDarkMode != isDark) {
        debugPrint('🔄 Actualizando tema a: ${isDark ? "Oscuro" : "Claro"}');
        themeBloc.toggleDarkMode(isDark);
      }
    } catch (e) {
      debugPrint('❌ Error actualizando tema desde sistema: $e');
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
