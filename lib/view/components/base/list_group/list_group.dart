import 'package:dashboardpro/dashboardpro.dart';

class ListGroupScreen extends StatelessWidget {
  const ListGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
        title: AppBarTitle.listGroup,
        isSubMenu: true,
        mainMenu: AppBarTitle.base,
        body: bodyWidget(context: context)
    );
  }

  Widget bodyWidget({required BuildContext context}) {
    return const Placeholder();
  }
}
