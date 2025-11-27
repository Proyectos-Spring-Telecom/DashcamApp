// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
    return Column(
      children: [
        // Header with back button, title, and profile
        _buildHeader(context),

        // Content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instructions text
                  Text(
                    "Sigue las indicaciones para realizar el cambio de contraseña.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  // Current Password field
                  _buildPasswordField(
                    label: "Contraseña Actual",
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrentPassword,
                    onVisibilityToggle: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                  const SizedBox(height: 20.0),

                  // New Password field
                  _buildPasswordField(
                    label: "Contraseña Nueva",
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    onVisibilityToggle: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                  const SizedBox(height: 20.0),

                  // Confirm Password field
                  _buildPasswordField(
                    label: "Confirmar Contraseña",
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    onVisibilityToggle: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  const SizedBox(height: 24.0),

                  // Password security indicator
                  _buildPasswordSecurityIndicator(),
                ],
              ),
            ),
          ),
        ),

        // Change Password button fixed at bottom
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildChangePasswordButton(context),
        ),
      ],
    );
  }

  Widget desktopWidget({required BuildContext context}) {
    return Column(
      children: [
        // Header with back button, title, and profile
        _buildHeader(context),

        // Content
        Expanded(
          child: Center(
            child: Card(
              child: Container(
                width: MediaQuery.of(context).size.width / 1.6,
                height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.all(48.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Instructions text
                      Text(
                        "Sigue las indicaciones para realizar el cambio de contraseña.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 40.0),

                      // Current Password field
                      _buildPasswordField(
                        label: "Contraseña Actual",
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        onVisibilityToggle: () {
                          setState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
                          });
                        },
                      ),
                      const SizedBox(height: 20.0),

                      // New Password field
                      _buildPasswordField(
                        label: "Contraseña Nueva",
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        onVisibilityToggle: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                      const SizedBox(height: 20.0),

                      // Confirm Password field
                      _buildPasswordField(
                        label: "Confirmar Contraseña",
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        onVisibilityToggle: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      const SizedBox(height: 24.0),

                      // Password security indicator
                      _buildPasswordSecurityIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Change Password button fixed at bottom
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildChangePasswordButton(context),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => GoRouter.of(context).go(RoutesName.login),
          ),

          // Title
          Expanded(
            child: Text(
              "Cambio de contraseña",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Profile avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[800],
            child: Icon(Icons.person, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onVisibilityToggle,
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
          obscureText: obscureText,
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
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[400],
              ),
              onPressed: onVisibilityToggle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordSecurityIndicator() {
    return Row(
      children: [
        Text(
          "Seguridad en contraseña",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            // Red circle
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            // Orange circle
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            // Green circle
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChangePasswordButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => GoRouter.of(context).go(RoutesName.dashboard),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF205AA8), // Blue color #205AA8
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            "Cambiar Contraseña",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
