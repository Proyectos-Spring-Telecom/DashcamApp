// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class SessionsArea extends StatelessWidget {
  const SessionsArea({super.key});

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
                  "Session",
                ),
              ],
            ),
            Text(
              "55K",
              style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "( -72.4% )",
            ),
          ],
        ),
      ),
    );
  }
}
