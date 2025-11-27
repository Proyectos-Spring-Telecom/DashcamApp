// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class FadeTransitionPage extends CustomTransitionPage<void> {
  /// Creates a [FadeTransitionPage].
  FadeTransitionPage({
    required LocalKey super.key,
    required super.child,
  }) : super(
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              return FadeTransition(
                opacity: animation.drive(_curveTween),
                child: child,
              );
            });

  static final CurveTween _curveTween = CurveTween(curve: Curves.easeIn);
}
