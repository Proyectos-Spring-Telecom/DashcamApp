
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
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppTheme>(
      stream: themeBloc.themeStream,
      initialData: themeBloc.currentTheme,
      builder: (context, snapshot) {
        final isDark = snapshot.data?.data.brightness == Brightness.dark;
        
        // Configurar el estilo de la barra de estado según el tema
        final systemUiOverlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Transparente para que use el color del Scaffold
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark, // iOS
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // Android
          systemNavigationBarColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        );
        
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemUiOverlayStyle,
          child: MaterialApp.router(
            routerConfig: AppRoutes.router(context: context),
            title: 'DashboardPro',
            theme: snapshot.data!.data,
          ),
        );
      },
    );
  }
}
