// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class BreadcrumbScreen extends StatelessWidget {
  const BreadcrumbScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
      title: AppBarTitle.breadcrumb,
      isSubMenu: true,
      mainMenu: AppBarTitle.base,
      body: bodyWidget(context: context)
    );
  }

  Widget bodyWidget({required BuildContext context}) {
    return Column(
      children: [
        SizedBox(height: SizeConfig.spaceHeight),
        Card(
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.padding * 2),
            child: BreadcrumbOne(
              items: const ['Home', 'Products', 'Product Detail'],
              textColor: AppColors.gray.withOpacity(0.5),
              activeTextColor: Theme.of(context).colorScheme.primary,
              separatorColor: AppColors.gray,
              fontSize: 18,
              fontWeight: FontWeight.normal,
              onItemTap: (int index) {
                // print
              },
            ),
          ),
        ),
        SizedBox(height: SizeConfig.spaceHeight),
        Card(
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.padding * 2),
            child: BreadcrumbTwo(
              items: const ['Home', 'Products', 'Product Detail',],
              textColor: AppColors.gray.withOpacity(0.5),
              activeTextColor: Theme.of(context).colorScheme.primary,
              separatorColor: AppColors.gray,
              fontSize: 16,
              fontWeight: FontWeight.normal,
              onItemTap: (int index) {
                // print
              },
            )
          ),
        ),
        SizedBox(height: SizeConfig.spaceHeight),
        Card(
          child: Padding(
              padding: EdgeInsets.all(SizeConfig.padding * 2),
              child: BreadcrumbThree(
                items: const ['Home', 'Products', 'Product Detail',],
                textColor: AppColors.gray.withOpacity(0.5),
                activeTextColor: Theme.of(context).colorScheme.primary,
                separatorColor: AppColors.gray,
                fontSize: 16,
                fontWeight: FontWeight.normal,
                onItemTap: (int index) {},
              )
          ),
        ),
      ],
    );
  }
}
