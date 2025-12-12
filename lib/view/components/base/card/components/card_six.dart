// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class CardSix extends StatelessWidget {
  const CardSix({super.key});

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
              "Influencing The Influencer",
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: SizeConfig.padding * 2,
            ),
            Text(
              """Computers have become ubiquitous in almost every facet of our lives. At work, desk jockeys spend hours in front of their desktops, while delivery people scan bar codes with handhelds and workers in the field stay in touch.

If you’re in the market for new desktops, notebooks, or PDAs, there are a myriad of choices. Here’s a rundown of some of the best systems available.""",
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 12,
            ),
            SizedBox(
              height: SizeConfig.padding * 2,
            ),
            TextButton(
              onPressed: () {},
              child: const Text("READ MORE"),
            ),
          ],
        ),
      ),
    );
  }
}
