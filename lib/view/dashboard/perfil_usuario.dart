// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:dashboardpro/view/dashboard/datos_fiscales_bottom_sheet.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/services.dart';
// Imports condicionales para File
import 'dart:io' if (dart.library.html) 'package:dashboardpro/services/auth_service_file_stub.dart';
// Imports condicionales para HTML (solo web)
import 'package:dashboardpro/services/html_stub.dart' as html if (dart.library.html) 'dart:html';
import 'package:dashboardpro/services/ui_web_stub.dart' as ui_web if (dart.library.html) 'dart:ui_web';
import 'package:dashboardpro/controller/auth_bloc.dart';
import 'package:dashboardpro/model/auth/user.dart';
import 'package:dashboardpro/utils/date_formatter.dart';
import 'package:quickalert/quickalert.dart';

class PerfilUsuarioPage extends StatefulWidget {
  const PerfilUsuarioPage({super.key});

  @override
  State<PerfilUsuarioPage> createState() => _PerfilUsuarioPageState();
}

class _PerfilUsuarioPageState extends State<PerfilUsuarioPage> {
  // En mobile, File es de dart:io; en web nunca se usa
  dynamic _selectedImage; // Usamos dynamic para evitar conflictos de tipos entre stub y dart:io
  Uint8List? _selectedImageBytes; // Para web
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingPhoto = false;

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
                // Rol
                StreamBuilder<User?>(
                  stream: authBloc.userStream,
                  builder: (context, userSnapshot) {
                    final user = userSnapshot.data ?? authBloc.currentUser;
                    return Text(
                      user != null && user.rol != null
                          ? 'Rol: ${user.rol!.nombre}'
                          : 'Rol: N/A',
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
                StreamBuilder<User?>(
                  stream: authBloc.userStream,
                  builder: (context, userSnapshot) {
                    final user = userSnapshot.data ?? authBloc.currentUser;
                    final isCajero = user?.rol?.nombre.toLowerCase() == 'cajero';

                    return Column(
                      children: [
                        // Ocultar "Métodos de Pago" si el usuario es Cajero
                        if (!isCajero) ...[
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
                        ],
                        // Ocultar "Datos fiscales" si el usuario es Cajero
                        if (!isCajero) ...[
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
                        ],
                      ],
                    );
                  },
                ),
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
                  // Rol
                  StreamBuilder<User?>(
                    stream: authBloc.userStream,
                    builder: (context, userSnapshot) {
                      final user = userSnapshot.data ?? authBloc.currentUser;
                      return Text(
                        user != null && user.rol != null
                            ? 'Rol: ${user.rol!.nombre}'
                            : 'Rol: N/A',
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
                  StreamBuilder<User?>(
                    stream: authBloc.userStream,
                    builder: (context, userSnapshot) {
                      final user = userSnapshot.data ?? authBloc.currentUser;
                      final isCajero = user?.rol?.nombre.toLowerCase() == 'cajero';

                      return Column(
                        children: [
                          // Ocultar "Métodos de Pago" si el usuario es Cajero
                          if (!isCajero) ...[
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
                          ],
                          // Ocultar "Datos fiscales" si el usuario es Cajero
                          if (!isCajero) ...[
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
                          ],
                        ],
                      );
                    },
                  ),
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
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA6CE39).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFA6CE39), width: 1.5),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle,
                                  color: Color(0xFFA6CE39), size: 14),
                              SizedBox(width: 4),
                              Text(
                                "Activo",
                                style: TextStyle(
                                  color: Color(0xFFA6CE39),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Menu options
            Expanded(
              child: StreamBuilder<User?>(
                stream: authBloc.userStream,
                builder: (context, userSnapshot) {
                  final user = userSnapshot.data ?? authBloc.currentUser;
                  final rolNombre = user?.rol?.nombre.toLowerCase() ?? '';
                  final isPasajero = rolNombre == 'pasajero';
                  final isCajero = rolNombre == 'cajero';
                  final isAdministrador = rolNombre == 'administrador';

                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Solo mostrar si NO es Cajero
                      if (!isCajero)
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
                      // Solo mostrar si NO es Cajero
                      if (!isCajero)
                        ListTile(
                          leading: Icon(Icons.directions_bus, color: textColor),
                          title: Text(
                            "Movilidad Inteligente",
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
                      // Mostrar si NO es Pasajero (incluye Cajero y otros roles)
                      if (!isPasajero)
                        ListTile(
                          leading: Icon(Icons.point_of_sale, color: textColor),
                          title: Text(
                            "Punto de Venta",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            GoRouter.of(context).go(RoutesName.pos);
                          },
                        ),
                      // Solo mostrar si es Cajero o Administrador
                      if (isCajero || isAdministrador)
                        ListTile(
                          leading: Icon(Icons.credit_card, color: textColor),
                          title: Text(
                            "Monederos",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            GoRouter.of(context).go(RoutesName.monederos);
                          },
                        ),
                      // Mostrar si NO es Pasajero (incluye Cajero y otros roles)
                      if (!isPasajero)
                        ListTile(
                          leading: Icon(Icons.swap_horiz, color: textColor),
                          title: Text(
                            "Transacciones",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            GoRouter.of(context).go(RoutesName.transacciones);
                          },
                        ),
                      // Solo mostrar si NO es Cajero
                      if (!isCajero)
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
                      // Configuración visible para todos los roles
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
                      // Apariencia visible para todos los roles
                      ListTile(
                        leading: Icon(Icons.contrast, color: textColor),
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
                  );
                },
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


  // Widget helper para cargar imagen desde S3 (URL pública) - funciona en Web, Android e iOS
  Widget _buildNetworkImage(String imageUrl) {
    return ClipOval(
      child: Image.network(
        imageUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading profile image from S3: $error');
          debugPrint('Image URL: $imageUrl');
          return _buildDefaultAvatar();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingAvatar();
        },
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFFFB6C1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: 80,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }

  Widget _buildLoadingAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFFFB6C1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.white.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture(BuildContext context,
      {bool isDark = true, User? user}) {
    final borderColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey[300]!;
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
            child: _selectedImageBytes != null
                ? Image.memory(
                    _selectedImageBytes!,
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                  )
                : user?.fotoPerfil != null && user!.fotoPerfil!.isNotEmpty
                    ? _buildNetworkImage(user.fotoPerfil!)
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
            onTap: _isUploadingPhoto ? null : () => _showImageSourceDialog(context, isDark),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _isUploadingPhoto 
                    ? Colors.grey 
                    : const Color(0xFF205AA8), // Blue
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: 3,
                ),
              ),
              child: _isUploadingPhoto
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
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
        // Leer los bytes directamente del XFile (funciona en web y mobile)
        final imageBytes = await image.readAsBytes();
        
        // En mobile, también crear File desde el path para compatibilidad con el servicio
        dynamic imageFile;
        if (!kIsWeb) {
          imageFile = File(image.path);
        }
        
        // Validar formato del archivo
        // En iOS, el path puede no tener extensión o tener formato diferente,
        // así que validamos primero por mimeType (más confiable)
        bool isValidFormat = false;
        
        // Validar por mimeType (más confiable, especialmente en iOS y web)
        if (image.mimeType != null && image.mimeType!.isNotEmpty) {
          final mimeType = image.mimeType!.toLowerCase();
          isValidFormat = mimeType == 'image/png' ||
              mimeType == 'image/jpeg' ||
              mimeType == 'image/jpg';
        }
        
        // Si no hay mimeType, validar por extensión del path (solo en mobile)
        if (!isValidFormat && !kIsWeb && imageFile != null) {
          final fileName = imageFile.path.toLowerCase();
          isValidFormat = fileName.endsWith('.png') ||
              fileName.endsWith('.jpg') ||
              fileName.endsWith('.jpeg') ||
              fileName.endsWith('.heic'); // iOS puede usar HEIC que se convierte a JPEG/PNG
        }
        
        // Si aún no es válido, confiar en image_picker
        // (image_picker solo permite seleccionar imágenes válidas)
        if (!isValidFormat) {
          // Confiar en image_picker - solo permite imágenes válidas
          isValidFormat = true;
        }
        
        if (!isValidFormat) {
          debugPrint('Formato de imagen no válido. MimeType: ${image.mimeType}');
          if (mounted) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Formato no válido',
              text: 'Solo se permiten archivos PNG, JPG o JPEG.',
              confirmBtnText: 'Aceptar',
              confirmBtnColor: const Color(0xFF205AA8),
            );
          }
          return;
        }

        // Mostrar la imagen seleccionada
        // Usamos bytes en ambos casos para evitar conflictos de tipos
        setState(() {
          _selectedImageBytes = imageBytes;
          if (!kIsWeb) {
            _selectedImage = imageFile; // Guardamos también para el servicio
          }
        });

        // Subir la foto automáticamente
        if (kIsWeb && imageBytes != null) {
          // En web, crear un File temporal desde los bytes para mantener compatibilidad
          // Pero pasaremos los bytes directamente al servicio
          await _uploadProfilePhotoWeb(imageBytes, image.mimeType);
        } else if (!kIsWeb && imageFile != null) {
          await _uploadProfilePhoto(imageFile);
        }
      }
    } catch (e) {
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Error al seleccionar imagen: ${e.toString()}',
          confirmBtnText: 'Aceptar',
          confirmBtnColor: const Color(0xFF205AA8),
        );
      }
    }
  }

  Future<void> _uploadProfilePhoto(File imageFile) async {
    await _uploadProfilePhotoInternal(imageFile: imageFile);
  }
  
  Future<void> _uploadProfilePhotoWeb(Uint8List imageBytes, String? mimeType) async {
    await _uploadProfilePhotoInternal(imageBytes: imageBytes);
  }
  
  Future<void> _uploadProfilePhotoInternal({File? imageFile, Uint8List? imageBytes}) async {
    if (!mounted) return;

    setState(() {
      _isUploadingPhoto = true;
    });

    String? errorMessage;

    try {
      // Escuchar el stream de errores antes de llamar al método
      final errorSubscription = authBloc.errorStream.listen((error) {
        if (error != null && error.isNotEmpty) {
          errorMessage = error;
        }
      });

      final success = kIsWeb && imageBytes != null
          ? await authBloc.uploadProfilePhotoWeb(imageBytes)
          : await authBloc.uploadProfilePhoto(imageFile!);

      // Cancelar la suscripción
      errorSubscription.cancel();

      if (!mounted) return;

      if (success) {
        // Mostrar mensaje de éxito
        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: '¡Éxito!',
            text: 'Foto de perfil actualizada exitosamente',
            confirmBtnText: 'Aceptar',
            confirmBtnColor: const Color(0xFF205AA8),
          );
        }

        // Mantener la imagen seleccionada en la UI para que se vea actualizada
        // La imagen del servidor se actualizará cuando se recargue el usuario
        // No limpiar _selectedImage para mantener la imagen visible en la UI
        
        // Nota: Si el backend retorna la nueva URL en la respuesta, podríamos
        // actualizar el usuario aquí. Por ahora, la imagen se mantendrá visible
        // hasta que el usuario se recargue desde otra fuente.
      } else {
        // Mostrar el mensaje de error capturado del stream
        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Error',
            text: errorMessage ?? 'Error al subir la foto de perfil',
            confirmBtnText: 'Aceptar',
            confirmBtnColor: const Color(0xFF205AA8),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error inesperado',
          text: 'Ocurrió un error inesperado: ${e.toString()}',
          confirmBtnText: 'Aceptar',
          confirmBtnColor: const Color(0xFF205AA8),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
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

