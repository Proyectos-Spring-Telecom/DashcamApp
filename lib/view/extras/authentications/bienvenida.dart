// Project imports:
import 'dart:async';
import 'package:dashboardpro/dashboardpro.dart';

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
        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          body: _isLoading
              ? _buildLoadingScreen()
              : Responsive(
                  mobile: mobileWidget(context: context),
                  desktop: desktopWidget(context: context),
                  tablet: mobileWidget(context: context),
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
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo app_icon
              Image.asset(
                'assets/images/app_icon.png',
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.red.withOpacity(0.3),
                    child: const Center(
                      child: Text('Error cargando logo'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Indicador de carga
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mobileWidget({required BuildContext context}) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      height: screenSize.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bienvenida_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Spacer para centrar el logo verticalmente
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
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo app_icon - más grande para web
                Image.asset(
                  'assets/images/app_icon.png',
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.red.withOpacity(0.3),
                      child: const Center(
                        child: Text('Error cargando logo'),
                      ),
                    );
                  },
                ),

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

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/app_icon.png',
      height: 120,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Si hay error, mostrar un placeholder para debug
        return Container(
          height: 120,
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
