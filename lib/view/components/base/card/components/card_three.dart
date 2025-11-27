// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class CardThree extends StatelessWidget {
  const CardThree({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidgets(
      alignment: const Alignment(0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CachedNetworkImage(
              height: 210,
              width: MediaQuery.of(context).size.width,
              filterQuality: FilterQuality.none,
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              cacheKey: Uri.parse(
                  "https://ik.imagekit.io/ua6mxoxdh/paper-boat.png")
                  .pathSegments
                  .last,
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                ),
              ),
              placeholderFadeInDuration: Duration.zero,
              errorWidget: (context, url, errorWidget) =>
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                  ),
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              imageUrl:
              "https://ik.imagekit.io/ua6mxoxdh/paper-boat.png"),
          Padding(
            padding: EdgeInsets.all(SizeConfig.padding * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Popular Uses Of The Internet",
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: SizeConfig.spaceHeight / 2),
                Text(
                  "Although cards can support multiple actions, UI controls, and an overflow menu.",
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4,
                ),
                SizedBox(height: SizeConfig.spaceHeight / 2),
                ExpansionTileCard(
                  contentPadding: EdgeInsets.zero,
                  elevation: 0.0,
                   expandedColor: Colors.transparent,
                  baseColor: Colors.transparent,
                  finalPadding: EdgeInsets.zero,
                  animateTrailing: true,
                  borderRadius:
                  const BorderRadius.all(Radius.zero),
                  title: Text(
                    "DETAILS",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  children: [
                    const Divider(
                      thickness: 1.0,
                      height: 1.0,
                    ),
                    SizedBox(height: SizeConfig.spaceHeight / 2),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        """I′m a thing. But, like most politicians, he promised more than he could deliver. You won′t have time for sleeping, soldier, not with all the bed making you′ll be doing. Then we′ll go with that data file! Hey, you add a one and two zeros to that or we walk! You′re going to do his laundry? I′ve got to find a way to escape.""",
                        style: Theme.of(context).textTheme.labelMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 5,
                      ),
                    ),
                    SizedBox(height: SizeConfig.spaceHeight / 2),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
