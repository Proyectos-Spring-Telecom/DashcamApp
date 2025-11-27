// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C), // Dark grey background
      body: SafeArea(
        child: Responsive(
          mobile: mobileWidget(context: context),
          desktop: desktopWidget(context: context),
          tablet: mobileWidget(context: context),
        ),
      ),
    );
  }

  Widget mobileWidget({required BuildContext context}) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo section - Top
            _buildLogo(),
            const SizedBox(height: 32.0),

            // Title
            Text(
              "Registro",
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
                      ),
                      const SizedBox(height: 20.0),
                      _buildTextField(
                        label: "Apellido Paterno",
                        controller: _apellidoPaternoController,
                      ),
                      const SizedBox(height: 20.0),
                      _buildTextField(
                        label: "Apellido Materno",
                        controller: _apellidoMaternoController,
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
                      ),
                      const SizedBox(height: 20.0),
                      _buildTextField(
                        label: "Teléfono",
                        controller: _telefonoController,
                      ),
                      const SizedBox(height: 20.0),
                      _buildTextField(
                        label: "Correo Electrónico",
                        controller: _emailController,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20.0),

            // Password in its own row
            _buildPasswordField(),
            const SizedBox(height: 20.0),
            // Monedero in its own row
            _buildTextField(
              label: "Monedero (número de serie)",
              controller: _monederoController,
            ),

            const SizedBox(height: 32.0),

            // Register button
            _buildRegisterButton(context),
            const SizedBox(height: 24.0),

            // Bottom links
            _buildBottomLinks(context),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  Widget desktopWidget({required BuildContext context}) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Card(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.6,
          height: screenHeight * 0.9,
          padding: const EdgeInsets.all(48.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogo(),
                const SizedBox(height: 32.0),
                Text(
                  "Registro",
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                          ),
                          const SizedBox(height: 20.0),
                          _buildTextField(
                            label: "Apellido Paterno",
                            controller: _apellidoPaternoController,
                          ),
                          const SizedBox(height: 20.0),
                          _buildTextField(
                            label: "Apellido Materno",
                            controller: _apellidoMaternoController,
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
                          ),
                          const SizedBox(height: 20.0),
                          _buildTextField(
                            label: "Teléfono",
                            controller: _telefonoController,
                          ),
                          const SizedBox(height: 20.0),
                          _buildTextField(
                            label: "Correo Electrónico",
                            controller: _emailController,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20.0),

                // Password in its own row
                _buildPasswordField(),
                const SizedBox(height: 20.0),
                // Monedero in its own row
                _buildTextField(
                  label: "Monedero (número de serie)",
                  controller: _monederoController,
                ),

                const SizedBox(height: 32.0),

                // Register button
                _buildRegisterButton(context),
                const SizedBox(height: 24.0),

                // Bottom links
                _buildBottomLinks(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo_dash.png',
      height: 80,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 60,
          color: Colors.red.withOpacity(0.3),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "",
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[800],
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "••••••••••••",
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[800],
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[400],
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

  Widget _buildBottomLinks(BuildContext context) {
    return Column(
      children: [
        Center(
          child: TextButton(
            onPressed: () => GoRouter.of(context).go(RoutesName.forgotPassword),
            child: Text(
              "¿Olvidaste tu Contraseña?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: TextButton(
            onPressed: () => GoRouter.of(context).go(RoutesName.login),
            child: Text(
              "Iniciar sesión",
              style: TextStyle(
                color: Colors.white,
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
