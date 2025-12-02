// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:file_picker/file_picker.dart';

class CargarConstanciaFiscalPage extends StatefulWidget {
  const CargarConstanciaFiscalPage({super.key});

  @override
  State<CargarConstanciaFiscalPage> createState() => _CargarConstanciaFiscalPageState();
}

class _CargarConstanciaFiscalPageState extends State<CargarConstanciaFiscalPage> {
  final _rfcController = TextEditingController();
  final _idCIFController = TextEditingController();

  @override
  void dispose() {
    _rfcController.dispose();
    _idCIFController.dispose();
    super.dispose();
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      // File selected, can be used for upload
      // result.files.single.path contains the file path
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
        final inputBgColor = isDark ? Colors.grey[900]! : Colors.grey[50]!;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
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
                          // Seleccionar archivo button
                          _buildSelectFileButton(
                            textColor: textColor,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16.0),

                          // Information box
                          _buildInfoBox(
                            textColor: textColor,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 24.0),

                          // Divider
                          Divider(color: Colors.grey.withOpacity(0.3), height: 1),
                          const SizedBox(height: 24.0),

                          // Manual input section
                          Text(
                            "O captura lo siguiente:",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20.0),

                          // RFC Field
                          _buildTextField(
                            label: "RFC",
                            controller: _rfcController,
                            textColor: textColor,
                            inputBgColor: inputBgColor,
                            isDark: isDark,
                            hintText: "ERF1234123",
                          ),
                          const SizedBox(height: 20.0),

                          // idCIF Field
                          _buildIdCIFField(
                            controller: _idCIFController,
                            textColor: textColor,
                            inputBgColor: inputBgColor,
                            isDark: isDark,
                            hintText: "12345667890",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Obtener Datos Button - Fixed at bottom
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildObtenerDatosButton(context, textColor: textColor),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context, isDark: isDark),
        );
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
              "Cargar Constancia Fiscal",
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
              child: Icon(
                Icons.person,
                color: textColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectFileButton({
    required Color textColor,
    required bool isDark,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _selectFile,
        icon: Container(
          width: 24,
          height: 24,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.description,
                color: Colors.white,
                size: 20,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_upward,
                    color: const Color(0xFFA6CE39),
                    size: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
        label: Text(
          "Seleccionar archivo",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA6CE39), // Lime green
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox({
    required Color textColor,
    required bool isDark,
  }) {
    final boxColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Cargar archivo en formato PDF. Verificar que tu Constancia de Situación Fiscal haya sido emitida a partir de enero 2023.",
              style: TextStyle(
                color: textColor,
                fontSize: 14,
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

  Widget _buildIdCIFField({
    required TextEditingController controller,
    required Color textColor,
    required Color inputBgColor,
    required bool isDark,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "idCIF",
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.info_outline,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              size: 16,
            ),
          ],
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

  Widget _buildObtenerDatosButton(BuildContext context, {Color textColor = Colors.white}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle obtener datos action
          // Try to pop first, if not possible, navigate back
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
          "Obtener Datos",
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
    return Container(
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
        backgroundColor: navBarColor,
        selectedItemColor: const Color(0xFF205AA8), // Blue
        unselectedItemColor: Colors.grey[600],
        currentIndex: 2, // Settings is selected
        type: BottomNavigationBarType.fixed,
        elevation: 0,
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
            // Navegar al dashboard
            GoRouter.of(context).go(RoutesName.dashboard);
          } else if (index == 1) {
            // Abrir bottomsheet de Monedero (Actividad)
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const MonederoBottomSheet(),
            );
          } else if (index == 2) {
            // Navegar a perfil de usuario
            GoRouter.of(context).go(RoutesName.perfil);
          }
        },
      ),
    );
  }
}

