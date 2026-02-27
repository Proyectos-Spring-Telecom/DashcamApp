import 'package:dashboardpro/dashboardpro.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dashboardpro/controller/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno ANTES de cualquier servicio (no commitear .env)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env no existe (ej. primer clone): copia .env.example a .env y rellena valores
    debugPrint('⚠️ No se encontró .env. Copia .env.example a .env y configura las variables.');
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
