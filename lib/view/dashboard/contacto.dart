// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:flutter/services.dart';

class ContactoPage extends StatelessWidget {
  const ContactoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppTheme>(
      stream: themeBloc.themeStream,
      initialData: themeBloc.currentTheme,
      builder: (context, snapshot) {
        final isDark = snapshot.data?.data.brightness == Brightness.dark;
        final backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;

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
            backgroundColor: backgroundColor,
            extendBodyBehindAppBar: true,
            body: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: backgroundColor,
                child: Responsive(
                  mobile: mobileView(context: context, isDark: isDark, textColor: textColor),
                  desktop: desktopView(context: context, isDark: isDark, textColor: textColor),
                  tablet: mobileView(context: context, isDark: isDark, textColor: textColor),
                ),
              ),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(context, isDark),
          ),
        );
      },
    );
  }

  Widget mobileView({required BuildContext context, required bool isDark, required Color textColor}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          _buildHeader(context, textColor: textColor, isDark: isDark),
          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                            // Section 1: "Comunícate con nosotros:"
                            Text(
                              "Comunícate con nosotros:",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Call Center Card
                            _buildContactCard(
                              icon: Icons.phone,
                              iconColor: const Color(0xFF205AA8), // Blue
                              title: "Centro de Atención",
                              subtitle: "55 1040 4127",
                              buttonText: "Llamar",
                              textColor: textColor,
                              isDark: isDark,
                              onButtonTap: () async {
                                final Uri phoneUri =
                                    Uri(scheme: 'tel', path: '5510404127');
                                if (await canLaunchUrl(phoneUri)) {
                                  await launchUrl(phoneUri);
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            // Comments and Suggestions Card
                            _buildContactCard(
                              icon: Icons.email,
                              iconColor: const Color(0xFFA6CE39), // Green
                              title: "Comentarios y sugerencias",
                              subtitle: "admin@mexicodashcam.com",
                              buttonText: "Enviar",
                              textColor: textColor,
                              isDark: isDark,
                              onButtonTap: () {
                                _launchContactEmail();
                              },
                            ),
                            const SizedBox(height: 12),
                            // Website Card
                            _buildContactCard(
                              icon: Icons.language,
                              iconColor: const Color(0xFF205AA8), // Blue
                              title: "Sitio web",
                              subtitle: "www.mexicodashcam.com",
                              buttonText: "Visitar sitio",
                              textColor: textColor,
                              isDark: isDark,
                              onButtonTap: () {
                                _launchContactWebsite();
                              },
                            ),
                            const SizedBox(height: 12),
                            // Sobre esta aplicación
                            _buildContactCard(
                              icon: Icons.info_outline,
                              iconColor: const Color(0xFFA6CE39), // Green
                              title: "Sobre esta aplicación",
                              subtitle:
                                  "Esta aplicación te permite consultar tu saldo y realizar recargas de forma rápida, segura desde cualquier lugar de forma clara y confiable.",
                              textColor: textColor,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 32),
                            // Section 2: "¿Buscas otro tipo de información?"
                            Text(
                              "¿Buscas otro tipo de información?",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Help Center Card
                            _buildContactCard(
                              icon: Icons.settings,
                              iconColor: const Color(0xFF205AA8), // Blue
                              title: "Centro de Ayuda",
                              subtitle: "712 147 2271",
                              buttonText: "Llamar",
                              textColor: textColor,
                              isDark: isDark,
                              onButtonTap: () async {
                                final Uri phoneUri =
                                    Uri(scheme: 'tel', path: '7121472271');
                                if (await canLaunchUrl(phoneUri)) {
                                  await launchUrl(phoneUri);
                                }
                              },
                            ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget desktopView({required BuildContext context, required bool isDark, required Color textColor}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          _buildHeader(context, textColor: textColor, isDark: isDark),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: "Comunícate con nosotros:"
                  Text(
                    "Comunícate con nosotros:",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Call Center Card
                  _buildContactCard(
                    icon: Icons.phone,
                    iconColor: const Color(0xFF205AA8), // Blue
                    title: "Centro de Atención",
                    subtitle: "55 1040 4127",
                    buttonText: "Llamar",
                    textColor: textColor,
                    isDark: isDark,
                    onButtonTap: () async {
                      final Uri phoneUri =
                          Uri(scheme: 'tel', path: '5510404127');
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  // Comments and Suggestions Card
                  _buildContactCard(
                    icon: Icons.email,
                    iconColor: const Color(0xFFA6CE39), // Green
                    title: "Comentarios y sugerencias",
                    subtitle: "admin@mexicodashcam.com",
                    buttonText: "Enviar",
                    textColor: textColor,
                    isDark: isDark,
                    onButtonTap: () {
                      _launchContactEmail();
                    },
                  ),
                  const SizedBox(height: 12),
                  // Website Card
                  _buildContactCard(
                    icon: Icons.language,
                    iconColor: const Color(0xFF205AA8), // Blue
                    title: "Sitio web",
                    subtitle: "www.mexicodashcam.com",
                    buttonText: "Visitar sitio",
                    textColor: textColor,
                    isDark: isDark,
                    onButtonTap: () {
                      _launchContactWebsite();
                    },
                  ),
                  const SizedBox(height: 12),
                  // Sobre esta aplicación
                  _buildContactCard(
                    icon: Icons.info_outline,
                    iconColor: const Color(0xFFA6CE39), // Green
                    title: "Sobre esta aplicación",
                    subtitle:
                        "Esta aplicación está pensada para brindarte herramientas útiles de forma rápida, clara y confiable.",
                    textColor: textColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),
                  // Section 2: "¿Buscas otro tipo de información?"
                  Text(
                    "¿Buscas otro tipo de información?",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Help Center Card
                  _buildContactCard(
                    icon: Icons.settings,
                    iconColor: const Color(0xFF205AA8), // Blue
                    title: "Centro de Ayuda",
                    subtitle: "712 147 2271",
                    buttonText: "Llamar",
                    textColor: textColor,
                    isDark: isDark,
                    onButtonTap: () async {
                      final Uri phoneUri =
                          Uri(scheme: 'tel', path: '7121472271');
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context,
      {Color textColor = Colors.white, bool isDark = true}) {
    final paddingTop = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: paddingTop + 16.0,
        bottom: 16.0,
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () {
              // Intentar hacer pop, si no funciona, navegar al perfil
              final router = GoRouter.of(context);
              if (router.canPop()) {
                router.pop();
              } else {
                // Si no hay página anterior, navegar al perfil
                router.go(RoutesName.perfil);
              }
            },
          ),
          // Title
          Expanded(
            child: Text(
              "Contacto",
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Profile avatar - dinámico
          GestureDetector(
            onTap: () {
              GoRouter.of(context).go(RoutesName.perfil);
            },
            child: StreamBuilder<User?>(
              stream: authBloc.userStream,
              builder: (context, userSnapshot) {
                final user = userSnapshot.data ?? authBloc.currentUser;
                final textColor = isDark ? Colors.white : Colors.black;
                return UserAvatar(
                  imageUrl: user?.fotoPerfil,
                  radius: 20,
                  backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  iconColor: textColor,
                  iconSize: 24,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? buttonText,
    VoidCallback? onButtonTap,
    required Color textColor,
    required bool isDark,
  }) {
    final cardColor = isDark ? Colors.grey[800] : Colors.grey[100];
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final showButton = buttonText != null && onButtonTap != null;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (showButton) ...[
            TextButton(
              onPressed: onButtonTap,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF205AA8), // Blue
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                buttonText!,
                style: TextStyle(
                  color: const Color(0xFF205AA8), // Blue
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isDark) {
    final navBarColor = isDark ? Colors.grey[900] : Colors.grey[100];
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: navBarColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF205AA8), // Blue
          unselectedItemColor: Colors.grey[600],
          currentIndex: 2, // Settings is selected
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          iconSize: 24,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Monedero',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timeline),
              label: 'Actividad',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Configuración',
            ),
          ],
          onTap: (index) {
            if (index == 0) {
              GoRouter.of(context).go(RoutesName.dashboard);
            } else if (index == 1) {
              // Abrir bottomsheet de Monedero
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const MonederoBottomSheet(),
              );
            } else if (index == 2) {
              GoRouter.of(context).go(RoutesName.perfil);
            }
          },
        ),
      ),
    );
  }
}

const String _kContactEmail = 'admin@mexicodashcam.com';
const String _kContactWebsite = 'https://www.mexicodashcam.com';

Future<void> _launchContactEmail() async {
  await _launchExternalUri(Uri.parse('mailto:$_kContactEmail'));
}

Future<void> _launchContactWebsite() async {
  await _launchExternalUri(Uri.parse(_kContactWebsite));
}

Future<void> _launchExternalUri(Uri uri) async {
  final webWindow = kIsWeb ? '_blank' : null;
  bool launched = await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
    webOnlyWindowName: webWindow,
  );
  if (!launched) {
    launched = await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
      webOnlyWindowName: webWindow,
    );
  }
  if (!launched) {
    await launchUrl(uri, webOnlyWindowName: webWindow);
  }
}
