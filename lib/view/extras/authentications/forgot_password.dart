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
  final _formKey = GlobalKey<FormState>();
  bool _isEmailEmpty = true;
  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

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

  /// Valida el formato del email
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa tu correo electrónico';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Por favor ingresa un correo electrónico válido';
    }
    return null;
  }

  /// Maneja el envío del formulario de recuperación
  Future<void> _handleRecoverPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await authBloc.recoverPassword(userName: email);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response != null && response.success) {
        // Mostrar mensaje de éxito en la UI
        setState(() {
          _successMessage = 'Hemos enviado instrucciones para restablecer tu contraseña a tu correo electrónico.';
          _errorMessage = null;
        });

        // Redirigir al login después de un delay para que el usuario pueda leer el mensaje
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            GoRouter.of(context).go(RoutesName.login);
          }
        });
      } else {
        // El error fue manejado por el bloc y agregado al errorStream
        // Escuchar el stream para obtener el mensaje de error
        String errorMessage = 'Error al recuperar contraseña';
        try {
          // Intentar obtener el último error del stream
          await authBloc.errorStream.first.timeout(
            const Duration(milliseconds: 500),
            onTimeout: () => null,
          ).then((error) {
            if (error != null && error.isNotEmpty) {
              errorMessage = error;
            }
          });
        } catch (e) {
          // Si hay un error al obtener el mensaje, usar el mensaje por defecto
          debugPrint('Error al obtener mensaje del stream: $e');
        }

        if (mounted) {
          setState(() {
            _errorMessage = errorMessage;
            _successMessage = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error inesperado: ${e.toString()}';
          _successMessage = null;
        });
      }
    }
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

            // Mensajes de error/éxito
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_successMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Email field
            Form(
              key: _formKey,
              child: _buildEmailField(
                isDark: isDark,
                textColor: textColor,
              ),
            ),
            const SizedBox(height: 32.0),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (_isEmailEmpty || _isLoading) ? null : _handleRecoverPassword,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF205AA8), // Blue
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: const Color(0xFF205AA8).withOpacity(0.6),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
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

                  // Mensajes de error/éxito
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_successMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Email field
                  Form(
                    key: _formKey,
                    child: _buildEmailField(
                      isDark: isDark,
                      textColor: textColor,
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: (_isEmailEmpty || _isLoading) ? null : _handleRecoverPassword,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF205AA8), // Blue
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: const Color(0xFF205AA8).withOpacity(0.6),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
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
    final errorTextColor = Colors.red[400];
    
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      enabled: !_isLoading,
      validator: _validateEmail,
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
          borderSide: BorderSide(color: errorTextColor ?? Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorTextColor ?? Colors.red, width: 2.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.0),
        ),
        errorStyle: TextStyle(color: errorTextColor),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

}
