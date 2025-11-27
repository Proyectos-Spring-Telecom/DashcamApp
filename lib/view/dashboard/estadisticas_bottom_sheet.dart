// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class EstadisticasBottomSheet extends StatefulWidget {
  const EstadisticasBottomSheet({super.key});

  @override
  State<EstadisticasBottomSheet> createState() =>
      _EstadisticasBottomSheetState();
}

class _EstadisticasBottomSheetState extends State<EstadisticasBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

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
    final screenHeight = MediaQuery.of(context).size.height;

    return StreamBuilder<AppTheme>(
      stream: themeBloc.themeStream,
      initialData: themeBloc.currentTheme,
      builder: (context, snapshot) {
        final isDark = snapshot.data?.data.brightness == Brightness.dark;
        final backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;

        return Container(
          height: screenHeight * 0.85,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Tabs
              _buildTabs(),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGeneralTab(textColor: textColor),
                    _buildQRCodesTab(textColor: textColor, isDark: isDark),
                    _buildGoalsTab(textColor: textColor),
                    _buildOperacionesTab(textColor: textColor, isDark: isDark),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem('General', 0),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabItem('Códigos QR', 1),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabItem('Viajes', 2),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabItem('Registros', 3),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
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

  Widget _buildGeneralTab({Color textColor = Colors.white}) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Balance",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Legend
                Row(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDB462), // Yellow/Orange
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Gastos",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFFA6CE39), // Green
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Recargas",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Stacked Bar Chart
            SizedBox(
              height: 250,
              child: _buildStackedBarChart(textColor: textColor),
            ),

            const SizedBox(height: 32.0),

            // Monthly expenses chart
            Text(
              "Gastos durante cada mes",
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24.0),

            // Grouped Bar Chart
            SizedBox(
              height: 250,
              child: _buildGroupedBarChart(textColor: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodesTab(
      {Color textColor = Colors.white, bool isDark = true}) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Código QR section
            _buildCodigoQRSection(textColor: textColor, isDark: isDark),
            const SizedBox(height: 24.0),

            // Mis códigos section
            _buildMisCodigosSection(textColor: textColor, isDark: isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCodigoQRSection(
      {Color textColor = Colors.white, bool isDark = true}) {
    final cardColor = isDark ? Colors.grey[800] : Colors.grey[100];

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
              Navigator.of(context).pop(); // Close bottom sheet first
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

  Widget _buildMisCodigosSection(
      {Color textColor = Colors.white, bool isDark = true}) {
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
          textColor: textColor,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildCodigoItem(
          code: "1234567VBDFFJGRTH",
          date: "01-Mayo-2025",
          amount: "-\$ 15",
          type: "Débito",
          textColor: textColor,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildCodigoItem(
          code: "1234567VBDFFJGRTH",
          date: "01-Mayo-2025",
          amount: "-\$ 15",
          type: "Débito",
          textColor: textColor,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildCodigoItem(
          code: "1234567VBDFFJGRTH",
          date: "01-Mayo-2025",
          amount: "-\$ 15",
          type: "Débito",
          textColor: textColor,
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
    Color textColor = Colors.white,
    bool isDark = true,
  }) {
    final cardColor = isDark ? Colors.grey[800] : Colors.grey[100];

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

  Widget _buildGoalsTab({Color textColor = Colors.white}) {
    return Center(
      child: Text(
        "Viajes",
        style: TextStyle(color: textColor),
      ),
    );
  }

  Widget _buildOperacionesTab(
      {Color textColor = Colors.white, bool isDark = true}) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lista de transacciones
            _buildTransaccionItem(
              description: "1234567VBDFFJGRTH",
              date: "01-Mayo-2022",
              amount: "-\$ 15",
              type: "Débito",
              iconType: 'qr',
              textColor: textColor,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildTransaccionItem(
              description: "1234567VBDFFJGRTH",
              date: "01-Mayo-2022",
              amount: "-\$ 10",
              type: "Débito",
              iconType: 'bus',
              textColor: textColor,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildTransaccionItem(
              description: "1234567VBDFFJGRTH",
              date: "01-Mayo-2022",
              amount: "-\$ 20",
              type: "Débito",
              iconType: 'qr',
              textColor: textColor,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildTransaccionItem(
              description: "1234567VBDFFJGRTH",
              date: "01-Mayo-2022",
              amount: "\$ 100",
              type: "Recarga",
              iconType: 'recharge',
              textColor: textColor,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildTransaccionItem(
              description: "1234567VBDFFJGRTH",
              date: "01-Mayo-2022",
              amount: "-\$ 20",
              type: "Débito",
              iconType: 'bus',
              textColor: textColor,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildTransaccionItem(
              description: "1234567VBDFFJGRTH",
              date: "01-Mayo-2022",
              amount: "-\$ 20",
              type: "Débito",
              iconType: 'qr',
              textColor: textColor,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildTransaccionItem(
              description: "1234567VBDFFJGRTH",
              date: "01-Mayo-2022",
              amount: "\$ 100",
              type: "Recarga",
              iconType: 'recharge',
              textColor: textColor,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildTransaccionItem(
              description: "1234567VBDFFJGRTH",
              date: "01-Mayo-2022",
              amount: "-\$ 20",
              type: "Débito",
              iconType: 'bus',
              textColor: textColor,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransaccionItem({
    required String description,
    required String date,
    required String amount,
    required String type,
    required String iconType,
    Color textColor = Colors.white,
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

    final cardColor = isDark ? Colors.grey[800] : Colors.grey[100];

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

  Widget _buildStackedBarChart({Color textColor = Colors.white}) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: TextStyle(color: textColor),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: const MajorGridLines(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        labelStyle: TextStyle(color: textColor),
      ),
      series: <CartesianSeries>[
        StackedColumnSeries<MonthlyData, String>(
          dataSource: [
            MonthlyData('Ene', 45000, 80000),
            MonthlyData('Feb', 60000, 70000),
            MonthlyData('Mar', 55000, 75000),
            MonthlyData('Abr', 70000, 60000),
            MonthlyData('May', 65000, 85000),
            MonthlyData('Jun', 95000, 25000),
            MonthlyData('Jul', 50000, 70000),
            MonthlyData('Ago', 75000, 55000),
            MonthlyData('Sep', 60000, 80000),
          ],
          xValueMapper: (MonthlyData data, _) => data.month,
          yValueMapper: (MonthlyData data, _) => data.expenses,
          color: const Color(0xFFFDB462), // Yellow/Orange for Gastos
          name: 'Gastos',
        ),
        StackedColumnSeries<MonthlyData, String>(
          dataSource: [
            MonthlyData('Ene', 45000, 80000),
            MonthlyData('Feb', 60000, 70000),
            MonthlyData('Mar', 55000, 75000),
            MonthlyData('Abr', 70000, 60000),
            MonthlyData('May', 65000, 85000),
            MonthlyData('Jun', 95000, 25000),
            MonthlyData('Jul', 50000, 70000),
            MonthlyData('Ago', 75000, 55000),
            MonthlyData('Sep', 60000, 80000),
          ],
          xValueMapper: (MonthlyData data, _) => data.month,
          yValueMapper: (MonthlyData data, _) => data.recharges,
          color: const Color(0xFFA6CE39), // Green for Recargas
          name: 'Recargas',
        ),
      ],
    );
  }

  Widget _buildGroupedBarChart({Color textColor = Colors.white}) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: TextStyle(color: textColor),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: const MajorGridLines(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        labelStyle: TextStyle(color: textColor),
      ),
      series: <CartesianSeries>[
        ColumnSeries<ExpenseCategory, String>(
          dataSource: [
            ExpenseCategory('Ene', 45000, 35000, 25000),
            ExpenseCategory('Feb', 55000, 40000, 35000),
            ExpenseCategory('Mar', 38000, 42000, 30000),
          ],
          xValueMapper: (ExpenseCategory data, _) => data.month,
          yValueMapper: (ExpenseCategory data, _) => data.category1,
          color: const Color(0xFFA6CE39), // Green
          name: 'Category 1',
          width: 0.6,
        ),
        ColumnSeries<ExpenseCategory, String>(
          dataSource: [
            ExpenseCategory('Ene', 45000, 35000, 25000),
            ExpenseCategory('Feb', 55000, 40000, 35000),
            ExpenseCategory('Mar', 38000, 42000, 30000),
          ],
          xValueMapper: (ExpenseCategory data, _) => data.month,
          yValueMapper: (ExpenseCategory data, _) => data.category2,
          color: const Color(0xFF205AA8), // Blue
          name: 'Category 2',
          width: 0.6,
        ),
        ColumnSeries<ExpenseCategory, String>(
          dataSource: [
            ExpenseCategory('Ene', 45000, 35000, 25000),
            ExpenseCategory('Feb', 55000, 40000, 35000),
            ExpenseCategory('Mar', 38000, 42000, 30000),
          ],
          xValueMapper: (ExpenseCategory data, _) => data.month,
          yValueMapper: (ExpenseCategory data, _) => data.category3,
          color: const Color(0xFFFB8072), // Red/Pink
          name: 'Category 3',
          width: 0.6,
        ),
      ],
    );
  }
}

class MonthlyData {
  final String month;
  final double expenses;
  final double recharges;

  MonthlyData(this.month, this.expenses, this.recharges);
}

class ExpenseCategory {
  final String month;
  final double category1;
  final double category2;
  final double category3;

  ExpenseCategory(this.month, this.category1, this.category2, this.category3);
}
