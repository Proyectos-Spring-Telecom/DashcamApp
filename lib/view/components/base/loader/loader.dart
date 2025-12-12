import 'package:dashboardpro/dashboardpro.dart';

class LoaderScreen extends StatelessWidget {
  const LoaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
        title: AppBarTitle.loader,
        isSubMenu: true,
        mainMenu: AppBarTitle.base,
        body: bodyWidget(context: context)
    );
  }

  Widget bodyWidget({required BuildContext context}) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.padding),
      child: Card(
        child: ResponsiveGridList(
            shrinkWrap: true,
            scroll: false,
            desiredItemWidth: 100,
            minSpacing: 70,
            children: [
              SpinKitSquareCircle(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitRotatingCircle(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),

              SpinKitWave(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),

              SpinKitDoubleBounce(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),

              SpinKitWanderingCubes(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitFadingFour(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitFadingCube(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitPulse(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitChasingDots(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitThreeBounce(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitCircle(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitCubeGrid(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitFadingCircle(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),

              SpinKitFoldingCube(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitPumpingHeart(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitHourGlass(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitPouringHourGlass(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitPouringHourGlassRefined(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitFadingGrid(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitRing(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitRipple(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitSpinningCircle(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitSpinningLines(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitDualRing(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitPianoWave(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitDancingSquare(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
              SpinKitThreeInOut(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              )
            ]
        ),
      ),
    );
  }
}

