import 'package:dashboardpro/dashboardpro.dart';

class GroupBarPage extends StatelessWidget {
  const GroupBarPage({super.key});

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
            max: 12.0,
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
      ChartGroupBarLayer(
        items: List.generate(
          12 - 7 + 1,
              (index) => [
            ChartGroupBarDataItem(
              color: const Color(0xFF8043F9),
              x: index + 7,
              value: Random().nextInt(280) + 20,
            ),
            ChartGroupBarDataItem(
              color: const Color(0xFFFF4150),
              x: index + 7,
              value: Random().nextInt(280) + 20,
            ),
          ],
        ),
        settings: const ChartGroupBarSettings(
          thickness: 8.0,
          radius: BorderRadius.all(Radius.circular(4.0)),
        ),
      ),
      ChartTooltipLayer(
        shape: () => ChartTooltipBarShape<ChartGroupBarDataItem>(
          backgroundColor: AppColors.danger,
          currentPos: (item) => item.currentValuePos,
          currentSize: (item) => item.currentValueSize,
          onTextValue: (item) => '€${item.value.toString()}',
          marginBottom: 6.0,
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 8.0,
          ),
          radius: 6.0,
          textStyle: const TextStyle(
            color: Color(0xFF8043F9),
            letterSpacing: 0.2,
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ];
  }
}
