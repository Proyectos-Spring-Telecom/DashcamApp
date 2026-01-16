import 'package:dashboardpro/dashboardpro.dart';

class PopoversScreen extends StatelessWidget {
  const PopoversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
        title: AppBarTitle.popovers,
        isSubMenu: true,
        mainMenu: AppBarTitle.base,
        body: bodyWidget(context: context)
    );
  }

  Widget bodyWidget({required BuildContext context}) {
    return const Placeholder();
  }
}
