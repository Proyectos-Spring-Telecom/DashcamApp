// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:flutter/services.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _nombreController = TextEditingController(text: "Thomas");
  final _apellidoPaternoController = TextEditingController(text: "Thomas");
  final _apellidoMaternoController = TextEditingController(text: "Hernández");
  final _fechaNacimientoController = TextEditingController(text: "1995/09/23");
  final _telefonoController = TextEditingController(text: "(55) 1234 3412");
  final _emailController = TextEditingController(text: "correo@gmail.com");
  final _passwordController = TextEditingController();
  final _monederoController = TextEditingController(text: "AVBDG1231234234");
  bool _obscurePassword = true;

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
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
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

            // Two column fields layout for first 6 fields
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  child: Column(
                    children: [
                      _buildTextField(
                        label: "Nombre",
                        controller: _nombreController,
                        isDark: isDark,
                        textColor: textColor,
                      ),
                      const SizedBox(height: 20.0),
                      _buildTextField(
                        label: "Apellido Paterno",
                        controller: _apellidoPaternoController,
                        isDark: isDark,
                        textColor: textColor,
                      ),
                      const SizedBox(height: 20.0),
                      _buildTextField(
                        label: "Apellido Materno",
                        controller: _apellidoMaternoController,
                        isDark: isDark,
                        textColor: textColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),
                // Right column
                Expanded(
                  child: Column(
                    children: [
                      _buildTextField(
                        label: "Fecha Nacimiento",
                        controller: _fechaNacimientoController,
                        isDark: isDark,
                        textColor: textColor,
                      ),
                      const SizedBox(height: 20.0),
                      _buildTextField(
                        label: "Teléfono",
                        controller: _telefonoController,
                        isDark: isDark,
                        textColor: textColor,
                      ),
                      const SizedBox(height: 20.0),
                      _buildTextField(
                        label: "Correo Electrónico",
                        controller: _emailController,
                        isDark: isDark,
                        textColor: textColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20.0),

            // Password in its own row
            _buildPasswordField(isDark: isDark, textColor: textColor),
            const SizedBox(height: 20.0),
            // Monedero in its own row
            _buildTextField(
              label: "Monedero (número de serie)",
              controller: _monederoController,
              isDark: isDark,
              textColor: textColor,
            ),

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
    );
  }

  Widget desktopWidget({required BuildContext context, bool isDark = true}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final textColor = isDark ? Colors.white : Colors.black;
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

                // Two column fields layout for first 6 fields
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column
                    Expanded(
                      child: Column(
                        children: [
                          _buildTextField(
                            label: "Nombre",
                            controller: _nombreController,
                            isDark: isDark,
                            textColor: textColor,
                          ),
                          const SizedBox(height: 20.0),
                          _buildTextField(
                            label: "Apellido Paterno",
                            controller: _apellidoPaternoController,
                            isDark: isDark,
                            textColor: textColor,
                          ),
                          const SizedBox(height: 20.0),
                          _buildTextField(
                            label: "Apellido Materno",
                            controller: _apellidoMaternoController,
                            isDark: isDark,
                            textColor: textColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24.0),
                    // Right column
                    Expanded(
                      child: Column(
                        children: [
                          _buildTextField(
                            label: "Fecha Nacimiento",
                            controller: _fechaNacimientoController,
                            isDark: isDark,
                            textColor: textColor,
                          ),
                          const SizedBox(height: 20.0),
                          _buildTextField(
                            label: "Teléfono",
                            controller: _telefonoController,
                            isDark: isDark,
                            textColor: textColor,
                          ),
                          const SizedBox(height: 20.0),
                          _buildTextField(
                            label: "Correo Electrónico",
                            controller: _emailController,
                            isDark: isDark,
                            textColor: textColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20.0),

                // Password in its own row
                _buildPasswordField(isDark: isDark, textColor: textColor),
                const SizedBox(height: 20.0),
                // Monedero in its own row
                _buildTextField(
                  label: "Monedero (número de serie)",
                  controller: _monederoController,
                  isDark: isDark,
                  textColor: textColor,
                ),

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
          decoration: InputDecoration(
            hintText: "",
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
      ],
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () => GoRouter.of(context).go(RoutesName.dashboard),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF205AA8), // Blue color #205AA8
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Registrar",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
