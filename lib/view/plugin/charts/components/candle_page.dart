import 'package:intl/intl.dart';

// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class CustomCandleScreen extends StatefulWidget {
  const CustomCandleScreen({super.key});

  @override
  State<CustomCandleScreen> createState() => _CustomCandleScreenState();
}

class _CustomCandleScreenState extends State<CustomCandleScreen> {

  bool _whichCandleMock = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400.0,
      width: 600.0,
      padding: const EdgeInsets.all(24.0),
      child: Chart(
        layers: layers(),
        padding: const EdgeInsets.symmetric(horizontal: 12.0).copyWith(
          bottom: 12.0,
        ),
      ),
    );
  }

  List<ChartLayer> layers() {
    _whichCandleMock = !_whichCandleMock;
    final double frequency =
        (DateTime(2017, 11).millisecondsSinceEpoch.toDouble() -
            DateTime(2017, 4).millisecondsSinceEpoch.toDouble()) /
            4;
    final double frequencyData = frequency / 3;
    final double from = DateTime(2017, 4).millisecondsSinceEpoch.toDouble();
    return [
      ChartGridLayer(
        settings: ChartGridSettings(
          x: ChartGridSettingsAxis(
            color: AppColors.black.withOpacity(0.2),
            frequency: frequency,
            max: DateTime(2017, 11).millisecondsSinceEpoch.toDouble(),
            min: DateTime(2017, 4).millisecondsSinceEpoch.toDouble(),
          ),
          y: ChartGridSettingsAxis(
            color: AppColors.black.withOpacity(0.2),
            frequency: 3.0,
            max: 66.0,
            min: 48.0,
          ),
        ),
      ),
      ChartAxisLayer(
        settings: ChartAxisSettings(
          x: ChartAxisSettingsAxis(
            frequency: frequency,
            max: DateTime(2017, 11).millisecondsSinceEpoch.toDouble(),
            min: DateTime(2017, 4).millisecondsSinceEpoch.toDouble(),
            textStyle: Theme.of(context).textTheme.labelSmall!,
          ),
          y: ChartAxisSettingsAxis(
            frequency: 3.0,
            max: 66.0,
            min: 48.0,
            textStyle: Theme.of(context).textTheme.labelSmall!,
          ),
        ),
        labelX: (value) => DateFormat('MMM yyyy')
            .format(DateTime.fromMillisecondsSinceEpoch(value.toInt())),
        labelY: (value) => value.toInt().toString(),
      ),
      ChartCandleLayer(
        items: _whichCandleMock
            ? [
          _candleItem(Colors.green, 50.0, 52.0, 48.0, 53.0, from),
          _candleItem(
              Colors.red, 52.0, 54.0, 51.0, 57.0, from + frequencyData),
          _candleItem(Colors.red, 53.0, 56.0, 53.0, 56.0,
              from + 2 * frequencyData),
          _candleItem(Colors.green, 54.0, 56.0, 53.0, 58.0,
              from + 3 * frequencyData),
          _candleItem(Colors.green, 55.0, 57.0, 53.0, 58.0,
              from + 4 * frequencyData),
          _candleItem(Colors.green, 56.0, 58.0, 56.0, 58.0,
              from + 5 * frequencyData),
          _candleItem(Colors.red, 58.0, 60.0, 57.0, 61.0,
              from + 6 * frequencyData),
          _candleItem(Colors.green, 57.5, 59.0, 56.5, 60.3,
              from + 7 * frequencyData),
          _candleItem(Colors.green, 57.0, 59.0, 57.0, 60.0,
              from + 8 * frequencyData),
          _candleItem(Colors.red, 60.0, 62.0, 57.0, 61.0,
              from + 9 * frequencyData),
          _candleItem(Colors.green, 63.0, 65.0, 62.0, 66.0,
              from + 10 * frequencyData),
          _candleItem(Colors.green, 64.0, 66.0, 63.0, 66.0,
              from + 11 * frequencyData),
          _candleItem(Colors.red, 62.0, 64.0, 61.0, 64.0,
              from + 12 * frequencyData),
        ]
            : [
          _candleItem(Colors.red, 62.0, 64.0, 61.0, 64.0, from),
          _candleItem(
              Colors.green, 64.0, 66.0, 63.0, 66.0, from + frequencyData),
          _candleItem(Colors.green, 63.0, 65.0, 62.0, 66.0,
              from + 2 * frequencyData),
          _candleItem(Colors.red, 60.0, 62.0, 57.0, 61.0,
              from + 3 * frequencyData),
          _candleItem(Colors.green, 57.0, 59.0, 57.0, 60.0,
              from + 4 * frequencyData),
          _candleItem(Colors.green, 57.5, 59.0, 56.5, 60.3,
              from + 5 * frequencyData),
          _candleItem(Colors.red, 58.0, 60.0, 57.0, 61.0,
              from + 6 * frequencyData),
          _candleItem(Colors.green, 56.0, 58.0, 56.0, 58.0,
              from + 7 * frequencyData),
          _candleItem(Colors.green, 55.0, 57.0, 53.0, 58.0,
              from + 8 * frequencyData),
          _candleItem(Colors.green, 54.0, 56.0, 53.0, 58.0,
              from + 9 * frequencyData),
          _candleItem(Colors.red, 53.0, 56.0, 53.0, 56.0,
              from + 10 * frequencyData),
          _candleItem(Colors.red, 52.0, 54.0, 51.0, 57.0,
              from + 11 * frequencyData),
          _candleItem(Colors.green, 50.0, 52.0, 48.0, 53.0,
              from + 12 * frequencyData),
        ],
        settings: const ChartCandleSettings(),
      ),
    ];
  }

  static _candleItem(Color color, double min1, double max1, double min2,
      double max2, double x) {
    return ChartCandleDataItem(
      color: color,
      value1: ChartCandleDataItemValue(
        max: max1,
        min: min1,
      ),
      value2: ChartCandleDataItemValue(
        max: max2,
        min: min2,
      ),
      x: x,
    );
  }
}
