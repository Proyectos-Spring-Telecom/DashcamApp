// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class CardNine extends StatelessWidget {
  const CardNine({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidgets(
      containerColor: AppColors.cyan,
      alignment: const Alignment(0, 0),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.padding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Twitter Card",style: TextStyle(color: AppColors.white,fontSize: 20.0),),
            ),
            SizedBox(
              height: SizeConfig.padding,
            ),
            Text(
              """Turns out semicolon-less style is easier and safer in TS because most gotcha edge cases are type invalid as well.""",
              style: TextStyle(
                color: AppColors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 12,
            ),
            SizedBox(
              height: SizeConfig.padding * 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage: NetworkImage("https://ik.imagekit.io/ua6mxoxdh/4.png"),
                    ),
                    SizedBox(
                      width: SizeConfig.spaceWidth,
                    ),
                    Text("Trueuly Market",style: TextStyle(color: AppColors.white),),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.favorite,color: AppColors.white),
                    SizedBox(
                      width: SizeConfig.spaceWidth,
                    ),
                    Icon(Icons.share,color: AppColors.white),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
