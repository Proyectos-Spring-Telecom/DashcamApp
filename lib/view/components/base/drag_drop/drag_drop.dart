import 'package:dashboardpro/dashboardpro.dart';

class DragDropScreen extends StatelessWidget {
  const DragDropScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
        title: AppBarTitle.dragDrop,
        isSubMenu: true,
        mainMenu: AppBarTitle.base,
        body: bodyWidget(context: context)
    );
  }

  Widget bodyWidget({required BuildContext context}) {
    return CustomCardWidgets(
        alignment: const Alignment(0, 0),
        child: Padding(
        padding: EdgeInsets.all(SizeConfig.padding * 2),
          child: const DragList(),
    ),
    );
  }
}
