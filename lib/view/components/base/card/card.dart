// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class CardScreen extends StatelessWidget {
  const CardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
      title: AppBarTitle.cards,
      isSubMenu: true,
      mainMenu: AppBarTitle.base,
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
              md: 6,
              xl: 4,
              child: const CardOne(),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 6,
              md: 6,
              xl: 4,
              child: const CardTwo(),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 6,
              md: 6,
              xl: 4,
              child: const CardThree(),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 12,
              md: 12,
              xl: 6,
              child: const CardFour(),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 12,
              md: 12,
              xl: 6,
              child: const CardFive(),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 6,
              md: 6,
              xl: 4,
              child: const CardSix(),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 6,
              md: 6,
              xl: 4,
              child: const CardSeven(),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 6,
              md: 6,
              xl: 4,
              child: const CardEight(),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 6,
              md: 6,
              xl: 4,
              child: const CardNine(),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 6,
              md: 6,
              xl: 4,
              child: const CardTen(),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 6,
              md: 6,
              xl: 4,
              child: const CardEleven(),
            ),
          ],
        ),
        SizedBox(height: SizeConfig.spaceHeight * 2),
        Responsive.isDesktop(context) ? const Row(
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
            )
          ],
        ) : const SizedBox()
      ],
    );
  }
}
