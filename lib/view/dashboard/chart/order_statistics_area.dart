// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class OrderListTile extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String trailingText;

  const OrderListTile({
    super.key,
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Center(
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18.0),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.labelSmall,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(trailingText),
    );
  }
}

class OrderStatisticsArea extends StatelessWidget {
  const OrderStatisticsArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: SizeConfig.padding + 5, horizontal: SizeConfig.padding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: const Text(
                  "Order Statistics",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "42.82k Total Sales",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                trailing: const Icon(Icons.more_vert_outlined),
              ),
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "9,258",
                              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              "Total Orders",
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildDefaultPieChart(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              OrderListTile(
                backgroundColor: AppColors.info,
                icon: Icons.mobile_screen_share,
                iconColor: AppColors.info,
                title: "Electronic",
                subtitle: "Mobile, Earbuds, TV",
                trailingText: "34.4k",
              ),
              OrderListTile(
                backgroundColor: AppColors.success,
                icon: Icons.people_alt_rounded,
                iconColor: AppColors.success,
                title: "Fashion",
                subtitle: "Tshirt, Jeans, Shoes",
                trailingText: "234k",
              ),
              OrderListTile(
                backgroundColor: AppColors.cyan,
                icon: Icons.bug_report,
                iconColor: AppColors.cyan,
                title: "Decor",
                subtitle: "Fine Art, Dining",
                trailingText: "546k",
              ),
              OrderListTile(
                backgroundColor: AppColors.gray,
                icon: Icons.bike_scooter,
                iconColor: AppColors.gray,
                title: "Sports",
                subtitle: "Football, Cricket Kit",
                trailingText: "344k",
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns the circular chart with pie series.
  SfCircularChart _buildDefaultPieChart() {
    return SfCircularChart(
      legend: const Legend(isVisible: false),
      series: _getDefaultPieSeries(),
    );
  }

  /// Returns the pie series.
  List<PieSeries<ChartEntity, String>> _getDefaultPieSeries() {
    return <PieSeries<ChartEntity, String>>[
      PieSeries<ChartEntity, String>(
        explode: true,
        explodeIndex: 0,
        explodeOffset: '10%',
        dataSource: <ChartEntity>[
          ChartEntity(x: 'Electronic', y: 13, text: 'David \n 13%'),
          ChartEntity(x: 'Fashion', y: 24, text: 'Steve \n 24%'),
          ChartEntity(x: 'Decor', y: 25, text: 'Jack \n 25%'),
          ChartEntity(x: 'Sports', y: 38, text: 'Others \n 38%'),
        ],
        xValueMapper: (ChartEntity data, _) => data.x,
        yValueMapper: (ChartEntity data, _) => data.y,
        dataLabelMapper: (ChartEntity data, _) => data.text,
        startAngle: 90,
        endAngle: 90,
        dataLabelSettings: const DataLabelSettings(isVisible: false),
      ),
    ];
  }
}
