// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class ConversionRateArea extends StatelessWidget {
  const ConversionRateArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.padding + 5, vertical: SizeConfig.padding),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Conversion Rate",
                ),
              ],
            ),
            Text(
              "2.34%",
              style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "( +84.8% )",
            ),
          ],
        ),
      ),
    );
  }
}
