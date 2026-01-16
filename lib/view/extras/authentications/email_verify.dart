// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:flutter/services.dart';
import 'package:dashboardpro/controller/auth_bloc.dart';
import 'package:dashboardpro/model/auth/user.dart';
import 'dart:async';

class EmailVerificationWaitingScreen extends StatefulWidget {
  final String? userName;
  final String? userEmail;

  const EmailVerificationWaitingScreen({
    super.key,
    this.userName,
    this.userEmail,
  });

  @override
  State<EmailVerificationWaitingScreen> createState() =>
      _EmailVerificationWaitingScreenState();

  // Clave única para evitar conflictos en el Navigator
  static const Key uniqueKey = ValueKey('email_verification_screen');
}

class _EmailVerificationWaitingScreenState
    extends State<EmailVerificationWaitingScreen> {
  final List<TextEditingController> _codeControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isExpired = false;
  
  // Variables para reenvío de código
  bool _isResendingCode = false;
  int _resendCountdown = 0;
  Timer? _resendTimer;
  String? _resendSuccessMessage;
  String? _resendErrorMessage;

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _onCodeChanged(int index, String value) {
    setState(() {
      // Actualizar el estado para que el botón se habilite/deshabilite
    });

    if (value.length == 1) {
      // Mover al siguiente campo si hay uno
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Si es el último campo, quitar el foco
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      // Si se borra, volver al campo anterior
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _getVerificationCode() {
    return _codeControllers.map((controller) => controller.text).join();
  }

  bool _isCodeComplete() {
    return _codeControllers.every((controller) => controller.text.isNotEmpty);
  }

  /// Obtiene el email del usuario desde diferentes fuentes
  String? _getUserEmail() {
    // 1. Intentar obtener del parámetro pasado desde el registro (prioridad más alta)
    if (widget.userEmail != null && widget.userEmail!.isNotEmpty) {
      // Decodificar el email en caso de que venga codificado desde la URL
      try {
        final decodedEmail = Uri.decodeComponent(widget.userEmail!);
        debugPrint('📧 Email obtenido del parámetro: $decodedEmail');
        return decodedEmail;
      } catch (e) {
        debugPrint('⚠️ Error al decodificar email: $e');
        return widget.userEmail;
      }
    }

    // 2. Intentar obtener del usuario logueado (userName puede ser el email)
    final user = authBloc.currentUser;
    if (user?.userName != null && user!.userName.isNotEmpty) {
      debugPrint('📧 Email obtenido del usuario logueado: ${user.userName}');
      return user.userName;
    }

    // 3. Si no hay email disponible, retornar null
    debugPrint('❌ No se pudo obtener el email del usuario');
    return null;
  }

  /// Valida el formato del email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Verifica si el userName está disponible (no es "Usuario")
  bool _hasUserName() {
    // Verificar si tenemos userName del widget
    if (widget.userName != null && widget.userName!.isNotEmpty) {
      return true;
    }
    // Verificar si tenemos userEmail del widget (el email también cuenta como userName)
    if (widget.userEmail != null && widget.userEmail!.isNotEmpty) {
      return true;
    }
    // Verificar si tenemos usuario logueado con nombre
    final user = authBloc.currentUser;
    if (user != null && user.nombre.isNotEmpty) {
      return true;
    }
    return false;
  }

  /// Maneja la verificación del código
  Future<void> _handleVerification() async {
    if (!_isCodeComplete()) {
      return;
    }

    final code = _getVerificationCode();
    if (code.length != 4) {
      setState(() {
        _errorMessage = 'Por favor ingresa el código completo de 4 dígitos';
        _successMessage = null;
        _isExpired = false;
      });
      return;
    }

    // Obtener el email del usuario
    final email = _getUserEmail();
    if (email == null || email.isEmpty) {
      setState(() {
        _errorMessage =
            'No se pudo obtener el correo electrónico. Por favor, inicia sesión nuevamente.';
        _successMessage = null;
        _isExpired = false;
      });
      return;
    }

    // Validar formato del email
    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = 'El formato del correo electrónico no es válido';
        _successMessage = null;
        _isExpired = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      _isExpired = false;
    });

    debugPrint('📤 Enviando verificación con:');
    debugPrint('   - Email: $email');
    debugPrint('   - Código: $code');

    try {
      final verifyResponse = await authBloc.verifyEmail(
        userName: email,
        code: code,
      );

      debugPrint('📥 Respuesta de verificación: $verifyResponse');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (verifyResponse != null) {
        if (verifyResponse.success) {
          // Mostrar el mensaje del servicio si está disponible, de lo contrario usar mensaje por defecto
          final messageToShow = verifyResponse.message.isNotEmpty
              ? verifyResponse.message
              : 'Código verificado exitosamente';
          
          setState(() {
            _successMessage = messageToShow;
            _errorMessage = null;
            _isExpired = false;
          });

          // Redirigir al login después de un delay más largo para que el usuario pueda leer el mensaje
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              GoRouter.of(context).go(RoutesName.login);
            }
          });
        } else {
          setState(() {
            _errorMessage = verifyResponse.message;
            _isExpired = verifyResponse.isExpired;
            _successMessage = null;
          });
        }
      } else {
        // El error ya fue manejado por el AuthBloc
        final errorFromBloc = authBloc.authStatus == AuthStatus.error
            ? 'Error al verificar el código'
            : null;
        setState(() {
          _errorMessage = errorFromBloc;
          _successMessage = null;
          _isExpired = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error inesperado: ${e.toString()}';
        _successMessage = null;
        _isExpired = false;
      });
    }
  }

  /// Maneja el reenvío del código de verificación
  Future<void> _handleResendCode() async {
    // Obtener el email del usuario
    final email = _getUserEmail();
    if (email == null || email.isEmpty) {
      setState(() {
        _resendErrorMessage =
            'No se pudo obtener el correo electrónico. Por favor, inicia sesión nuevamente.';
        _resendSuccessMessage = null;
      });
      return;
    }

    // Validar formato del email
    if (!_isValidEmail(email)) {
      setState(() {
        _resendErrorMessage = 'El formato del correo electrónico no es válido';
        _resendSuccessMessage = null;
      });
      return;
    }

    setState(() {
      _isResendingCode = true;
      _resendErrorMessage = null;
      _resendSuccessMessage = null;
    });

    debugPrint('📤 Reenviando código a: $email');

    try {
      final resendResponse = await authBloc.resendCode(userName: email);

      if (!mounted) return;

      setState(() {
        _isResendingCode = false;
      });

      if (resendResponse != null && resendResponse.success) {
        // Mostrar mensaje de éxito
        setState(() {
          _resendSuccessMessage = 'Hemos reenviado el código de verificación a tu correo electrónico.';
          _resendErrorMessage = null;
        });

        // Iniciar countdown de 1 minuto (60 segundos)
        _startResendCountdown();
      } else {
        // El error fue manejado por el bloc
        String errorMessage = 'Error al reenviar el código';
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
          debugPrint('Error al obtener mensaje del stream: $e');
        }

        if (mounted) {
          setState(() {
            _resendErrorMessage = errorMessage;
            _resendSuccessMessage = null;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isResendingCode = false;
        _resendErrorMessage = 'Error inesperado: ${e.toString()}';
        _resendSuccessMessage = null;
      });
    }
  }

  /// Inicia el countdown de 1 minuto para el reenvío de código
  void _startResendCountdown() {
    _resendTimer?.cancel();
    _resendCountdown = 60; // 1 minuto = 60 segundos

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _resendCountdown = 0;
          timer.cancel();
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // Log para debug al inicializar el widget
    debugPrint('🔍 EmailVerificationWaitingScreen inicializado');
    debugPrint('   - userName: ${widget.userName}');
    debugPrint('   - userEmail (raw): ${widget.userEmail}');
    if (widget.userEmail != null) {
      try {
        final decoded = Uri.decodeComponent(widget.userEmail!);
        debugPrint('   - userEmail (decoded): $decoded');
      } catch (e) {
        debugPrint('   - Error al decodificar: $e');
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

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemUiOverlayStyle,
          child: Scaffold(
            backgroundColor: backgroundColor,
            extendBodyBehindAppBar: true,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              color: backgroundColor,
              child: SafeArea(
                top: false,
                bottom: false,
                child: Responsive(
                  mobile: mobileView(context: context, isDark: isDark),
                  desktop: desktopView(context: context, isDark: isDark),
                  tablet: mobileView(context: context, isDark: isDark),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget mobileView({required BuildContext context, required bool isDark}) {
    final textColor = isDark ? Colors.white : Colors.black;
    final lightTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo section - Top left
            _buildLogo(isDark: isDark),
            const SizedBox(height: 80.0),
            // Title - Left aligned, positioned lower
            Text(
              "Verificación de Cuenta",
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(
                height: 40.0), // Increased spacing to position title lower

            // Greeting and instructions - Centered
            Center(
              child: StreamBuilder<User?>(
                stream: authBloc.userStream,
                builder: (context, userSnapshot) {
                  final user = userSnapshot.data ?? authBloc.currentUser;
                  // Priorizar el nombre pasado como parámetro, luego el del usuario logueado, luego el email, y finalmente "Usuario"
                  String displayName;
                  if (widget.userName != null && widget.userName!.isNotEmpty) {
                    displayName = widget.userName!;
                  } else if (user != null && user.nombre.isNotEmpty) {
                    displayName = '${user.nombre} ${user.apellidoPaterno}';
                  } else if (widget.userEmail != null && widget.userEmail!.isNotEmpty) {
                    // Si tenemos email pero no nombre, usar el email como displayName
                    try {
                      displayName = Uri.decodeComponent(widget.userEmail!);
                    } catch (e) {
                      displayName = widget.userEmail!;
                    }
                  } else {
                    displayName = 'Usuario';
                  }

                  return RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16.0,
                        color: lightTextColor,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'Hola, '),
                        TextSpan(
                          text: displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' — nos alegra que estés aquí. Para terminar el registro, ingresa el código de 4 dígitos que te enviamos a tu correo.',
                          style: TextStyle(
                            color: lightTextColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40.0),

            // Mensajes de error/éxito
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: _isExpired
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isExpired ? Colors.orange : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isExpired
                          ? Icons.warning_amber_rounded
                          : Icons.error_outline,
                      color: _isExpired ? Colors.orange : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: _isExpired ? Colors.orange : Colors.red,
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
            // Mensajes de error/éxito para reenvío de código
            if (_resendErrorMessage != null) ...[
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
                        _resendErrorMessage!,
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
            if (_resendSuccessMessage != null) ...[
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
                        _resendSuccessMessage!,
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

            // Mensaje informativo si no hay userName
            if (!_hasUserName()) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Por favor, haz clic en "Reenviar código" para reenviar tu código de verificación.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Code input fields - Centered
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final hasUserName = _hasUserName();
                return Container(
                  width: 60.0,
                  height: 60.0,
                  margin: EdgeInsets.only(
                    right: index < 3 ? 12.0 : 0,
                  ),
                  child: TextField(
                    controller: _codeControllers[index],
                    focusNode: _focusNodes[index],
                    enabled: hasUserName && !_isLoading,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: hasUserName ? textColor : Colors.grey,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) => _onCodeChanged(index, value),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1.0,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey[400]!,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF205AA8),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 40.0),

            // Verify button and Resend link
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verify button
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFA6CE39), // Light green
                          Color(0xFF8FB82E), // Darker green
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FilledButton(
                      onPressed: (_isCodeComplete() && !_isLoading && _hasUserName())
                          ? _handleVerification
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.transparent,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              "Verificar",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: (_isCodeComplete() && !_isLoading)
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.6),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // Resend code link
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Abrir modal de reenvío de código
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.all(24.0),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 500),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const ResendCodeModal(),
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Reenviar código",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF205AA8),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40.0),

            // Troubleshooting message
            Text(
              "¿No recibiste el correo? Revisa tu carpeta de spam o solicita reenviar.",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 14.0,
                color: lightTextColor,
              ),
            ),
            const SizedBox(height: 40.0),

            // Bottom links
            _buildBottomLinks(context, textColor: textColor),
            const SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }

  Widget desktopView({required BuildContext context, required bool isDark}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final textColor = isDark ? Colors.white : Colors.black;
    final lightTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Center(
      child: Card(
        color: cardColor,
        child: Container(
          width: MediaQuery.of(context).size.width / 1.6,
          height: screenHeight * 0.9,
          padding: const EdgeInsets.all(48.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo section - Top left
                _buildLogo(isDark: isDark),
                const SizedBox(height: 120.0),
                // Title - Left aligned, positioned lower
                Text(
                  "Verificación de Cuenta",
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(
                    height: 60.0), // Increased spacing to position title lower

                // Greeting and instructions - Centered
                Center(
                  child: StreamBuilder<User?>(
                    stream: authBloc.userStream,
                    builder: (context, userSnapshot) {
                      final user = userSnapshot.data ?? authBloc.currentUser;
                      // Priorizar el nombre pasado como parámetro, luego el del usuario logueado, luego el email, y finalmente "Usuario"
                      String displayName;
                      if (widget.userName != null &&
                          widget.userName!.isNotEmpty) {
                        displayName = widget.userName!;
                      } else if (user != null && user.nombre.isNotEmpty) {
                        displayName = '${user.nombre} ${user.apellidoPaterno}';
                      } else if (widget.userEmail != null && widget.userEmail!.isNotEmpty) {
                        // Si tenemos email pero no nombre, usar el email como displayName
                        try {
                          displayName = Uri.decodeComponent(widget.userEmail!);
                        } catch (e) {
                          displayName = widget.userEmail!;
                        }
                      } else {
                        displayName = 'Usuario';
                      }

                      return RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 16.0,
                            color: lightTextColor,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(text: 'Hola, '),
                            TextSpan(
                              text: displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' — nos alegra que estés aquí. Para terminar el registro, ingresa el código de 4 dígitos que te enviamos a tu correo.',
                              style: TextStyle(
                                color: lightTextColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40.0),

                // Mensajes de error/éxito
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: _isExpired
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isExpired ? Colors.orange : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isExpired
                              ? Icons.warning_amber_rounded
                              : Icons.error_outline,
                          color: _isExpired ? Colors.orange : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: _isExpired ? Colors.orange : Colors.red,
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
                // Mensajes de error/éxito para reenvío de código
                if (_resendErrorMessage != null) ...[
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
                            _resendErrorMessage!,
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
                if (_resendSuccessMessage != null) ...[
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
                            _resendSuccessMessage!,
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

                // Mensaje informativo si no hay userName
                if (!_hasUserName()) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Por favor, haz clic en "Reenviar código" para reenviar tu código de verificación.',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Code input fields - Centered
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final hasUserName = _hasUserName();
                    return Container(
                      width: 70.0,
                      height: 70.0,
                      margin: EdgeInsets.only(
                        right: index < 3 ? 16.0 : 0,
                      ),
                      child: TextField(
                        controller: _codeControllers[index],
                        focusNode: _focusNodes[index],
                        enabled: hasUserName && !_isLoading,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: hasUserName ? textColor : Colors.grey,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _onCodeChanged(index, value),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: isDark ? Colors.grey[800] : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.0,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey[400]!,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF205AA8),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40.0),

                // Verify button and Resend link
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Verify button
                    SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFA6CE39), // Light green
                              Color(0xFF8FB82E), // Darker green
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: FilledButton(
                          onPressed: (_isCodeComplete() && !_isLoading && _hasUserName())
                              ? _handleVerification
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Colors.transparent,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  "Verificar",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: (_isCodeComplete() && !_isLoading)
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.6),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    // Resend code link
                    TextButton(
                      onPressed: () {
                        // Abrir modal de reenvío de código
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(24.0),
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 500),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const ResendCodeModal(),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Reenviar código",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF205AA8),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40.0),

                // Troubleshooting message
                Text(
                  "¿No recibiste el correo? Revisa tu carpeta de spam o solicita reenviar.",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: lightTextColor,
                  ),
                ),
                const SizedBox(height: 40.0),

                // Bottom links
                _buildBottomLinks(context, textColor: textColor),
                const SizedBox(height: 10.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomLinks(BuildContext context, {Color? textColor}) {
    final linkColor = textColor ?? Colors.white;

    return Column(
      children: [
        Center(
          child: TextButton(
            onPressed: () {
              if (context.mounted) {
                GoRouter.of(context).go(RoutesName.forgotPassword);
              }
            },
            child: Text(
              "¿Olvidaste tu Contraseña?",
              style: TextStyle(
                color: linkColor,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 1),
        Center(
          child: TextButton(
            onPressed: () {
              if (context.mounted) {
                GoRouter.of(context).go(RoutesName.login);
              }
            },
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
      ],
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
}
