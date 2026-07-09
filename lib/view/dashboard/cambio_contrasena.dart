// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:dashboardpro/utils/password_rules.dart';
import 'package:dashboardpro/widgets/password_security_meter.dart';
import 'package:flutter/services.dart';

class CambioContrasenaPage extends StatefulWidget {
  const CambioContrasenaPage({super.key});

  @override
  State<CambioContrasenaPage> createState() => _CambioContrasenaPageState();
}

class _CambioContrasenaPageState extends State<CambioContrasenaPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;


  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_onNewPasswordChanged);
    _confirmPasswordController.addListener(_onNewPasswordChanged);
  }

  void _onNewPasswordChanged() {
    setState(() {
      // Actualizar para mostrar validación y reglas de contraseña
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordController.removeListener(_onNewPasswordChanged);
    _confirmPasswordController.removeListener(_onNewPasswordChanged);
    super.dispose();
  }

  /// Verifica si la nueva contraseña cumple con todas las reglas
  bool _isNewPasswordValid() =>
      PasswordRules.isValid(_newPasswordController.text);

  bool _isConfirmPasswordValid() =>
      PasswordRules.isValid(_confirmPasswordController.text);

  /// Verifica si ambas contraseñas coinciden
  bool _doPasswordsMatch() {
    return _newPasswordController.text == _confirmPasswordController.text &&
           _newPasswordController.text.isNotEmpty &&
           _confirmPasswordController.text.isNotEmpty;
  }

  Widget _buildField({
    required String label,
    required IconData icon,
    required Widget child,
    required bool isDark,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFA6CE39),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  /// Maneja el cambio de contraseña
  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que las contraseñas nuevas coincidan antes de enviar
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Las contraseñas nuevas no coinciden';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await authBloc.changePassword(
        passwordActual: _currentPasswordController.text,
        passwordNueva: _newPasswordController.text,
        passwordNuevaConfirmacion: _confirmPasswordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response != null && response.success) {
        // Mostrar mensaje de éxito
        setState(() {
          _successMessage = 'Tu contraseña se actualizó correctamente.';
          _errorMessage = null;
        });

        // Limpiar los campos
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        // Redirigir al perfil después de un breve delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              router.go(RoutesName.perfil);
            }
          }
        });
      } else {
        // El error fue manejado por el bloc
        String errorMessage = 'Error al cambiar la contraseña';
        try {
          await authBloc.errorStream.first.timeout(
            const Duration(milliseconds: 500),
            onTimeout: () => null,
          ).then((error) {
            if (error != null && error.isNotEmpty) {
              errorMessage = error;
            }
          });
        } catch (e) {
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instructions
                  Text(
                    "Sigue las indicaciones para realizar el cambio de contraseña.",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Current Password
                  _buildField(
                    label: 'Contraseña Actual',
                    icon: Icons.lock,
                    isDark: isDark,
                    textColor: textColor,
                    child: TextFormField(
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      enabled: !_isLoading,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark
                            ? Colors.grey[800]
                            : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "************",
                        hintStyle: TextStyle(
                            color: isDark
                                ? Colors.grey[500]
                                : Colors.grey[600]),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrentPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureCurrentPassword =
                                  !_obscureCurrentPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu contraseña actual';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // New Password
                  _buildField(
                    label: 'Contraseña Nueva',
                    icon: Icons.lock_open,
                    isDark: isDark,
                    textColor: textColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: _obscureNewPassword,
                          enabled: !_isLoading,
                          style: TextStyle(color: textColor),
                          onChanged: (value) {
                            setState(() {}); // Actualizar para mostrar validación y reglas
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark
                                ? Colors.grey[800]
                                : Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "••••••••••••",
                            hintStyle: TextStyle(
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600]),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword =
                                      !_obscureNewPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) => PasswordRules.validate(
                            value,
                            emptyMessage:
                                'Por favor ingresa una nueva contraseña',
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_newPasswordController.text.isNotEmpty)
                          PasswordSecurityMeter(
                            password: _newPasswordController.text,
                            isDark: isDark,
                            textColor: textColor,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Confirm Password
                  _buildField(
                    label: 'Confirmar Contraseña',
                    icon: Icons.verified,
                    isDark: isDark,
                    textColor: textColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          enabled: !_isLoading,
                          style: TextStyle(color: textColor),
                          onChanged: (value) {
                            setState(() {}); // Actualizar para habilitar/deshabilitar botón
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark
                                ? Colors.grey[800]
                                : Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "************",
                            hintStyle: TextStyle(
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600]),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) => PasswordRules.validateConfirmation(
                            value,
                            _newPasswordController.text,
                            emptyMessage: 'Por favor confirma tu contraseña',
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Mensaje de confirmación válida
                        if (_isConfirmPasswordValid() && _doPasswordsMatch())
                          Text(
                            "Las contraseñas coinciden",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else if (_confirmPasswordController.text.isNotEmpty && !_doPasswordsMatch())
                          Text(
                            "Las contraseñas no coinciden",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
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

                  // Change Password Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: (_isNewPasswordValid() && 
                                 _newPasswordController.text == _confirmPasswordController.text &&
                                 !_isLoading)
                          ? _handleChangePassword
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF205AA8), // Blue
                        disabledBackgroundColor: const Color(0xFF205AA8).withOpacity(0.6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                          : Text(
                              "Cambiar Contraseña",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instructions
                    Text(
                      "Sigue las indicaciones para realizar el cambio de contraseña.",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Current Password
                    _buildField(
                      label: 'Contraseña Actual',
                      icon: Icons.lock,
                      isDark: isDark,
                      textColor: textColor,
                      child: TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        enabled: !_isLoading,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          hintText: "************",
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrentPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureCurrentPassword = !_obscureCurrentPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu contraseña actual';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // New Password
                    _buildField(
                      label: 'Nueva Contraseña',
                      icon: Icons.lock_open,
                      isDark: isDark,
                      textColor: textColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: _obscureNewPassword,
                            enabled: !_isLoading,
                            style: TextStyle(color: textColor),
                            onChanged: (value) {
                              setState(() {}); // Actualizar para mostrar validación y reglas
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "••••••••••••",
                              hintStyle: TextStyle(
                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNewPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureNewPassword = !_obscureNewPassword;
                                  });
                                },
                              ),
                            ),
                          validator: (value) => PasswordRules.validate(
                            value,
                            emptyMessage:
                                'Por favor ingresa una nueva contraseña',
                          ),
                          ),
                          const SizedBox(height: 8),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      enabled: !_isLoading,
                      style: TextStyle(color: textColor),
                      onChanged: (value) {
                        setState(() {}); // Actualizar para mostrar validación y reglas
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.red, width: 1.0),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white, width: 1.0),
                        ),
                        hintText: "••••••••••••",
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                          validator: (value) => PasswordRules.validate(
                            value,
                            emptyMessage:
                                'Por favor ingresa una nueva contraseña',
                          ),
                    ),
                          const SizedBox(height: 12),
                          if (_newPasswordController.text.isNotEmpty)
                            PasswordSecurityMeter(
                              password: _newPasswordController.text,
                              isDark: isDark,
                              textColor: textColor,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Confirm Password
                    _buildField(
                      label: 'Confirmar Nueva Contraseña',
                      icon: Icons.verified,
                      isDark: isDark,
                      textColor: textColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            enabled: !_isLoading,
                            style: TextStyle(color: textColor),
                            onChanged: (value) {
                              setState(() {}); // Actualizar para habilitar/deshabilitar botón
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "************",
                              hintStyle: TextStyle(
                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) =>
                                PasswordRules.validateConfirmation(
                              value,
                              _newPasswordController.text,
                              emptyMessage:
                                  'Por favor confirma tu nueva contraseña',
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Mensaje de confirmación válida
                          if (_isConfirmPasswordValid() && _doPasswordsMatch())
                            Text(
                              "Las contraseñas coinciden",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          else if (_confirmPasswordController.text.isNotEmpty && !_doPasswordsMatch())
                            Text(
                              "Las contraseñas no coinciden",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
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

                    // Change Password Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: (_isNewPasswordValid() && 
                                   _newPasswordController.text == _confirmPasswordController.text &&
                                   !_isLoading)
                            ? _handleChangePassword
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF205AA8), // Blue
                          disabledBackgroundColor: const Color(0xFF205AA8).withOpacity(0.6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                            : Text(
                                "Cambiar Contraseña",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
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
              "Cambio de contraseña",
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
