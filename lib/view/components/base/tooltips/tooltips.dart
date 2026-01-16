import 'package:dashboardpro/dashboardpro.dart';

class TooltipsScreen extends StatelessWidget {
  const TooltipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
        title: AppBarTitle.tooltips,
        isSubMenu: true,
        mainMenu: AppBarTitle.base,
        body: bodyWidget(context: context)
    );
  }

  Widget bodyWidget({required BuildContext context}) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.padding),
      child: ResponsiveGridList(
          shrinkWrap: true,
          scroll: false,
          desiredItemWidth: 100,
          minSpacing: 10,
          children: [
            Tooltip(
              message: 'Simple tooltip',
              child: TextButton(
                child: const Text('Simple'),
                onPressed: () {},
              ),
            ),
            Tooltip(
              message: 'Custom tooltip',
              padding: const EdgeInsets.all(8),
              child: TextButton(
                child: const Text('Custom'),
                onPressed: () {},
              ),
            ),
            Tooltip(
              message: 'Tooltip with icon',
              child: IconButton(
                icon: const Icon(Icons.info),
                onPressed: () {},
              ),
            ),
            Tooltip(
              message: 'Interactive Tooltip with Action',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Action:'),
                  IconButton(
                    icon: Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.primary),
                    onPressed: () {
                      // Handle action button press
                    },
                  ),
                ],
              ),
            ),
          ]
      ),
    );
  }
}