// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class CardSeven extends StatelessWidget {
  const CardSeven({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidgets(
      alignment: const Alignment(0, 0),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.padding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: SizeConfig.padding,
            ),
            Text(
              "The Best Answers",
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: SizeConfig.padding * 2,
            ),
            Text(
              "5 Star | 98 reviews",
              style: Theme.of(context).textTheme.bodyLarge,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: SizeConfig.padding * 2,
            ),
            Text(
              """If you are looking for a new way to promote your business that won’t cost you more money, maybe printing is one of the options you won’t resist.

Printing is a widely use process in making printed materials that are used for advertising. It become fast, easy and simple.""",
              style: Theme.of(context).textTheme.labelLarge,
              overflow: TextOverflow.ellipsis,
              maxLines: 12,
            ),
            SizedBox(
              height: SizeConfig.padding * 3.3,
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text("LOCATION"),
                ),
                SizedBox(width: SizeConfig.spaceWidth,),
                TextButton(
                  onPressed: () {},
                  child: const Text("REVIEWS"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
