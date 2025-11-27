import 'package:dashboardpro/dashboardpro.dart';

class BarPage extends StatelessWidget {
  const BarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400.0,
      width: 600.0,
      padding: const EdgeInsets.all(24.0),
      child: Chart(
        layers: layers(context),
        padding: const EdgeInsets.symmetric(horizontal: 12.0).copyWith(
          bottom: 12.0,
        ),
      ),
    );
  }

  List<ChartLayer> layers(context) {
    return [
      ChartAxisLayer(
        settings: ChartAxisSettings(
          x: ChartAxisSettingsAxis(
            frequency: 1.0,
            max: 13.0,
            min: 7.0,
            textStyle: Theme.of(context).textTheme.labelSmall!,
          ),
          y: ChartAxisSettingsAxis(
            frequency: 100.0,
            max: 300.0,
            min: 0.0,
            textStyle: Theme.of(context).textTheme.labelSmall!,
          ),
        ),
        labelX: (value) => value.toInt().toString(),
        labelY: (value) => value.toInt().toString(),
      ),
      ChartBarLayer(
        items: List.generate(
          13 - 7 + 1,
              (index) => ChartBarDataItem(
            color: const Color(0xFF8043F9),
            value: Random().nextInt(280) + 20,
            x: index.toDouble() + 7,
          ),
        ),
        settings: const ChartBarSettings(
          thickness: 8.0,
          radius: BorderRadius.all(Radius.circular(4.0)),
        ),
      ),
    ];
  }
}
