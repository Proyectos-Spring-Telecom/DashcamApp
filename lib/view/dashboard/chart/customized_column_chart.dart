// Project imports:
import 'package:dashboardpro/dashboardpro.dart';
import 'package:intl/intl.dart';

class ColumnVertical extends StatefulWidget {
  const ColumnVertical({super.key});

  @override
  State<ColumnVertical> createState() => _ColumnVerticalState();
}

class _ColumnVerticalState extends State<ColumnVertical> {
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
          children:  [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Revenue",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                const SizedBox(height: 10.0),
                Text(
                  _getCurrentDateTime(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            _buildCustomizedColumnChart(),
          ],
        ),
      ),
    );
  }

  /// Get customized column chart
  SfCartesianChart _buildCustomizedColumnChart() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: const CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        labelFormat: '{value}M',
        majorGridLines: MajorGridLines(width: 0),
        majorTickLines: MajorTickLines(size: 0),
      ),
      series: <CartesianSeries<ChartEntity, String>>[
        ColumnSeries<ChartEntity, String>(
          onCreateRenderer: (ChartSeries<ChartEntity, String> series) {
            return _CustomColumnSeriesRenderer();
          },
          dataLabelSettings: const DataLabelSettings(
              isVisible: true, labelAlignment: ChartDataLabelAlignment.middle),
          dataSource: <ChartEntity>[
            ChartEntity(
                x: 'HP Inc',
                y: 12.54,
                pointColor: const Color.fromARGB(53, 92, 125, 1)),
            ChartEntity(
                x: 'Lenovo',
                y: 13.46,
                pointColor: const Color.fromARGB(192, 108, 132, 1)),
            ChartEntity(
                x: 'Dell',
                y: 9.18,
                pointColor: const Color.fromARGB(246, 114, 128, 1)),
            ChartEntity(
                x: 'Apple',
                y: 4.56,
                pointColor: const Color.fromARGB(248, 177, 149, 1)),
            ChartEntity(
                x: 'Asus',
                y: 5.29,
                pointColor: const Color.fromARGB(116, 180, 155, 1)),
          ],
          width: 0.8,
          xValueMapper: (ChartEntity sales, _) => sales.x as String,
          yValueMapper: (ChartEntity sales, _) => sales.y,
          pointColorMapper: (ChartEntity sales, _) => sales.pointColor,
        )
      ],
      tooltipBehavior: TooltipBehavior(enable: true, canShowMarker: false, header: ''),
    );
  }

}

class _CustomColumnSeriesRenderer<T, D> extends ColumnSeriesRenderer<T, D> {
  _CustomColumnSeriesRenderer();


  @override
  ColumnSegment<T, D> createSegment() {
    return _ColumnCustomPainter();
  }
}

class _ColumnCustomPainter<T, D> extends ColumnSegment<T, D> {
  _ColumnCustomPainter();

  List<Color> colorList = <Color>[
    const Color.fromRGBO(53, 92, 125, 1),
    const Color.fromRGBO(192, 108, 132, 1),
    const Color.fromRGBO(246, 114, 128, 1),
    const Color.fromRGBO(248, 177, 149, 1),
    const Color.fromRGBO(116, 180, 155, 1)
  ];
  List<Color> colorListM3Light = const [
    Color.fromRGBO(6, 174, 224, 1),
    Color.fromRGBO(99, 85, 199, 1),
    Color.fromRGBO(49, 90, 116, 1),
    Color.fromRGBO(255, 180, 0, 1),
    Color.fromRGBO(150, 60, 112, 1)
  ];
  List<Color> colorListM3Dark = const [
    Color.fromRGBO(255, 245, 0, 1),
    Color.fromRGBO(51, 182, 119, 1),
    Color.fromRGBO(218, 150, 70, 1),
    Color.fromRGBO(201, 88, 142, 1),
    Color.fromRGBO(77, 170, 255, 1),
  ];

  @override
  Paint getFillPaint() {
    final Paint customerFillPaint = Paint();

    customerFillPaint.isAntiAlias = false;
    customerFillPaint.color = colorList[currentSegmentIndex];
    customerFillPaint.style = PaintingStyle.fill;
    return customerFillPaint;
  }

  @override
  Paint getStrokePaint() {
    final Paint customerStrokePaint = Paint();
    customerStrokePaint.isAntiAlias = false;
    customerStrokePaint.color = Colors.transparent;
    customerStrokePaint.style = PaintingStyle.stroke;
    return customerStrokePaint;
  }

  @override
  void onPaint(Canvas canvas) {
    if (segmentRect != null) {
      double x, y;
      x = segmentRect!.center.dx;
      y = segmentRect!.top;
      double width = 0;
      const double height = 20;
      width = segmentRect!.width;
      final Paint paint = Paint();
      paint.color = getFillPaint().color;
      paint.style = PaintingStyle.fill;
      final Path path = Path();
      final double factor = segmentRect!.height * (1 - animationFactor);
      path.moveTo(x - width / 2, y + factor + height);
      path.lineTo(x, (segmentRect!.top + factor + height) - height);
      path.lineTo(x + width / 2, y + factor + height);
      path.lineTo(x + width / 2, segmentRect!.bottom + factor);
      path.lineTo(x - width / 2, segmentRect!.bottom + factor);
      path.close();
      canvas.drawPath(path, paint);
    }
  }
}