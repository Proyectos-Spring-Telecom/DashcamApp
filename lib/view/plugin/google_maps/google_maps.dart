import 'package:dashboardpro/dashboardpro.dart';

class GoogleMap extends StatelessWidget {
  const GoogleMap({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
      title: AppBarTitle.googleMaps,
      isSubMenu: false,
      body: bodyWidget(context: context),
    );
  }

  Widget bodyWidget({required BuildContext context}) {
    return Column(
      children: [
        ResponsiveGridRow(
          children: [
            ResponsiveGridCol(
              sm: 12,
              lg: 12,
              md: 12,
              xl: 12,
              child: const Card(child : WorldMap()),
            ),
          ],
        ),
        SizedBox(height: SizeConfig.spaceHeight * 2),
        Responsive.isDesktop(context)
            ? const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("© 2023, Made with ❤️  by TGI"),
            Row(
              children: [
                Text("License"),
                SizedBox(width: 10.0),
                Text("Support"),
                SizedBox(width: 10.0),
                Text("Documentation"),
                SizedBox(width: 60.0)
              ],
            ),
          ],
        )
            : const SizedBox(),
      ],
    );
  }
}
