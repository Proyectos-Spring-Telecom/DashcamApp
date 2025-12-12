import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'custom_card_widgets.dart';

class CardTwo extends StatelessWidget {
  const CardTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidgets(
      containerHeight: 390,
      alignment: const Alignment(0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(alignment: Alignment.bottomLeft, children: [
            CachedNetworkImage(
              height: 225,
              width: MediaQuery.of(context).size.width,
              filterQuality: FilterQuality.none,
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              cacheKey: Uri.parse(
                  "https://ik.imagekit.io/ua6mxoxdh/background-user.png")
                  .pathSegments
                  .last,
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
                margin: const EdgeInsets.only(bottom: 35),
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
              "https://ik.imagekit.io/ua6mxoxdh/background-user.png",
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15.0, bottom: 10.0),
              child: CircleAvatar(
                radius: 40.0,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 36.0,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(
                      'https://ik.imagekit.io/ua6mxoxdh/1.png'),
                ),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.all(15.0), // Adjust padding as needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Trueuly Market",
                          style: Theme.of(context).textTheme.titleLarge, // Assuming AppColors is defined
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          "London, Uk",
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                        ),
                      ],
                    ),
                    FilledButton(
                      onPressed:() {},
                      child: const Text('Follow'),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  "18 mutual friends",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 8.0),
                Text(
                  "trueuly market, john..",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
