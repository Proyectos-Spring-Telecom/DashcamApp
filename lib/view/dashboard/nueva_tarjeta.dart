// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class NuevaTarjetaPage extends StatefulWidget {
  const NuevaTarjetaPage({super.key});

  @override
  State<NuevaTarjetaPage> createState() => _NuevaTarjetaPageState();
}

class _NuevaTarjetaPageState extends State<NuevaTarjetaPage> {
  final TextEditingController _nombreController = TextEditingController(text: "Maria Jane Perez");
  final TextEditingController _numeroController = TextEditingController(text: "1234 5678 9999 0000");
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController(text: "123");
  bool _isDefault = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _numeroController.dispose();
    _fechaController.dispose();
    _cvvController.dispose();
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
        
        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context, textColor: textColor),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card preview
                          _buildCardPreview(textColor: textColor),
                          const SizedBox(height: 24),
                          // Form fields
                          _buildFormFields(textColor: textColor, isDark: isDark),
                        ],
                      ),
                    ),
                  ),
                ),
                // Save button fixed at bottom
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildSaveButton(),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context, isDark),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () {
              if (GoRouter.of(context).canPop()) {
                GoRouter.of(context).pop();
              } else {
                GoRouter.of(context).go(RoutesName.metodosPago);
              }
            },
          ),
          // Title
          Expanded(
            child: Text(
              "Agregar método de pago",
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
              backgroundColor: Colors.grey[800],
              child: const Icon(Icons.person, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPreview({Color textColor = Colors.white}) {
    return Stack(
      children: [
        // Card container
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF3A3A3A), // Dark grey card
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Light grey stripe at top
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              // Card number
              Text(
                _numeroController.text.isEmpty ? "1234 5678 9999 0000" : _numeroController.text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              // CVV and Cardholder name row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "CVV ${_cvvController.text.isEmpty ? "123" : _cvvController.text}",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _nombreController.text.isEmpty ? "Andrea Barajas Cruz" : _nombreController.text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Toggle switch
                  Switch(
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() {
                        _isDefault = value;
                      });
                    },
                    activeColor: Colors.blue,
                    inactiveThumbColor: Colors.grey[600],
                    inactiveTrackColor: Colors.grey[800],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields({Color textColor = Colors.white, bool isDark = true}) {
    final labelColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final fillColor = isDark ? Colors.grey[900] : Colors.grey[100];
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final focusedBorderColor = isDark ? Colors.white : Colors.black;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre en la tarjeta
        Text(
          "Nombre en la tarjeta",
          style: TextStyle(
            color: labelColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nombreController,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: focusedBorderColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        const SizedBox(height: 16),
        // Número de tarjeta
        Text(
          "Número de tarjeta",
          style: TextStyle(
            color: labelColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _numeroController,
          style: TextStyle(color: textColor),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: focusedBorderColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        const SizedBox(height: 16),
        // Fecha Expiración and CVV row
        Row(
          children: [
            // Fecha Expiración
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Fecha Expiración",
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _fechaController,
                    style: TextStyle(color: textColor),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: fillColor,
                      hintText: "MM/AA",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: focusedBorderColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // CVV
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CVV",
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _cvvController,
                    style: TextStyle(color: textColor),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: fillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: focusedBorderColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () {
          // Lógica para guardar tarjeta
          print("Guardar tarjeta");
          // Navegar de vuelta a métodos de pago
          GoRouter.of(context).pop();
        },
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF205AA8), // Blue
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Guardar",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isDark) {
    final navBarColor = isDark ? Colors.grey[900] : Colors.grey[100];
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
        currentIndex: 2, // Configuración is selected
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Monedero',
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
            GoRouter.of(context).go(RoutesName.perfil);
          }
        },
      ),
    );
  }
}

