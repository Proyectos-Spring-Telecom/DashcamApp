import 'package:dashboardpro/dashboardpro.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
      title: AppBarTitle.gallery,
      isSubMenu: true,
      mainMenu: AppBarTitle.base,
      body: bodyWidget(context: context),
    );
  }

  Widget bodyWidget({required BuildContext context}) {
    return ResponsiveGridList(
        shrinkWrap: true,
        scroll: true,
        physics: const ScrollPhysics(),
        desiredItemWidth: 200,
        minSpacing: 10,
        children: [
          'https://picsum.photos/300/300?random=1',
          'https://picsum.photos/300/300?random=2',
          'https://picsum.photos/300/300?random=3',
          'https://picsum.photos/300/300?random=4',
          'https://picsum.photos/300/300?random=5',
          'https://picsum.photos/300/300?random=6',
          'https://picsum.photos/300/300?random=7',
          'https://picsum.photos/300/300?random=8',
          'https://picsum.photos/300/300?random=9',
          'https://picsum.photos/300/300?random=10',
          'https://picsum.photos/300/300?random=11',
          'https://picsum.photos/300/300?random=12',
          'https://picsum.photos/300/300?random=13',
          'https://picsum.photos/300/300?random=14',
          'https://picsum.photos/300/300?random=15',
          'https://picsum.photos/300/300?random=16',
          'https://picsum.photos/300/300?random=17',
          'https://picsum.photos/300/300?random=18',
          'https://picsum.photos/300/300?random=19',
          'https://picsum.photos/300/300?random=20'
        ].map((i) {
          return CustomCardWidgets(
            alignment: const Alignment(0, 0),
            child: Padding(
              padding: EdgeInsets.all(SizeConfig.padding * 2),
              child: Image.network(i),
            ),
          );
        }).toList());
  }
}
