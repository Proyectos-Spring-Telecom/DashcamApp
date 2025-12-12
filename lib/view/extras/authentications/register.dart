// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:flutter/services.dart';
import 'package:dashboardpro/controller/auth_bloc.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _monederoController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _fechaNacimientoController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _monederoController.dispose();
    super.dispose();
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
                  mobile: mobileWidget(context: context, isDark: isDark),
                  desktop: desktopWidget(context: context, isDark: isDark),
                  tablet: mobileWidget(context: context, isDark: isDark),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget mobileWidget({required BuildContext context, bool isDark = true}) {
    final textColor = isDark ? Colors.white : Colors.black;
    
    return StreamBuilder<String?>(
      stream: authBloc.errorStream,
      builder: (context, errorSnapshot) {
        // Actualizar el mensaje de error si viene del stream
        final error = errorSnapshot.data ?? _errorMessage;
        if (error != null && error != _errorMessage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _errorMessage = error;
              });
            }
          });
        }
        
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // Logo section - Top
            _buildLogo(isDark: isDark),
            const SizedBox(height: 32.0),

            // Title
            Text(
              "Registro",
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 40.0),

            // Nombre
            _buildTextField(
              label: "Nombre",
              controller: _nombreController,
              isDark: isDark,
              textColor: textColor,
              placeholder: "Nombre",
            ),
            const SizedBox(height: 20.0),

            // Apellido Paterno
            _buildTextField(
              label: "Apellido Paterno",
              controller: _apellidoPaternoController,
              isDark: isDark,
              textColor: textColor,
              placeholder: "Apellido Paterno",
            ),
            const SizedBox(height: 20.0),

            // Apellido Materno
            _buildTextField(
              label: "Apellido Materno",
              controller: _apellidoMaternoController,
              isDark: isDark,
              textColor: textColor,
              placeholder: "Apellido Materno",
              isRequired: false,
            ),
            const SizedBox(height: 20.0),

            // Fecha Nacimiento
            _buildDateField(
              label: "Fecha Nacimiento",
              controller: _fechaNacimientoController,
              isDark: isDark,
              textColor: textColor,
            ),
            const SizedBox(height: 20.0),

            // Teléfono
            _buildPhoneField(
              label: "Teléfono",
              controller: _telefonoController,
              isDark: isDark,
              textColor: textColor,
            ),
            const SizedBox(height: 20.0),

            // Monedero
            _buildTextField(
              label: "Monedero (número de serie)",
              controller: _monederoController,
              isDark: isDark,
              textColor: textColor,
              placeholder: "MON-0001",
            ),
            const SizedBox(height: 20.0),

            // Correo Electrónico
            _buildEmailField(
              label: "Correo Electrónico",
              controller: _emailController,
              isDark: isDark,
              textColor: textColor,
            ),
            const SizedBox(height: 20.0),

            // Password
            _buildPasswordField(isDark: isDark, textColor: textColor),

            const SizedBox(height: 32.0),

            // Register button
            _buildRegisterButton(context),
            const SizedBox(height: 24.0),

            // Bottom links
            _buildBottomLinks(context, textColor: textColor),
            const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget desktopWidget({required BuildContext context, bool isDark = true}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    
    return StreamBuilder<String?>(
      stream: authBloc.errorStream,
      builder: (context, errorSnapshot) {
        // Actualizar el mensaje de error si viene del stream
        final error = errorSnapshot.data ?? _errorMessage;
        if (error != null && error != _errorMessage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _errorMessage = error;
              });
            }
          });
        }
        
        return Center(
      child: Card(
        color: cardColor,
        child: Container(
          width: MediaQuery.of(context).size.width / 1.6,
          height: screenHeight * 0.9,
          padding: const EdgeInsets.all(48.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                _buildLogo(isDark: isDark),
                const SizedBox(height: 32.0),
                Text(
                  "Registro",
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 40.0),

                // Nombre
                _buildTextField(
                  label: "Nombre",
                  controller: _nombreController,
                  isDark: isDark,
                  textColor: textColor,
                  placeholder: "Nombre",
                ),
                const SizedBox(height: 20.0),

                // Apellido Paterno
                _buildTextField(
                  label: "Apellido Paterno",
                  controller: _apellidoPaternoController,
                  isDark: isDark,
                  textColor: textColor,
                  placeholder: "Apellido Paterno",
                ),
                const SizedBox(height: 20.0),

                // Apellido Materno
                _buildTextField(
                  label: "Apellido Materno",
                  controller: _apellidoMaternoController,
                  isDark: isDark,
                  textColor: textColor,
                  placeholder: "Apellido Materno",
                  isRequired: false,
                ),
                const SizedBox(height: 20.0),

                // Fecha Nacimiento
                _buildDateField(
                  label: "Fecha Nacimiento",
                  controller: _fechaNacimientoController,
                  isDark: isDark,
                  textColor: textColor,
                ),
                const SizedBox(height: 20.0),

                // Teléfono
                _buildPhoneField(
                  label: "Teléfono",
                  controller: _telefonoController,
                  isDark: isDark,
                  textColor: textColor,
                ),
                const SizedBox(height: 20.0),

                // Monedero
                _buildTextField(
                  label: "Monedero (número de serie)",
                  controller: _monederoController,
                  isDark: isDark,
                  textColor: textColor,
                  placeholder: "MON-0001",
                ),
                const SizedBox(height: 20.0),

                // Correo Electrónico
                _buildEmailField(
                  label: "Correo Electrónico",
                  controller: _emailController,
                  isDark: isDark,
                  textColor: textColor,
                ),
                const SizedBox(height: 20.0),

                // Password
                _buildPasswordField(isDark: isDark, textColor: textColor),

                const SizedBox(height: 32.0),

                // Register button
                _buildRegisterButton(context),
                const SizedBox(height: 24.0),

                // Bottom links
                _buildBottomLinks(context, textColor: textColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
      },
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    required Color textColor,
    String? placeholder,
    bool isRequired = true,
    VoidCallback? onChanged,
  }) {
    final labelTextColor = textColor;
    final fieldTextColor = textColor;
    final fieldBgColor = isDark ? Colors.grey[800] : Colors.grey[100];
    final hintTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(color: fieldTextColor),
          onChanged: (value) {
            if (onChanged != null) {
              onChanged();
            }
            setState(() {}); // Actualizar para habilitar/deshabilitar botón
          },
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                }
              : null,
          decoration: InputDecoration(
            hintText: placeholder ?? "",
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
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
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
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    required Color textColor,
  }) {
    final labelTextColor = textColor;
    final fieldTextColor = textColor;
    final fieldBgColor = isDark ? Colors.grey[800] : Colors.grey[100];
    final hintTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(color: fieldTextColor),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
            LengthLimitingTextInputFormatter(10),
            _DateInputFormatter(),
          ],
          onChanged: (value) {
            setState(() {}); // Actualizar para habilitar/deshabilitar botón
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa la fecha de nacimiento';
            }
            // Validar formato dd/mm/aaaa
            final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
            if (!dateRegex.hasMatch(value)) {
              return 'Formato inválido. Use dd/mm/aaaa';
            }
            // Validar que la fecha sea válida
            try {
              final parts = value.split('/');
              final day = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final year = int.parse(parts[2]);
              final date = DateTime(year, month, day);
              if (date.year != year || date.month != month || date.day != day) {
                return 'Fecha inválida';
              }
              // Validar que no sea una fecha futura
              if (date.isAfter(DateTime.now())) {
                return 'La fecha no puede ser futura';
              }
            } catch (e) {
              return 'Fecha inválida';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: "dd/mm/aaaa",
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
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
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
        ),
      ],
    );
  }

  Widget _buildEmailField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    required Color textColor,
  }) {
    final labelTextColor = textColor;
    final fieldTextColor = textColor;
    final fieldBgColor = isDark ? Colors.grey[800] : Colors.grey[100];
    final hintTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(color: fieldTextColor),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            setState(() {}); // Actualizar para habilitar/deshabilitar botón
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu correo electrónico';
            }
            // Validar formato de correo electrónico
            final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
            if (!emailRegex.hasMatch(value)) {
              return 'Correo electrónico inválido';
            }
            return null;
          },
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
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
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
        ),
      ],
    );
  }

  Widget _buildPhoneField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    required Color textColor,
  }) {
    final labelTextColor = textColor;
    final fieldTextColor = textColor;
    final fieldBgColor = isDark ? Colors.grey[800] : Colors.grey[100];
    final hintTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(color: fieldTextColor),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          onChanged: (value) {
            setState(() {}); // Actualizar para habilitar/deshabilitar botón
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu teléfono';
            }
            if (value.length != 10) {
              return 'El teléfono debe tener 10 dígitos';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: "Teléfono",
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
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
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
        ),
      ],
    );
  }

  Widget _buildPasswordField({required bool isDark, required Color textColor}) {
    final labelTextColor = textColor;
    final fieldTextColor = textColor;
    final fieldBgColor = isDark ? Colors.grey[800] : Colors.grey[100];
    final hintTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final iconColor = isDark ? Colors.grey[400] : Colors.grey[600];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password",
          style: TextStyle(
            color: labelTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: fieldTextColor),
          onChanged: (value) {
            setState(() {}); // Actualizar para mostrar validación y habilitar/deshabilitar botón
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu contraseña';
            }
            
            // Validar longitud
            if (value.length < 7 || value.length > 15) {
              return 'La contraseña debe tener entre 7 y 15 caracteres';
            }
            
            // Validar que no contenga espacios
            if (value.contains(' ')) {
              return 'La contraseña no puede contener espacios';
            }
            
            // Validar que tenga al menos una minúscula
            if (!value.contains(RegExp(r'[a-z]'))) {
              return 'La contraseña debe tener al menos una minúscula';
            }
            
            // Validar que tenga al menos un número
            if (!value.contains(RegExp(r'[0-9]'))) {
              return 'La contraseña debe tener al menos un número';
            }
            
            // Validar que tenga al menos un símbolo
            if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
              return 'La contraseña debe incluir al menos un símbolo';
            }
            
            return null;
          },
          decoration: InputDecoration(
            hintText: "••••••••••••",
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
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 1.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: iconColor,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Reglas de contraseña (solo mostrar las que no se cumplen)
        if (!_isPasswordValid())
          _buildPasswordRules(isDark: isDark, textColor: textColor),
        // Mensaje de contraseña válida (solo cuando todas las reglas se cumplan)
        if (_isPasswordValid())
          Text(
            "Contraseña válida",
            style: TextStyle(
              color: Colors.green,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  bool _isPasswordValid() {
    final password = _passwordController.text;
    if (password.isEmpty) return false;
    
    // Validar todas las reglas
    if (password.length < 7 || password.length > 15) return false;
    if (password.contains(' ')) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    
    return true;
  }

  Widget _buildPasswordRules({required bool isDark, required Color textColor}) {
    final password = _passwordController.text;
    final ruleTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    
    // Verificar cada regla
    final hasMinLength = password.length >= 7;
    final hasMaxLength = password.length <= 15;
    final hasNoSpaces = !password.contains(' ');
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSymbol = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "La contraseña debe:",
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        _buildRuleItem(
          "Tener entre 7 y 15 caracteres",
          hasMinLength && hasMaxLength,
          ruleTextColor,
        ),
        _buildRuleItem(
          "Tener al menos una minúscula",
          hasLowercase,
          ruleTextColor,
        ),
        _buildRuleItem(
          "Tener al menos un número",
          hasNumber,
          ruleTextColor,
        ),
        _buildRuleItem(
          "Incluir un símbolo",
          hasSymbol,
          ruleTextColor,
        ),
        _buildRuleItem(
          "No contener espacios",
          hasNoSpaces,
          ruleTextColor,
        ),
      ],
    );
  }

  Widget _buildRuleItem(String text, bool isValid, Color defaultColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isValid ? Colors.green : defaultColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.green : defaultColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  bool _isFormValid() {
    // Verificar que todos los campos obligatorios estén llenos
    if (_nombreController.text.trim().isEmpty) return false;
    if (_apellidoPaternoController.text.trim().isEmpty) return false;
    // Apellido Materno es opcional, no se valida
    if (_fechaNacimientoController.text.trim().isEmpty) return false;
    if (_telefonoController.text.trim().isEmpty) return false;
    if (_emailController.text.trim().isEmpty) return false;
    if (_monederoController.text.trim().isEmpty) return false;
    
    // Verificar que la contraseña sea válida
    if (!_isPasswordValid()) return false;
    
    return true;
  }

  Future<void> _handleRegister(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    // Convertir fecha de formato dd/mm/aaaa a aaaa-mm-dd
    String fechaNacimientoFormatted = '';
    try {
      final fechaParts = _fechaNacimientoController.text.split('/');
      if (fechaParts.length == 3) {
        fechaNacimientoFormatted = '${fechaParts[2]}-${fechaParts[1]}-${fechaParts[0]}';
      } else {
        throw Exception('Formato de fecha inválido');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al formatear la fecha de nacimiento';
      });
      return;
    }

    final registroResponse = await authBloc.registerPasajero(
      nombre: _nombreController.text.trim(),
      apellidoPaterno: _apellidoPaternoController.text.trim(),
      apellidoMaterno: _apellidoMaternoController.text.trim(),
      fechaNacimiento: fechaNacimientoFormatted,
      correo: _emailController.text.trim(),
      passwordHash: _passwordController.text,
      numeroSerieMonedero: _monederoController.text.trim(),
      telefono: _telefonoController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (registroResponse != null) {
      // Mostrar mensaje de éxito
      if (mounted) {
        setState(() {
          _successMessage = registroResponse.message.isNotEmpty 
              ? registroResponse.message 
              : 'Registro exitoso. Se ha enviado un código de verificación a tu correo electrónico.';
        });
        // Redirigir a la verificación de email después de un breve delay
        // Pasar el nombre y email del usuario como parámetros en la URL
        final nombreCompleto = '${_nombreController.text.trim()} ${_apellidoPaternoController.text.trim()}'.trim();
        final email = _emailController.text.trim();
        final encodedNombre = Uri.encodeComponent(nombreCompleto);
        final encodedEmail = Uri.encodeComponent(email);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            GoRouter.of(context).go('${RoutesName.emailVerify}?nombre=$encodedNombre&email=$encodedEmail');
          }
        });
      }
    } else {
      // El error ya fue manejado por el AuthBloc
      // El mensaje de error se mostrará a través del StreamBuilder
      setState(() {
        _successMessage = null; // Limpiar mensaje de éxito si hay error
        _errorMessage = 'Error al registrar usuario. Verifica la información ingresada.';
      });
    }
  }

  Widget _buildRegisterButton(BuildContext context) {
    final isEnabled = _isFormValid() && !_isLoading;
    
    return Column(
      children: [
        // Mostrar mensaje de éxito si existe
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
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
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
        // Mostrar mensaje de error si existe
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
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: isEnabled ? () => _handleRegister(context) : null,
            style: FilledButton.styleFrom(
              backgroundColor: isEnabled
                  ? const Color(0xFF205AA8) // Blue color #205AA8
                  : Colors.grey, // Gris cuando está deshabilitado
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
                : const Text(
                    "Registrar",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomLinks(BuildContext context, {Color? textColor}) {
    final linkColor = textColor ?? Colors.white;
    
    return Column(
      children: [
        Center(
          child: TextButton(
            onPressed: () => GoRouter.of(context).go(RoutesName.forgotPassword),
            child: Text(
              "¿Olvidaste tu Contraseña?",
              style: TextStyle(
                color: linkColor,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => GoRouter.of(context).go(RoutesName.login),
            child: Text(
              "Iniciar sesión",
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
}

// Formatter para fecha de nacimiento (dd/mm/aaaa)
class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Si está vacío, permitir
    if (text.isEmpty) {
      return newValue;
    }
    
    // Eliminar todo excepto números
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Si no hay dígitos, retornar vacío
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }
    
    // Construir el formato con barras
    String formatted = '';
    for (int i = 0; i < digitsOnly.length && i < 8; i++) {
      if (i == 2 || i == 4) {
        formatted += '/';
      }
      formatted += digitsOnly[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
