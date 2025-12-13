// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:dashboardpro/view/dashboard/datos_fiscales_bottom_sheet.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:dashboardpro/controller/auth_bloc.dart';
import 'package:dashboardpro/model/auth/user.dart';
import 'package:dashboardpro/utils/date_formatter.dart';

class PerfilUsuarioPage extends StatefulWidget {
  const PerfilUsuarioPage({super.key});

  @override
  State<PerfilUsuarioPage> createState() => _PerfilUsuarioPageState();
}

class _PerfilUsuarioPageState extends State<PerfilUsuarioPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

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
            drawer: _buildDrawer(context, isDark),
            body: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: backgroundColor,
                child: Responsive(
                  mobile: mobileView(
                      context: context, isDark: isDark, textColor: textColor),
                  desktop: desktopView(
                      context: context, isDark: isDark, textColor: textColor),
                  tablet: mobileView(
                      context: context, isDark: isDark, textColor: textColor),
                ),
              ),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(context, isDark),
          ),
        );
      },
    );
  }

  Widget mobileView(
      {required BuildContext context,
      required bool isDark,
      required Color textColor}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          _buildHeader(context, textColor: textColor),
          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Profile picture
                StreamBuilder<User?>(
                  stream: authBloc.userStream,
                  builder: (context, userSnapshot) {
                    final user = userSnapshot.data ?? authBloc.currentUser;
                    return _buildProfilePicture(context,
                        isDark: isDark, user: user);
                  },
                ),
                const SizedBox(height: 16),
                // Name
                StreamBuilder<User?>(
                  stream: authBloc.userStream,
                  builder: (context, userSnapshot) {
                    final user = userSnapshot.data ?? authBloc.currentUser;
                    return Text(
                      user != null
                          ? '${user.nombre} ${user.apellidoPaterno}'
                          : 'Usuario',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Member since
                StreamBuilder<User?>(
                  stream: authBloc.userStream,
                  builder: (context, userSnapshot) {
                    final user = userSnapshot.data ?? authBloc.currentUser;
                    return Text(
                      user != null && user.fechaCreacion != null
                          ? DateFormatter.formatDateTime(user.fechaCreacion)
                          : 'N/A',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Información del contacto button
                FilledButton(
                  onPressed: () {
                    GoRouter.of(context).go(RoutesName.informacionUsuario);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF205AA8), // Blue
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Información del usuario",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Menu options
                _buildMenuOption(
                  icon: Icons.credit_card,
                  title: "Métodos de Pago",
                  iconColor: const Color(0xFFA6CE39), // Green
                  textColor: textColor,
                  onTap: () {
                    // Navigate to payment methods
                    GoRouter.of(context).go(RoutesName.metodosPago);
                  },
                ),
                Divider(color: Colors.grey, height: 1),
                _buildMenuOption(
                  icon: Icons.description,
                  title: "Datos fiscales",
                  iconColor: const Color(0xFFFDB462), // Yellow
                  textColor: textColor,
                  onTap: () {
                    // Open datos fiscales bottomsheet
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const DatosFiscalesBottomSheet(),
                    );
                  },
                ),
                Divider(color: Colors.grey, height: 1),
                _buildMenuOption(
                  icon: Icons.lock,
                  title: "Cambiar contraseña",
                  iconColor: const Color(0xFF205AA8), // Blue
                  textColor: textColor,
                  onTap: () {
                    // Navigate to change password page
                    GoRouter.of(context).go(RoutesName.cambioContrasena);
                  },
                ),
                Divider(color: Colors.grey, height: 1),
                _buildMenuOption(
                  icon: Icons.support_agent,
                  title: "Privacidad y Contacto",
                  iconColor: Colors.grey,
                  textColor: textColor,
                  onTap: () {
                    // Navigate to contact page
                    GoRouter.of(context).go(RoutesName.contacto);
                  },
                ),
                Divider(color: Colors.grey, height: 1),
                // Cerrar sesión button
                _buildLogoutButton(
                  textColor: textColor,
                  onTap: () async {
                    // Cerrar sesión usando AuthBloc
                    await authBloc.logout();
                    // Navigate to login page
                    if (context.mounted) {
                      GoRouter.of(context).go(RoutesName.login);
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

  Widget desktopView(
      {required BuildContext context,
      required bool isDark,
      required Color textColor}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          _buildHeader(context, textColor: textColor),
          // Content
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  // Profile picture
                  StreamBuilder<User?>(
                    stream: authBloc.userStream,
                    builder: (context, userSnapshot) {
                      final user = userSnapshot.data ?? authBloc.currentUser;
                      return _buildProfilePicture(context,
                          isDark: isDark, user: user);
                    },
                  ),
                  const SizedBox(height: 16),
                  // Name
                  StreamBuilder<User?>(
                    stream: authBloc.userStream,
                    builder: (context, userSnapshot) {
                      final user = userSnapshot.data ?? authBloc.currentUser;
                      return Text(
                        user != null
                            ? '${user.nombre} ${user.apellidoPaterno}'
                            : 'Usuario',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  // Member since
                  StreamBuilder<User?>(
                    stream: authBloc.userStream,
                    builder: (context, userSnapshot) {
                      final user = userSnapshot.data ?? authBloc.currentUser;
                      return Text(
                        user != null && user.fechaCreacion != null
                            ? DateFormatter.formatDateTime(user.fechaCreacion)
                            : 'N/A',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Información del contacto button
                  FilledButton(
                    onPressed: () {
                      GoRouter.of(context).go(RoutesName.informacionUsuario);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF205AA8), // Blue
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Información del usuario",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Menu options
                  _buildMenuOption(
                    icon: Icons.credit_card,
                    title: "Métodos de Pago",
                    iconColor: const Color(0xFFA6CE39), // Green
                    textColor: textColor,
                    onTap: () {
                      // Navigate to payment methods
                      GoRouter.of(context).go(RoutesName.metodosPago);
                    },
                  ),
                  Divider(color: Colors.grey, height: 1),
                  _buildMenuOption(
                    icon: Icons.description,
                    title: "Datos fiscales",
                    iconColor: const Color(0xFFFDB462), // Yellow
                    textColor: textColor,
                    onTap: () {
                      // Open datos fiscales bottomsheet
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const DatosFiscalesBottomSheet(),
                      );
                    },
                  ),
                  Divider(color: Colors.grey, height: 1),
                  _buildMenuOption(
                    icon: Icons.lock,
                    title: "Cambiar contraseña",
                    iconColor: const Color(0xFF205AA8), // Blue
                    textColor: textColor,
                    onTap: () {
                      // Navigate to change password page
                      GoRouter.of(context).go(RoutesName.cambioContrasena);
                    },
                  ),
                  Divider(color: Colors.grey, height: 1),
                  _buildMenuOption(
                    icon: Icons.support_agent,
                    title: "Privacidad y Contacto",
                    iconColor: Colors.grey,
                    textColor: textColor,
                    onTap: () {
                      // Navigate to contact page
                      GoRouter.of(context).go(RoutesName.contacto);
                    },
                  ),
                  Divider(color: Colors.grey, height: 1),
                  // Cerrar sesión button
                  _buildLogoutButton(
                    textColor: textColor,
                    onTap: () async {
                      // Cerrar sesión usando AuthBloc
                      await authBloc.logout();
                      // Navigate to login page
                      if (context.mounted) {
                        GoRouter.of(context).go(RoutesName.login);
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

  Widget _buildHeader(BuildContext context, {Color textColor = Colors.white}) {
    final paddingTop = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: paddingTop + 13.0,
        bottom: 1.0,
      ),
      child: Row(
        children: [
          // Hamburger menu
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: textColor),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark) {
    final backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? Colors.grey[900] : Colors.grey[100];

    return Drawer(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Profile section
            StreamBuilder<User?>(
              stream: authBloc.userStream,
              builder: (context, userSnapshot) {
                final user = userSnapshot.data ?? authBloc.currentUser;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                  ),
                  child: Column(
                    children: [
                      // Profile image
                      UserAvatar(
                        imageUrl: user?.fotoPerfil,
                        radius: 50,
                        backgroundColor:
                            isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        iconColor: textColor,
                        iconSize: 50,
                      ),
                      const SizedBox(height: 16),
                      // Full name
                      Text(
                        user != null
                            ? '${user.nombre} ${user.apellidoPaterno}'
                            : 'Usuario',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFA6CE39), // Green for active
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Activo",
                            style: TextStyle(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            // Menu options
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading:
                        Icon(Icons.account_balance_wallet, color: textColor),
                    title: Text(
                      "Monedero",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      GoRouter.of(context).go(RoutesName.dashboard);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.directions_bus, color: textColor),
                    title: Text(
                      "Transporte",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      GoRouter.of(context).go(RoutesName.transporte);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.timeline, color: textColor),
                    title: Text(
                      "Actividad",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const MonederoBottomSheet(),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: textColor),
                    title: Text(
                      "Configuración",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      GoRouter.of(context).go(RoutesName.perfil);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.palette, color: textColor),
                    title: Text(
                      "Apariencia",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const AparienciaBottomSheet(),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Cierre de Sesión at the bottom
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF205AA8)),
              title: Text(
                "Cierre de Sesión",
                style: TextStyle(
                  color: const Color(0xFF205AA8),
                  fontSize: 16,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                // Cerrar sesión usando AuthBloc
                await authBloc.logout();
                // Navigate to login page
                if (context.mounted) {
                  GoRouter.of(context).go(RoutesName.login);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture(BuildContext context,
      {bool isDark = true, User? user}) {
    final borderColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB6C1), // Soft pink background
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                  )
                : user?.fotoPerfil != null && user!.fotoPerfil!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: user.fotoPerfil!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        httpHeaders: const {'Accept': 'image/*'},
                        fadeInDuration: const Duration(milliseconds: 200),
                        fadeOutDuration: const Duration(milliseconds: 100),
                        placeholder: (context, url) => Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB6C1), // Soft pink
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          debugPrint('Error loading profile image: $error');
                          debugPrint('Image URL: $url');
                          return Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB6C1), // Soft pink
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          );
                        },
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB6C1), // Soft pink
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
          ),
        ),
        // Edit button
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _showImageSourceDialog(context, isDark),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF205AA8), // Blue
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black;
    final backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            'Seleccionar foto',
            style: TextStyle(color: textColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: const Color(0xFF205AA8)),
                title: Text(
                  'Tomar fotografía',
                  style: TextStyle(color: textColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.photo_library, color: const Color(0xFF205AA8)),
                title: Text(
                  'Elegir de la galería',
                  style: TextStyle(color: textColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
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
            // Title
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            // Arrow icon
            Icon(
              Icons.chevron_right,
              color: Colors.grey[600],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton({
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Title
            const Text(
              "Cerrar sesión",
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            // Arrow icon
            Icon(
              Icons.chevron_right,
              color: Colors.grey[600],
              size: 24,
            ),
          ],
        ),
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
            }
            // index 2 is current page (perfil), no action needed
          },
        ),
      ),
    );
  }
}
