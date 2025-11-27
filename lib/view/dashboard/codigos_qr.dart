// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:dashboardpro/view/dashboard/detalles_viaje_bottom_sheet.dart';

class CodigosQRPage extends StatefulWidget {
  const CodigosQRPage({super.key});

  @override
  State<CodigosQRPage> createState() => _CodigosQRPageState();
}

class _CodigosQRPageState extends State<CodigosQRPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 1; // Códigos QR is selected

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });

      // Navigate to appropriate screen when tabs change
      if (_tabController.index == 0) {
        // General - Navigate to dashboard
        GoRouter.of(context).go(RoutesName.dashboard);
      }
      // Viajes (index 2) - Show content in same page, no navigation
      // Operaciones (index 3) - Show content in same page, no navigation
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
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

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Responsive(
              mobile: mobileWidget(context: context, isDark: isDark),
              desktop: desktopWidget(context: context, isDark: isDark),
              tablet: mobileWidget(context: context, isDark: isDark),
            ),
          ),
          bottomNavigationBar:
              _buildBottomNavigationBar(context, isDark: isDark),
        );
      },
    );
  }

  Widget mobileWidget({required BuildContext context, required bool isDark}) {
    return Column(
      children: [
        // Header
        _buildHeader(context, isDark: isDark),

        // Tabs
        _buildTabs(isDark: isDark),

        // Content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedTabIndex == 1) ...[
                    // Código QR section
                    _buildCodigoQRSection(context, isDark: isDark),
                    const SizedBox(height: 24.0),

                    // Mis códigos section
                    _buildMisCodigosSection(isDark: isDark),
                  ] else if (_selectedTabIndex == 2) ...[
                    // Viajes section
                    _buildViajesSection(isDark: isDark),
                  ] else if (_selectedTabIndex == 3) ...[
                    // Operaciones section
                    _buildOperacionesSection(isDark: isDark),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget desktopWidget({required BuildContext context, required bool isDark}) {
    return Column(
      children: [
        // Header
        _buildHeader(context, isDark: isDark),

        // Tabs
        _buildTabs(isDark: isDark),

        // Content
        Expanded(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedTabIndex == 1) ...[
                        // Código QR section
                        _buildCodigoQRSection(context, isDark: isDark),
                        const SizedBox(height: 24.0),

                        // Mis códigos section
                        _buildMisCodigosSection(isDark: isDark),
                      ] else if (_selectedTabIndex == 2) ...[
                        // Viajes section
                        _buildViajesSection(isDark: isDark),
                      ] else if (_selectedTabIndex == 3) ...[
                        // Operaciones section
                        _buildOperacionesSection(isDark: isDark),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, {bool isDark = true}) {
    final textColor = isDark ? Colors.white : Colors.black;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          // Hamburger menu
          IconButton(
            icon: Icon(Icons.menu, color: textColor),
            onPressed: () {
              // Abrir drawer o menú
            },
          ),

          // Monedero title with green dot
          Row(
            children: [
              Text(
                "Monedero",
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFA6CE39), // Green
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          // Spacer to push avatar to the right
          Spacer(),

          // Profile avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
            child: Icon(Icons.person, color: textColor, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs({bool isDark = true}) {
    final textColor = isDark ? Colors.white : Colors.black;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem('General', 0, textColor: textColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabItem('Códigos QR', 1, textColor: textColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabItem('Viajes', 2, textColor: textColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabItem('Registros', 3, textColor: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index,
      {Color textColor = Colors.white}) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF205AA8) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildCodigoQRSection(BuildContext context, {bool isDark = true}) {
    final cardColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;
    final textColor = isDark ? Colors.white : Colors.black;
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Código QR",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Genera código qr para realizar pagos.",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Large button with plus icon
          GestureDetector(
            onTap: () {
              // Navigate to QR code generation
              GoRouter.of(context).go(RoutesName.pagoQR);
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF205AA8), // Blue
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMisCodigosSection({bool isDark = true}) {
    final textColor = isDark ? Colors.white : Colors.black;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mis códigos",
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // List of QR codes
        _buildCodigoItem(
          code: "1234567VBDFFJGRTH",
          date: "01-Mayo-2025",
          amount: "-\$ 15",
          type: "Débito",
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildCodigoItem(
          code: "1234567VBDFFJGRTH",
          date: "01-Mayo-2025",
          amount: "-\$ 15",
          type: "Débito",
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildCodigoItem(
          code: "1234567VBDFFJGRTH",
          date: "01-Mayo-2025",
          amount: "-\$ 15",
          type: "Débito",
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildCodigoItem(
          code: "1234567VBDFFJGRTH",
          date: "01-Mayo-2025",
          amount: "-\$ 15",
          type: "Débito",
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildCodigoItem({
    required String code,
    required String date,
    required String amount,
    required String type,
    bool isDark = true,
  }) {
    final cardColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;
    final textColor = isDark ? Colors.white : Colors.black;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // QR icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFDB462)
                  .withOpacity(0.2), // Orange with opacity
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code,
              color: Color(0xFFFDB462), // Orange
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Code and date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Amount and type
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                type,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperacionesSection({bool isDark = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tarjeta de saldo
        _buildSaldoCard(),
        const SizedBox(height: 24),
        // Lista de transacciones
        _buildTransaccionItem(
          description: "1234567VBDFFJGRTH",
          date: "01-Mayo-2022",
          amount: "-\$ 15",
          type: "Débito",
          iconType: 'qr', // QR code icon
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTransaccionItem(
          description: "1234567VBDFFJGRTH",
          date: "01-Mayo-2022",
          amount: "-\$ 10",
          type: "Débito",
          iconType: 'bus', // Bus icon
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTransaccionItem(
          description: "1234567VBDFFJGRTH",
          date: "01-Mayo-2022",
          amount: "-\$ 20",
          type: "Débito",
          iconType: 'qr', // QR code icon
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTransaccionItem(
          description: "1234567VBDFFJGRTH",
          date: "01-Mayo-2022",
          amount: "\$ 100",
          type: "Recarga",
          iconType: 'recharge', // Dollar/recharge icon
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTransaccionItem(
          description: "1234567VBDFFJGRTH",
          date: "01-Mayo-2022",
          amount: "-\$ 20",
          type: "Débito",
          iconType: 'bus', // Bus icon
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTransaccionItem(
          description: "1234567VBDFFJGRTH",
          date: "01-Mayo-2022",
          amount: "-\$ 20",
          type: "Débito",
          iconType: 'qr', // QR code icon
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTransaccionItem(
          description: "1234567VBDFFJGRTH",
          date: "01-Mayo-2022",
          amount: "\$ 100",
          type: "Recarga",
          iconType: 'recharge', // Dollar/recharge icon
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTransaccionItem(
          description: "1234567VBDFFJGRTH",
          date: "01-Mayo-2022",
          amount: "-\$ 20",
          type: "Débito",
          iconType: 'bus', // Bus icon
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSaldoCard() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF205AA8), // Blue
            Color(0xFF6B46C1), // Purple
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: "Saldo total:" and "Estudiante" tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Saldo total:",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFA6CE39), // Green
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Estudiante",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Balance amount
          Text(
            "\$ 222,358",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Bottom row: Card number and logo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "**** **** **** 0322",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.directions_bus,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "DASHCAM PAY",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransaccionItem({
    required String description,
    required String date,
    required String amount,
    required String type,
    required String iconType,
    bool isDark = true,
  }) {
    IconData iconData;
    Color iconColor;

    if (iconType == 'qr') {
      iconData = Icons.qr_code;
      iconColor = const Color(0xFF205AA8); // Blue
    } else if (iconType == 'bus') {
      iconData = Icons.directions_bus;
      iconColor = const Color(0xFF205AA8); // Blue
    } else {
      // recharge
      iconData = Icons.attach_money;
      iconColor = const Color(0xFFA6CE39); // Green
    }

    final cardColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Description and date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Amount and type
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                type,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
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
        currentIndex: 1, // Monedero is selected
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
    );
  }

  // Viajes Section
  Widget _buildViajesSection({bool isDark = true}) {
    final cardColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;
    final textColor = isDark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Último Viaje section
        _buildUltimoViajeSection(
          textColor: textColor,
          isDark: isDark,
          cardColor: cardColor,
        ),
        const SizedBox(height: 24.0),

        // Actividad section
        Text(
          "Actividad",
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),

        // Activity grid 2x2
        _buildActivityGrid(
          textColor: textColor,
          isDark: isDark,
          cardColor: cardColor,
        ),
      ],
    );
  }

  Widget _buildUltimoViajeSection({
    required Color textColor,
    required bool isDark,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Último Viaje:",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Calle Ignacio Zaragoza 12",
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "27 Nov 25 - 12:13 pm",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              // Total aligned to the right
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Total: \$ 84.14",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          // Top right - Green car icon
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFA6CE39), // Green
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.directions_car,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityGrid({
    required Color textColor,
    required bool isDark,
    required Color cardColor,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildActivityCard(
          location: "Ignacio Zaragoza 12",
          dateTime: "27 Nov 25 - 12:13 pm",
          cost: "\$ 84.14",
          textColor: textColor,
          cardColor: cardColor,
        );
      },
    );
  }

  Widget _buildActivityCard({
    required String location,
    required String dateTime,
    required String cost,
    required Color textColor,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                dateTime,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cost,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Detalle button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Obtener el Navigator principal antes de cerrar
                final navigator = Navigator.of(context, rootNavigator: false);
                // Cerrar el bottomsheet actual
                navigator.pop();
                // Abrir el bottomsheet de detalles del viaje usando el Navigator principal
                Future.delayed(const Duration(milliseconds: 200), () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (newContext) => const DetallesViajeBottomSheet(),
                  );
                });
              },
              icon: const Icon(
                Icons.description,
                size: 16,
                color: Colors.white,
              ),
              label: const Text(
                "Detalle",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF205AA8), // Blue
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
