// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class CardFive extends StatelessWidget {
  const CardFive({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidgets(
      containerHeight: 220,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(SizeConfig.padding * 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: SizeConfig.spaceHeight / 3),
                  Text(
                    "Stumptown Roasters",
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: SizeConfig.spaceHeight / 1.5),
                  Text(
                    "5 Star | 98 reviews",
                    style: Theme.of(context).textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: SizeConfig.spaceHeight / 2),
                  Text(
                    "Before there was a United States of America, there were coffee houses, because how are you supposed to build.",
                    style: Theme.of(context).textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                  ),
                  SizedBox(height: SizeConfig.spaceHeight/2),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text("LOCATION"),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("REVIEWS"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Responsive.isDesktop(context)
              ? Expanded(
            flex: 1,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: SizedBox(
                  height: 140,
                  child: CachedNetworkImage(
                      filterQuality: FilterQuality.none,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      cacheKey:
                      Uri.parse(
                          "https://ik.imagekit.io/ua6mxoxdh/analog-clock.jpg")
                          .pathSegments
                          .last,
                      placeholder: (context, url) =>
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                            ),
                          ),
                      placeholderFadeInDuration: Duration
                          .zero,
                      errorWidget: (context, url,
                          errorWidget) =>
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                            ),
                          ),
                      imageBuilder:
                          (context, imageProvider) =>
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                              const BorderRadius.only(
                                topLeft:
                                Radius.circular(10.0),
                                topRight:
                                Radius.circular(10.0),
                              ),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                      imageUrl:
                      "https://ik.imagekit.io/ua6mxoxdh/analog-clock.jpg"),
                ),
              ),
            ),
          )
              : const SizedBox(),
        ],
      ),
    );
  }
}
