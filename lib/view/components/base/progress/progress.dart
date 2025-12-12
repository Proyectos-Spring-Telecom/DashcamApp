import 'package:dashboardpro/dashboardpro.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
        title: AppBarTitle.progress,
        isSubMenu: true,
        mainMenu: AppBarTitle.base,
        body: bodyWidget(context: context));
  }

  Widget bodyWidget({required BuildContext context}) {
    return const Placeholder();
  }
}


