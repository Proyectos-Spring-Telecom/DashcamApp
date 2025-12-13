// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:flutter/services.dart';
import 'package:dashboardpro/controller/auth_bloc.dart';
import 'package:dashboardpro/model/auth/user.dart';
import 'package:dashboardpro/utils/date_formatter.dart';
import 'package:intl/intl.dart';

class InformacionUsuarioPage extends StatelessWidget {
  const InformacionUsuarioPage({super.key});

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
          _buildHeader(context, textColor: textColor),
          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: StreamBuilder<User?>(
              stream: authBloc.userStream,
              builder: (context, userSnapshot) {
                final user = userSnapshot.data ?? authBloc.currentUser;
                return Column(
                  children: [
                    // User name and profile picture
                    _buildUserHeader(context, user: user, isDark: isDark, textColor: textColor),
                    const SizedBox(height: 24),
                    // Information cards
                    _buildInfoCards(user: user, isDark: isDark, textColor: textColor),
                  ],
                );
              },
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
          _buildHeader(context, textColor: textColor),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: StreamBuilder<User?>(
                stream: authBloc.userStream,
                builder: (context, userSnapshot) {
                  final user = userSnapshot.data ?? authBloc.currentUser;
                  return Column(
                    children: [
                      // User name and profile picture
                      _buildUserHeader(context, user: user, isDark: isDark, textColor: textColor),
                      const SizedBox(height: 24),
                      // Information cards
                      _buildInfoCards(user: user, isDark: isDark, textColor: textColor),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {Color textColor = Colors.white}) {
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
              final router = GoRouter.of(context);
              if (router.canPop()) {
                router.pop();
              } else {
                router.go(RoutesName.perfil);
              }
            },
          ),
          // Title
          Expanded(
            child: Text(
              "Información",
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Spacer to center the title
          SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, {User? user, required bool isDark, required Color textColor}) {
    final cardColor = isDark ? Colors.grey[800] : Colors.grey[100];
    
    return Column(
      children: [
        // Name and profile picture row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Name
            Expanded(
              child: Text(
                user != null
                    ? '${user.nombre} ${user.apellidoPaterno} ${user.apellidoMaterno}'.trim()
                    : 'Usuario',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Profile picture
            UserAvatar(
              imageUrl: user?.fotoPerfil,
              radius: 30,
              backgroundColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              iconColor: textColor,
              iconSize: 30,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Tags row
        Row(
          children: [
            // Pasajero tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFDB462), // Mustard yellow
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user?.rol?.nombre ?? 'Pasajero',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Activo tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF8FB82E), // Dark green
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Activo",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCards({User? user, required bool isDark, required Color textColor}) {
    final cardColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;
    
    return Column(
      children: [
        // Member Since card
        _buildInfoCardWithCustomIcon(
          customIcon: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.calendar_today, color: Colors.white, size: 24),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF205AA8),
                    size: 8,
                  ),
                ),
              ),
            ],
          ),
          iconColor: const Color(0xFF205AA8), // Blue
          label: "Miembro desde:",
          value: user?.fechaCreacion != null
              ? _formatDateTime24h(user!.fechaCreacion)
              : 'N/A',
          cardColor: cardColor,
          textColor: textColor,
        ),
        const SizedBox(height: 16),
        // Email card
        _buildInfoCard(
          icon: Icons.email,
          iconColor: const Color(0xFFA6CE39), // Lime green
          label: "Correo electrónico:",
          value: user?.userName ?? 'N/A',
          cardColor: cardColor,
          textColor: textColor,
        ),
        const SizedBox(height: 16),
        // Phone card
        _buildInfoCard(
          icon: Icons.phone,
          iconColor: const Color(0xFF205AA8), // Blue
          label: "Teléfono:",
          value: user?.telefono ?? 'N/A',
          cardColor: cardColor,
          textColor: textColor,
        ),
        const SizedBox(height: 16),
        // Role card
        _buildInfoCard(
          icon: Icons.star,
          iconColor: const Color(0xFFA6CE39), // Lime green
          label: "Rol:",
          value: user?.rol?.nombre ?? 'N/A',
          cardColor: cardColor,
          textColor: textColor,
        ),
        const SizedBox(height: 16),
        // Security card
        _buildInfoCard(
          icon: Icons.shield,
          iconColor: const Color(0xFF205AA8), // Blue
          label: "Seguridad:",
          value: "Alta",
          cardColor: cardColor,
          textColor: textColor,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
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
          // Label and value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCardWithCustomIcon({
    required Widget customIcon,
    required Color iconColor,
    required String label,
    required String value,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon circle with custom icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: customIcon,
          ),
          const SizedBox(width: 16),
          // Label and value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
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
              icon: Icon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '',
            ),
          ],
          onTap: (index) {
            if (index == 0) {
              GoRouter.of(context).go(RoutesName.dashboard);
            } else if (index == 1) {
              // Search action (if needed)
            } else if (index == 2) {
              GoRouter.of(context).go(RoutesName.perfil);
            }
          },
        ),
      ),
    );
  }

  /// Formatea una fecha con hora en formato 24 horas "dd/MM/yyyy HH:mm:ss"
  String _formatDateTime24h(String? fechaCreacion) {
    if (fechaCreacion == null || fechaCreacion.isEmpty) {
      return 'N/A';
    }

    try {
      // Limpiar la cadena eliminando referencias a zonas horarias
      String fechaLimpia = fechaCreacion
          .replaceAll(RegExp(r'GMT[+-]\d{4}'), '')
          .replaceAll(RegExp(r'\(GMT[+-]\d{2}:\d{2}\)'), '')
          .replaceAll(RegExp(r'GMT[+-]\d{2}:\d{2}'), '')
          .replaceAll(RegExp(r'UTC[+-]\d{2}:\d{2}'), '')
          .replaceAll(RegExp(r'Z$'), '')
          .trim();
      
      DateTime? fecha;
      
      // Primero intentar parseo ISO directo
      fecha = DateTime.tryParse(fechaLimpia);
      
      // Si no funciona, intentar diferentes formatos comunes
      if (fecha == null) {
        final formatos = [
          'yyyy-MM-ddTHH:mm:ss',
          'yyyy-MM-ddTHH:mm:ss.SSS',
          'yyyy-MM-dd HH:mm:ss',
          'yyyy-MM-dd',
          'dd/MM/yyyy HH:mm:ss',
          'dd/MM/yyyy',
          'MM/dd/yyyy',
        ];

        for (final formato in formatos) {
          try {
            fecha = DateFormat(formato).parse(fechaLimpia);
            break;
          } catch (e) {
            continue;
          }
        }
      }

      if (fecha != null) {
        // Formatear con fecha y hora en formato 24 horas
        return DateFormat('dd/MM/yyyy HH:mm:ss').format(fecha);
      }

      return fechaLimpia;
    } catch (e) {
      return fechaCreacion
          .replaceAll(RegExp(r'GMT[+-]\d{4}'), '')
          .replaceAll(RegExp(r'\(GMT[+-]\d{2}:\d{2}\)'), '')
          .replaceAll(RegExp(r'GMT[+-]\d{2}:\d{2}'), '')
          .trim();
    }
  }
}

