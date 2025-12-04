
import 'package:dashboardpro/dashboardpro.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
        
        // Configurar el estilo de la barra de estado según el tema
        // Usar el mismo color de fondo que el Scaffold para que coincida
        final statusBarColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
        final systemUiOverlayStyle = SystemUiOverlayStyle(
          statusBarColor: statusBarColor, // Mismo color que el fondo del Scaffold
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark, // iOS
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // Android
          systemNavigationBarColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        );
        
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemUiOverlayStyle,
          child: MaterialApp.router(
            routerConfig: _router!,
            title: 'DashboardPro',
            theme: snapshot.data!.data,
          ),
        );
      },
    );
  }
}
