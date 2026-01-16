// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:intl/intl.dart';

class SalesArea extends StatefulWidget {
  const SalesArea({super.key});

  @override
  State<SalesArea> createState() => _SalesAreaState();
}

class _SalesAreaState extends State<SalesArea> {
  String _getCurrentDateTime() {
    final now = DateTime.now();
    return DateFormat('dd/MM/yyyy HH:mm').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.padding * 2, vertical: 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0),
            Flexible(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Sales",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    _getCurrentDateTime(),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            Flexible(flex: 3, child: _buildDefaultRadialBarChart()),
          ],
        ),
      ),
    );
  }

  /// Returns the circular chart with radial series.
  SfCircularChart _buildDefaultRadialBarChart() {
    return SfCircularChart(
      key: GlobalKey(),
      legend: const Legend(
          toggleSeriesVisibility: false,
          isVisible: true,
          iconHeight: 20,
          iconWidth: 20,
          overflowMode: LegendItemOverflowMode.scroll),
      series: _getRadialBarDefaultSeries(),
      tooltipBehavior:
          TooltipBehavior(enable: true, format: 'point.x : point.ym'),
    );
  }

  /// Returns default radial series.
  List<RadialBarSeries<ChartEntity, String>> _getRadialBarDefaultSeries() {
    return <RadialBarSeries<ChartEntity, String>>[
      RadialBarSeries<ChartEntity, String>(
          maximumValue: 18,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(fontSize: 10.0),
          ),
          dataSource: <ChartEntity>[
            ChartEntity(
              x: 'John',
              y: 10,
              text: '100%',
              pointColor: const Color.fromRGBO(248, 177, 149, 1.0),
            ),
            ChartEntity(
              x: 'Almaida',
              y: 11,
              text: '100%',
              pointColor: const Color.fromRGBO(246, 114, 128, 1.0),
            ),
            ChartEntity(
              x: 'Don',
              y: 12,
              text: '100%',
              pointColor: const Color.fromRGBO(61, 205, 171, 1.0),
            ),
            ChartEntity(
              x: 'Tom',
              y: 13,
              text: '100%',
              pointColor: const Color.fromRGBO(1, 174, 190, 1.0),
            ),
          ],
          cornerStyle: CornerStyle.bothCurve,
          gap: '10%',
          radius: '100%',
          xValueMapper: (ChartEntity data, _) => data.x as String,
          yValueMapper: (ChartEntity data, _) => data.y,
          pointRadiusMapper: (ChartEntity data, _) => data.text,
          pointColorMapper: (ChartEntity data, _) => data.pointColor,
          dataLabelMapper: (ChartEntity data, _) => data.x as String),
    ];
  }
}
