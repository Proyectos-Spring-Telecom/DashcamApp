// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class CardEleven extends StatelessWidget {
  const CardEleven({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidgets(
      containerColor: AppColors.success,
      alignment: const Alignment(0, 0),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.padding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("LinkedIn Card",style: TextStyle(color: AppColors.white,fontSize: 20.0),),
            ),
            SizedBox(
              height: SizeConfig.padding,
            ),
            Text(
              """With the Internet spreading like wildfire and reaching every part of our daily life, more and more traffic is directed.""",
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
                      backgroundImage: NetworkImage("https://ik.imagekit.io/ua6mxoxdh/8.png"),
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
