// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class CardOne extends StatelessWidget {
  const CardOne({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidgets(
      containerHeight: 390,
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedNetworkImage(
            height: 235,
            width: MediaQuery.of(context).size.width,
            filterQuality: FilterQuality.none,
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
            cacheKey: "glass-house.png",
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
            ),
            placeholderFadeInDuration: Duration.zero,
            errorWidget: (context, url, errorWidget) => Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
            ),
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            imageUrl: "https://ik.imagekit.io/ua6mxoxdh/glass-house.png",
          ),
          Padding(
            padding: EdgeInsets.all(SizeConfig.padding * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Influencing The Influencer",
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: SizeConfig.spaceHeight / 2),
                Text(
                  "Cancun is back, better than ever! Over a hundred Mexico resorts have reopened and the state tourism minister predicts Cancun will draw as many visitors in 2006 as it did two years ago.",
                  style:Theme.of(context).textTheme.labelSmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
