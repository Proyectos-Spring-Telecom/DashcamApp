// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class CardTen extends StatelessWidget {
  const CardTen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidgets(
      containerColor: AppColors.info,
      alignment: const Alignment(0, 0),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.padding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Facebook Card",style: TextStyle(color: AppColors.white,fontSize: 20.0),),
            ),
            SizedBox(
              height: SizeConfig.padding,
            ),
            Text(
              """You’ve read about the importance of being courageous, rebellious and imaginative. These are all vital ingredients in an effective.""",
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
                      backgroundImage: NetworkImage("https://ik.imagekit.io/ua6mxoxdh/1.png"),
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
