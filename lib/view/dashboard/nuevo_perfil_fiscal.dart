// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:flutter/services.dart';

class NuevoPerfilFiscalPage extends StatefulWidget {
  const NuevoPerfilFiscalPage({super.key});

  @override
  State<NuevoPerfilFiscalPage> createState() => _NuevoPerfilFiscalPageState();
}

class _NuevoPerfilFiscalPageState extends State<NuevoPerfilFiscalPage> {
  bool _isMoral = true; // true = Moral, false = Física
  
  // Controllers for Moral
  final _rfcController = TextEditingController(text: "ERF1234123");
  final _razonSocialController = TextEditingController(text: "Razon Social S.A de C.V");
  final _emailController = TextEditingController(text: "correo@gmail.com");
  final _celularController = TextEditingController();
  String? _selectedRegimen;
  
  // Controllers for Física
  final _rfcFisicaController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final _emailFisicaController = TextEditingController();
  final _celularFisicaController = TextEditingController();
  String? _selectedRegimenFiscal;
  String? _selectedUsoCFDI;
  String? _selectedDomicilio;

  @override
  void dispose() {
    _rfcController.dispose();
    _razonSocialController.dispose();
    _emailController.dispose();
    _celularController.dispose();
    _rfcFisicaController.dispose();
    _nombresController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _emailFisicaController.dispose();
    _celularFisicaController.dispose();
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
        final textColor = isDark ? Colors.white : Colors.black;
        final inputBgColor = isDark ? Colors.grey[900]! : Colors.grey[50]!;

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
                child: Column(
              children: [
                // Header
                _buildHeader(context, textColor: textColor, isDark: isDark),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Toggle Física/Moral
                          _buildToggleSelector(
                            isMoral: _isMoral,
                            onChanged: (value) {
                              setState(() {
                                _isMoral = value;
                              });
                            },
                            textColor: textColor,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 24.0),

                          // Show different fields based on _isMoral
                          if (_isMoral) ..._buildMoralFields(
                            textColor: textColor,
                            inputBgColor: inputBgColor,
                            isDark: isDark,
                          ) else ..._buildFisicaFields(
                            textColor: textColor,
                            inputBgColor: inputBgColor,
                            isDark: isDark,
                          ),

                          const SizedBox(height: 32.0),

                          // Guardar Button
                          _buildSaveButton(context, textColor: textColor),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context, isDark: isDark),
        ),
      },
    );
  }

  Widget _buildHeader(BuildContext context,
      {Color textColor = Colors.white, bool isDark = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () {
              // Try to pop first, if not possible, navigate back
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                GoRouter.of(context).go(RoutesName.perfil);
              }
            },
          ),
          // Title
          Expanded(
            child: Text(
              "Nuevo perfil fiscal",
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Profile avatar
          GestureDetector(
            onTap: () {
              GoRouter.of(context).go(RoutesName.perfil);
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
              child: Icon(Icons.person, color: textColor, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSelector({
    required bool isMoral,
    required Function(bool) onChanged,
    required Color textColor,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: !isMoral
                      ? const Color(0xFFA6CE39) // Green when selected
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "Física",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: !isMoral ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: isMoral
                      ? const Color(0xFFA6CE39) // Green when selected
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "Moral",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: isMoral ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required Color textColor,
    required Color inputBgColor,
    required bool isDark,
    TextInputType? keyboardType,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: inputBgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white,
              width: 1.0,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMoralFields({
    required Color textColor,
    required Color inputBgColor,
    required bool isDark,
  }) {
    return [
      // RFC Field
      _buildTextField(
        label: "RFC",
        controller: _rfcController,
        textColor: textColor,
        inputBgColor: inputBgColor,
        isDark: isDark,
      ),
      const SizedBox(height: 20.0),

      // Razón Social Field
      _buildTextField(
        label: "Razón Social",
        controller: _razonSocialController,
        textColor: textColor,
        inputBgColor: inputBgColor,
        isDark: isDark,
      ),
      const SizedBox(height: 20.0),

      // Régimen Capital Dropdown
      _buildDropdownField(
        label: "Régimen Capital",
        selectedValue: _selectedRegimen,
        onChanged: (value) {
          setState(() {
            _selectedRegimen = value;
          });
        },
        textColor: textColor,
        inputBgColor: inputBgColor,
        isDark: isDark,
        items: ["Régimen 1", "Régimen 2", "Régimen 3"],
      ),
      const SizedBox(height: 20.0),

      // Email Field
      _buildTextField(
        label: "Email",
        controller: _emailController,
        textColor: textColor,
        inputBgColor: inputBgColor,
        isDark: isDark,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 20.0),

      // Número celular Field
      _buildTextField(
        label: "Número celular",
        controller: _celularController,
        textColor: textColor,
        inputBgColor: inputBgColor,
        isDark: isDark,
        keyboardType: TextInputType.phone,
        hintText: "10 dígitos",
      ),
    ];
  }

  List<Widget> _buildFisicaFields({
    required Color textColor,
    required Color inputBgColor,
    required bool isDark,
  }) {
    return [
      // RFC Field
      _buildTextField(
        label: "RFC",
        controller: _rfcFisicaController,
        textColor: textColor,
        inputBgColor: inputBgColor,
        isDark: isDark,
      ),
      const SizedBox(height: 20.0),

      // Nombre(s) Field
      _buildTextField(
        label: "Nombre(s)",
        controller: _nombresController,
        textColor: textColor,
        inputBgColor: inputBgColor,
        isDark: isDark,
      ),
      const SizedBox(height: 20.0),

      // Apellido Paterno Field
      _buildTextField(
        label: "Apellido Paterno",
        controller: _apellidoPaternoController,
        textColor: textColor,
        inputBgColor: inputBgColor,
        isDark: isDark,
      ),
      const SizedBox(height: 20.0),

      // Apellido Materno Field
      _buildTextField(
        label: "Apellido Materno",
        controller: _apellidoMaternoController,
        textColor: textColor,
        inputBgColor: inputBgColor,
        isDark: isDark,
      ),
      const SizedBox(height: 20.0),

      // Email Field
      _buildTextField(
        label: "Email",
        controller: _emailFisicaController,
        textColor: textColor,
        inputBgColor: inputBgColor,
        isDark: isDark,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 20.0),

      // Número de celular Field
      _buildTextField(
        label: "Número de celular",
        controller: _celularFisicaController,
        textColor: textColor,
        inputBgColor: inputBgColor,
        isDark: isDark,
        keyboardType: TextInputType.phone,
        hintText: "10 dígitos",
      ),
      const SizedBox(height: 20.0),

      // Régimen fiscal Dropdown
      _buildDropdownField(
        label: "Régimen fiscal",
        selectedValue: _selectedRegimenFiscal,
        onChanged: (value) {
          setState(() {
            _selectedRegimenFiscal = value;
          });
        },
        textColor: textColor,
        inputBgColor: inputBgColor,
        isDark: isDark,
        items: ["Régimen Fiscal 1", "Régimen Fiscal 2", "Régimen Fiscal 3"],
      ),
      const SizedBox(height: 20.0),

      // Uso de CFDI Dropdown
      _buildDropdownField(
        label: "Uso de CFDI",
        selectedValue: _selectedUsoCFDI,
        onChanged: (value) {
          setState(() {
            _selectedUsoCFDI = value;
          });
        },
        textColor: textColor,
        inputBgColor: inputBgColor,
        isDark: isDark,
        items: ["Uso CFDI 1", "Uso CFDI 2", "Uso CFDI 3"],
      ),
      const SizedBox(height: 20.0),

      // Domicilio Dropdown
      _buildDropdownField(
        label: "Domicilio",
        selectedValue: _selectedDomicilio,
        onChanged: (value) {
          setState(() {
            _selectedDomicilio = value;
          });
        },
        textColor: textColor,
        inputBgColor: inputBgColor,
        isDark: isDark,
        items: ["Domicilio 1", "Domicilio 2", "Domicilio 3"],
      ),
    ];
  }

  Widget _buildDropdownField({
    required String label,
    required String? selectedValue,
    required Function(String?) onChanged,
    required Color textColor,
    required Color inputBgColor,
    required bool isDark,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: inputBgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white,
              width: 1.0,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            decoration: InputDecoration(
              hintText: "Selecciona",
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
            ),
            dropdownColor: isDark ? Colors.grey[800] : Colors.white,
            style: TextStyle(color: textColor),
            icon: Icon(Icons.arrow_drop_down, color: textColor),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, {Color textColor = Colors.white}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle save action
          // Try to pop first, if not possible, navigate back to profile
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            GoRouter.of(context).go(RoutesName.perfil);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF205AA8), // Blue
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          "Guardar",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, {bool isDark = true}) {
    final navBarColor = isDark ? Colors.grey[900]! : Colors.grey[100]!;
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
          currentIndex: 1, // Search is selected
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
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const MonederoBottomSheet(),
            );
          } else if (index == 2) {
            GoRouter.of(context).go(RoutesName.comingSoon);
          }
        },
      ),
      ),
    );
  }
}

