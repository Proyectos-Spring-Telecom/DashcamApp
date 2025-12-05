// Project imports:
import 'dart:async';
import 'package:dashboardpro/dashboardpro.dart';
import 'package:flutter/services.dart';

class BienvenidaPage extends StatefulWidget {
  const BienvenidaPage({super.key});

  @override
  State<BienvenidaPage> createState() => _BienvenidaPageState();
}

class _BienvenidaPageState extends State<BienvenidaPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simular carga inicial de la pantalla
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppTheme>(
      stream: themeBloc.themeStream,
      initialData: themeBloc.currentTheme,
      builder: (context, snapshot) {
        // Configurar status bar transparente para full-screen
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
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            body: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: _isLoading
                  ? _buildLoadingScreen()
                  : Responsive(
                      mobile: mobileWidget(context: context),
                      desktop: desktopWidget(context: context),
                      tablet: mobileWidget(context: context),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bienvenida_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            _buildLogo(),

            const SizedBox(height: 32),

            // Indicador de carga
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget mobileWidget({required BuildContext context}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bienvenida_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          // Spacer para centrar el logo verticalmente (ajustado para notch)
          const Spacer(flex: 40),

          // Logo DASHCAM PAY
          _buildLogo(),

          // Spacer para empujar el contenido hacia abajo
          const Spacer(flex: 2),

          // Tagline - al final de la vista, arriba del botón
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              "Viajes seguros, es lo que más importa.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Botón Comenzar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: _buildComenzarButton(context),
          ),
        ],
      ),
    );
  }

  Widget desktopWidget({required BuildContext context}) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      height: screenSize.height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bienvenida_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo - más grande para web
                _buildLogo(web: true),

                const SizedBox(height: 48),

                // Tagline - más grande para web
                Text(
                  "Viajes seguros, es lo que más importa.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 32),

                // Botón Comenzar - más grande para web
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      // Navegar al login
                      GoRouter.of(context).go(RoutesName.login);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF205AA8), // Azul
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Comenzar",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo({bool web = false}) {
    return Image.asset(
      'assets/images/logo_dash.png',
      height: web ? 180 : 120,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Si hay error, mostrar un placeholder para debug
        return Container(
          height: web ? 180 : 120,
          color: Colors.red.withOpacity(0.3),
          child: const Center(
            child: Text('Error cargando logo'),
          ),
        );
      },
    );
  }

  Widget _buildComenzarButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () {
          // Navegar al login
          GoRouter.of(context).go(RoutesName.login);
        },
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF205AA8), // Azul
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Comenzar",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
