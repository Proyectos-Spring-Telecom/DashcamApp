// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:intl/intl.dart';

class SplineArea extends StatefulWidget {
  const SplineArea({super.key});

  @override
  State<SplineArea> createState() => _SplineAreaState();
}

class _SplineAreaState extends State<SplineArea> {
  String _getCurrentDateTime() {
    final now = DateTime.now();
    return DateFormat('dd/MM/yyyy HH:mm').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.padding * 2,
                vertical: SizeConfig.padding * 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ventas",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      _getCurrentDateTime(),
                      style: Theme.of(context).textTheme.labelSmall,
                    )
                  ],
                ),
                Text(
                  "\$223.200",
                  style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
          Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: _buildSplineAreaChart(context),
            ),
          ),
        ],
      ),
    );
  }

  SfCartesianChart _buildSplineAreaChart(context) {
    return SfCartesianChart(
      margin: EdgeInsets.zero,
      legend: const Legend(isVisible: false, opacity: 0.7),
      plotAreaBorderWidth: 0,
      primaryXAxis: const NumericAxis(
          isVisible: false,
          interval: 1,
          majorGridLines: MajorGridLines(width: 0),
          edgeLabelPlacement: EdgeLabelPlacement.shift),
      primaryYAxis: const NumericAxis(
        isVisible: false,
        labelFormat: '{value}%',
        axisLine: AxisLine(width: 0),
        majorTickLines: MajorTickLines(size: 0),
      ),
      series: _getSplineAreaSeries(context),
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  /// Returns the list of chart series
  /// which need to render on the spline area chart.
  List<CartesianSeries<_SplineAreaData, double>> _getSplineAreaSeries(context) {
    return <CartesianSeries<_SplineAreaData, double>>[
      SplineAreaSeries<_SplineAreaData, double>(
        dataSource: <_SplineAreaData>[
          _SplineAreaData(2010, 5.53, 3.3),
          _SplineAreaData(2011, 4.5, 5.4),
          _SplineAreaData(2012, 4, 2.65),
          _SplineAreaData(2016, 3.5, 2),
          _SplineAreaData(2017, 3.6, 1.56),
          _SplineAreaData(2018, 3.43, 2.1),
        ],
        color: Theme.of(context).colorScheme.inversePrimary,
        borderColor: Theme.of(context).colorScheme.primary,
        borderWidth: 4,
        name: 'India',
        xValueMapper: (_SplineAreaData sales, _) => sales.year,
        yValueMapper: (_SplineAreaData sales, _) => sales.y1,
      ),
    ];
  }
}

/// Private class for storing the spline area chart datapoints.
class _SplineAreaData {
  _SplineAreaData(this.year, this.y1, this.y2);
  final double year;
  final double y1;
  final double y2;
}
