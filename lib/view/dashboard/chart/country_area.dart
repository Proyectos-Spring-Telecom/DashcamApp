// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class CountryArea extends StatelessWidget {
  const CountryArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.padding + 5, vertical: 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 140,
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
                            "785.6K",
                            style: TextStyle(
                                fontSize: 25.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            "Country",
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
          ],
        ),
      ),
    );
  }

  /// Returns the circular  chart with pie series.
  SfCircularChart _buildDefaultPieChart() {
    return SfCircularChart(
      legend: const Legend(isVisible: false),
      series: _getDefaultPieSeries(),
      tooltipBehavior: TooltipBehavior(enable: true),
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
          ChartEntity(x: 'India', y: 13, text: 'David \n 13%'),
          ChartEntity(x: 'Australia', y: 24, text: 'Steve \n 24%'),
          ChartEntity(x: 'London', y: 25, text: 'Jack \n 25%'),
          ChartEntity(x: 'Canada', y: 38, text: 'Others \n 38%'),
        ],
        xValueMapper: (ChartEntity data, _) => data.x as String,
        yValueMapper: (ChartEntity data, _) => data.y,
        dataLabelMapper: (ChartEntity data, _) => data.text,
        startAngle: 90,
        endAngle: 90,
        dataLabelSettings: const DataLabelSettings(isVisible: false),
      ),
    ];
  }
}
