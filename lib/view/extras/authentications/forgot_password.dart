// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:flutter/services.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isEmailEmpty = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    setState(() {
      _isEmailEmpty = _emailController.text.trim().isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppTheme>(
      stream: themeBloc.themeStream,
      initialData: themeBloc.currentTheme,
      builder: (context, snapshot) {
        final isDark = snapshot.data?.data.brightness == Brightness.dark;
        final backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

        const systemUiOverlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        );
        
        final textColor = isDark ? Colors.white : Colors.black;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemUiOverlayStyle,
          child: Scaffold(
            backgroundColor: backgroundColor,
            extendBodyBehindAppBar: true,
            body: Container(
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
        );
      },
    );
  }

  Widget mobileView({required BuildContext context, required bool isDark, required Color textColor}) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo section - Top left
            _buildLogo(isDark: isDark),
            const SizedBox(height: 100.0),

            // Title - Left aligned
            Text(
              "Recuperar contraseña",
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 50.0),

            // Instructions text
            Text(
              "Ingresa tu correo electrónico para recuperar tu contraseña.",
              style: TextStyle(
                color: textColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32.0),

            // Email field
            _buildEmailField(
              isDark: isDark,
              textColor: textColor,
            ),
            const SizedBox(height: 32.0),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isEmailEmpty ? null : () {
                  // Action for confirm
                  GoRouter.of(context).go(RoutesName.login);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF205AA8), // Blue
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: const Color(0xFF205AA8).withOpacity(0.6),
                ),
                child: const Text(
                  "Confirmar",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30.0),

            // Links at the bottom
            _buildBottomLinks(context, textColor: textColor),
            const SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }

  Widget desktopView({required BuildContext context, required bool isDark, required Color textColor}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Center(
      child: Card(
        color: cardColor,
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 1.6,
          height: screenHeight * 0.9,
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo section - Top left
                  _buildLogo(isDark: isDark),
                  const SizedBox(height: 140.0),

                  // Title - Left aligned
                  Text(
                    "Recuperar contraseña",
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 70.0),

                  // Instructions text
                  Text(
                    "Ingresa tu correo electrónico para recuperar tu contraseña.",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  // Email field
                  _buildEmailField(
                    isDark: isDark,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 32.0),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isEmailEmpty ? null : () {
                        // Action for confirm
                        GoRouter.of(context).go(RoutesName.login);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF205AA8), // Blue
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: const Color(0xFF205AA8).withOpacity(0.6),
                      ),
                      child: const Text(
                        "Confirmar",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),

                  // Links at the bottom
                  _buildBottomLinks(context, textColor: textColor),
                  const SizedBox(height: 40.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo({bool isDark = true}) {
    final logoPath = isDark
        ? 'assets/images/logo_dash.png'
        : 'assets/images/logo_dash_blue.png';

    return Image.asset(
      logoPath,
      height: 80,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 60,
          color: Colors.red.withValues(alpha: 0.3),
          child: Center(
            child: Text(
              'Logo Error',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomLinks(BuildContext context, {Color? textColor}) {
    final linkColor = textColor ?? Colors.white;

    return Column(
      children: [
        Center(
          child: TextButton(
            onPressed: () => GoRouter.of(context).go(RoutesName.login),
            child: Text(
              "Inicio de Sesión",
              style: TextStyle(
                color: linkColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Center(
          child: TextButton(
            onPressed: () => GoRouter.of(context).go(RoutesName.register),
            child: Text(
              "¿Necesitas una cuenta? Regístrate.",
              style: TextStyle(
                color: linkColor,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField({
    required bool isDark,
    required Color textColor,
  }) {
    final fieldTextColor = textColor;
    final fieldBgColor = isDark ? Colors.grey[800] : Colors.grey[100];
    final hintTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: fieldTextColor),
      decoration: InputDecoration(
        hintText: "Correo electrónico",
        hintStyle: TextStyle(color: hintTextColor),
        filled: true,
        fillColor: fieldBgColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

}
