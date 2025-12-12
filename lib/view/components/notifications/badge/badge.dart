import 'package:badges/badges.dart' as badges;

// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class Badge extends StatelessWidget {
  const Badge({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
      title: AppBarTitle.badge,
      isSubMenu: true,
      mainMenu: AppBarTitle.notifications,
      body: bodyWidget(context: context),
    );
  }

  Widget bodyWidget({required BuildContext context}) {
    return Column(
      children: [
        ResponsiveGridList(
            desiredItemWidth: 100,
            scroll: false,
            shrinkWrap: true,
            children: curveList.map((i) {
              return customBadge(curve: i);
            }).toList()),
        ResponsiveGridList(
            desiredItemWidth: 100,
            scroll: false,
            shrinkWrap: true,
            children: [
              Container(
                width: 100,
                height: 100,
                margin: EdgeInsets.symmetric(
                    horizontal: SizeConfig.padding,
                    vertical: SizeConfig.padding),
                child: Card(
                  child: Center(
                    child: badges.Badge(
                      position: badges.BadgePosition.topEnd(top: -10, end: -12),
                      badgeContent: Text("3",
                          style: TextStyle(color: AppColors.white, fontSize: 10)),
                      child: const Text(
                        "NEW",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),
                ),
              ),
              for (int i = 0; i < color.length; i++)
                customBadgeWithColor(color: color[i])
            ]),
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

  Widget customBadge({required Curve curve}) {
    return Container(
      width: 100,
      height: 100,
      margin: EdgeInsets.symmetric(
          horizontal: SizeConfig.padding, vertical: SizeConfig.padding),
      child: Card(
        child: Center(
          child: badges.Badge(
            badgeAnimation: badges.BadgeAnimation.rotation(
              animationDuration: const Duration(seconds: 2),
              colorChangeAnimationDuration: const Duration(seconds: 1),
              loopAnimation: true,
              curve: curve,
              colorChangeAnimationCurve: curve,
            ),
            position: badges.BadgePosition.topEnd(top: -10, end: -12),
            badgeContent:
                Text("3", style: TextStyle(color: AppColors.white, fontSize: 10)),
            child: const Icon(Icons.shopping_cart, size: 40.0),
          ),
        ),
      ),
    );
  }

  Widget customBadgeWithColor({required Color color}) {
    return Container(
      width: 100,
      height: 100,
      margin: EdgeInsets.symmetric(
          horizontal: SizeConfig.padding, vertical: SizeConfig.padding),
      child: Card(
        child: Center(
          child: badges.Badge(
            position: badges.BadgePosition.topEnd(top: -10, end: -12),
            child: Container(
              height: 30,
              width: 50,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3.0)),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Center(
                  child: Text(
                    "Badge",
                    style: TextStyle(fontSize: 10.0, color: color),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<Color> color = [
  AppColors.primary,
  AppColors.gray,
  AppColors.success,
  AppColors.danger,
  AppColors.warning,
  AppColors.info,
  AppColors.cyan,
];

const List<Curve> curveList = [
  Curves.linear,
  Curves.ease,
  Curves.decelerate,
  Curves.bounceIn,
  Curves.bounceInOut,
  Curves.easeIn,
  Curves.easeInBack,
  Curves.easeInCirc,
  Curves.easeInCubic,
  Curves.easeInOutCubicEmphasized,
  Curves.easeInOutExpo,
  Curves.easeInOutQuad,
  Curves.easeInOutQuart,
  Curves.easeInOutQuint,
  Curves.easeInOutSine,
  Curves.easeInQuad,
  Curves.easeInQuart,
  Curves.easeInQuint,
  Curves.easeInToLinear,
  Curves.bounceOut,
  Curves.easeOut,
  Curves.easeOutBack,
  Curves.easeOutCirc,
  Curves.easeOutCubic,
  Curves.easeInOutCubicEmphasized,
  Curves.easeInOutExpo,
  Curves.easeInOutQuad,
  Curves.easeInOutQuart,
  Curves.easeInOutQuint,
  Curves.easeInOutSine,
  Curves.easeOutQuad,
  Curves.easeOutQuart,
  Curves.easeOutQuint
];
