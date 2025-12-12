import 'package:dashboardpro/dashboardpro.dart';

class Charts extends StatelessWidget {
  const Charts({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
      title: AppBarTitle.charts,
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
              lg: 6,
              md: 12,
              xl: 6,
              child:const Card(child: BarPage())
            ),
            ResponsiveGridCol(
                sm: 12,
                lg: 6,
                md: 12,
                xl: 6,
                child:const Card(child: CustomCandleScreen())
            ),
            ResponsiveGridCol(
                sm: 12,
                lg: 6,
                md: 12,
                xl: 6,
                child:const Card(child: GroupBarPage())
            ),
            ResponsiveGridCol(
                sm: 12,
                lg: 6,
                md: 12,
                xl: 6,
                child: const Card(child: LinePage())
            ),
            ResponsiveGridCol(
                sm: 12,
                lg: 6,
                md: 12,
                xl: 6,
                child:const Card(child: PiePage())
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
