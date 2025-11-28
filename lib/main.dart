import 'package:dashboardpro/dashboardpro.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Si no hay configuración de Firebase, la app puede continuar
    // Para producción, asegúrate de tener google-services.json configurado.
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
        return MaterialApp.router(
          routerConfig: AppRoutes.router(context: context),
          title: 'DashboardPro',
          theme: snapshot.data!.data,
        );
      },
    );
  }
}
