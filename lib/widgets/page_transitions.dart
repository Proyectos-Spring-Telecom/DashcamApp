import 'package:dashboardpro/dashboardpro.dart';

class NoTransitionsOnWeb extends PageTransitionsTheme {
  @override
  Widget buildTransitions<T>(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
      ) {
    return child;
  }
}