import 'package:dashboardpro/dashboardpro.dart';

class UserArea extends StatelessWidget {
  const UserArea({super.key});

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
                  "Users",
                ),
              ],
            ),
            Text(
              "458.34",
              style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "( +972.4% )",
            ),
          ],
        ),
      ),
    );
  }
}
