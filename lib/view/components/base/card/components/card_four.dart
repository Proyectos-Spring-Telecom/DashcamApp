// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class CardFour extends StatelessWidget {
  const CardFour({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidgets(
      containerHeight: 220,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: SizedBox(
                height: 160,
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.padding),
                  child: CachedNetworkImage(
                      filterQuality: FilterQuality.none,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      cacheKey: Uri.parse(
                          "https://ik.imagekit.io/ua6mxoxdh/iPhone-11-pro.png")
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
                      imageBuilder: (context, imageProvider) =>
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0),
                              ),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                      imageUrl:
                      "https://ik.imagekit.io/ua6mxoxdh/iPhone-11-pro.png"),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(SizeConfig.padding * 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: SizeConfig.spaceHeight / 3),
                  Text(
                    "Apple iPhone 11 Pro",
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: SizeConfig.spaceHeight / 2),
                  Text(
                    "Apple iPhone 11 Pro smartphone. Announced Sep 2019. Features 5.8″ display Apple A13 Bionic",
                    style: Theme.of(context).textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                  ),
                  SizedBox(height: SizeConfig.spaceHeight / 1.5),
                  const Text(
                    "Price: \$899",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                  ),
                  SizedBox(height: SizeConfig.spaceHeight),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_shopping_cart_sharp),
                        label: const Text("ADD TO CART"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
