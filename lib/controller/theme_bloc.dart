import 'package:dashboardpro/dashboardpro.dart';
import 'dart:ui' as ui;

class ThemeBloc {
  final _themeController = StreamController<AppTheme>.broadcast();
  Stream<AppTheme> get themeStream => _themeController.stream;
  ColorSeed _currentColorSeed = ColorSeed.baseColor; // Default color seed
  
  // Inicializar campos no-nullables
  late AppTheme _currentTheme;
  late bool _isDarkMode;

  AppTheme get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode; // Getter to check current mode
  ColorSeed get currentColorSeed => _currentColorSeed;

  ThemeBloc() {
    // Inicializar con modo claro por defecto, se actualizará después
    _isDarkMode = false;
    _currentTheme = AppTheme(data: buildAppTheme(_currentColorSeed.color));
    _themeController.sink.add(_currentTheme);
  }

  // Inicializar con la apariencia del sistema (debe llamarse después de WidgetsFlutterBinding.ensureInitialized())
  void initializeWithSystemBrightness() {
    _isDarkMode = _detectSystemBrightness();
    _currentTheme = AppTheme(data: buildAppTheme(_currentColorSeed.color));
    _themeController.sink.add(_currentTheme);
  }

  // Detectar la apariencia del sistema (claro/oscuro)
  bool _detectSystemBrightness() {
    try {
      // Usar WidgetsBinding para obtener el brightness del sistema
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final isDark = brightness == ui.Brightness.dark;
      return isDark;
    } catch (e) {
      // Si hay algún error, intentar con PlatformDispatcher directamente
      try {
        final brightness = ui.PlatformDispatcher.instance.platformBrightness;
        final isDark = brightness == ui.Brightness.dark;
        return isDark;
      } catch (e2) {
        // Si hay algún error, usar modo claro por defecto
        return false;
      }
    }
  }

  void dispose() {
    _themeController.close();
  }

  void toggleDarkMode(bool isDarkMode) {
    _isDarkMode = isDarkMode; // Update the mode flag
    _currentTheme = AppTheme(data: buildAppTheme(_currentColorSeed.color));
    _themeController.sink.add(_currentTheme);
  }

  void updateColorSeed(ColorSeed colorSeed) {
    _currentColorSeed = colorSeed;
    _currentTheme = AppTheme(data: buildAppTheme(colorSeed.color));
    _themeController.sink.add(_currentTheme);
  }

  // Set Default Theme
  ThemeData buildAppTheme(Color seedColor) {
    return ThemeData(
      pageTransitionsTheme: NoTransitionsOnWeb(),
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0.0,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: const CardThemeData(
        shadowColor: Colors.transparent,
      ),
    );
  }
}

final themeBloc = ThemeBloc();