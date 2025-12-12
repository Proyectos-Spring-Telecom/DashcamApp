// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class CardEight extends StatelessWidget {
  const CardEight({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidgets(
      alignment: const Alignment(0, 0),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.padding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: SizeConfig.padding,
            ),
            CircleAvatar(
              backgroundColor: AppColors.info.withOpacity(0.3),
              child: Icon(Icons.support,color: AppColors.info,),
            ),
            SizedBox(
              height: SizeConfig.padding * 2,
            ),
            Text(
              "Support",
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: SizeConfig.padding * 2,
            ),
            Text(
              """According to us blisters are a very common thing and we come across them very often in our daily lives. It is a very common occurrence like cold or fever depending upon your lifestyle.""",
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 12,
            ),
            SizedBox(
              height: SizeConfig.padding * 4,
            ),
            FilledButton(
              onPressed: () {},
              child: const Text('CONTACT NOW'),
            ),
          ],
        ),
      ),
    );
  }
}
