import 'package:dashboardpro/dashboardpro.dart';

class SidebarDrawer extends StatelessWidget {
  final String title;
  final bool isSubMenu;
  final String? mainMenu;
  const SidebarDrawer(
      {super.key,
      required this.title,
      required this.isSubMenu,
      this.mainMenu = ""});

  @override
  Widget build(BuildContext context) {

    TextStyle titleStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
      color: Theme.of(context).colorScheme.onSecondary,
    );

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0.0,
          centerTitle: false,
          title: GestureDetector(
              onTap: () => GoRouter.of(context).go(RoutesName.dashboard),
              child: Text("DashboardPro",style: TextStyle(color: Theme.of(context).colorScheme.onSecondary,),)),
        ),
        body: SafeArea(
          child: ListView(
            children: [
              const SizedBox(height: 10.0),
              ListTile(
                onTap:
                    activeDeactivateMenuOnTap(menuTitle: AppBarTitle.dashboard)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.dashboard),
                leading: Icon(Icons.dashboard, size: 18.0,color: Theme.of(context).colorScheme.onSecondary,),
                title: Text(AppBarTitle.dashboard,style: titleStyle),
                trailing: Container(
                  height: 20.0,
                  width: 45.0,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Center(
                    child: Text(
                      "NEW",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 11.0,
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                title: Text("COMPONENTS",style: titleStyle),
              ),
              ExpansionTile(
                initiallyExpanded:
                    expandListTileOnTap(mainMenuTitle: AppBarTitle.base),
                textColor: Theme.of(context).colorScheme.inversePrimary,
                iconColor: Theme.of(context).colorScheme.inversePrimary,
                collapsedTextColor: Theme.of(context).colorScheme.inversePrimary,
                collapsedIconColor: Theme.of(context).colorScheme.inversePrimary,
                leading: Icon(Icons.dashboard_customize_rounded, size: 18.0,color: Theme.of(context).colorScheme.onSecondary,),
                title: Text(AppBarTitle.base,style: titleStyle),
                children: <Widget>[
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.accordion,
                            mainMenuTitle: AppBarTitle.base)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.accordion),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.accordion
                        ,style: titleStyle
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.breadcrumb,
                            mainMenuTitle: AppBarTitle.base)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.breadcrumb),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.breadcrumb,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.cards,
                            mainMenuTitle: AppBarTitle.base)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.card),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.cards,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.loader,
                            mainMenuTitle: AppBarTitle.base)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.loader),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.loader,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.dragDrop,
                            mainMenuTitle: AppBarTitle.base)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.dragDrop),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.dragDrop,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.gallery,
                            mainMenuTitle: AppBarTitle.base)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.gallery),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.gallery,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.videoPlayer,
                            mainMenuTitle: AppBarTitle.base)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.videoPlayer),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.videoPlayer,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.tables,
                            mainMenuTitle: AppBarTitle.base)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.tables),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.tables,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.tooltips,
                            mainMenuTitle: AppBarTitle.base)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.tooltips),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.tooltips,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              ListTile(
                  onTap:
                      activeDeactivateMenuOnTap(menuTitle: AppBarTitle.buttons)
                          ? null
                          : () => GoRouter.of(context).go(RoutesName.buttons),
                  leading: Icon(Icons.radio_button_checked,
                      size: 18.0,color: Theme.of(context).colorScheme.onSecondary,),
                  title: Text(
                    AppBarTitle.buttons,
                      style: titleStyle
                  )),
              ListTile(
                  onTap: activeDeactivateMenuOnTap(menuTitle: AppBarTitle.forms)
                      ? null
                      : () => GoRouter.of(context).go(RoutesName.forms),
                  leading: Icon(Icons.newspaper,
                      size: 18.0,color: Theme.of(context).colorScheme.onSecondary,),
                  title: Text(
                    AppBarTitle.forms,
                    style: titleStyle
                  )),
              ExpansionTile(
                initiallyExpanded:
                    expandListTileOnTap(mainMenuTitle: AppBarTitle.icons),

                textColor: Theme.of(context).colorScheme.inversePrimary,
                iconColor: Theme.of(context).colorScheme.inversePrimary,
                collapsedTextColor: Theme.of(context).colorScheme.inversePrimary,
                collapsedIconColor: Theme.of(context).colorScheme.inversePrimary,
                leading: Icon(Icons.star, size: 18.0,color: Theme.of(context).colorScheme.onSecondary,),
                title: Text(AppBarTitle.icons,style: titleStyle),
                children: <Widget>[
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.flagIcon,
                            mainMenuTitle: AppBarTitle.icons)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.flagIcon),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.flagIcon,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.materialIcon,
                            mainMenuTitle: AppBarTitle.icons)
                        ? null
                        : () =>
                            GoRouter.of(context).go(RoutesName.materialIcon),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.materialIcon,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                initiallyExpanded: expandListTileOnTap(
                    mainMenuTitle: AppBarTitle.notifications),
                textColor: Theme.of(context).colorScheme.inversePrimary,
                iconColor: Theme.of(context).colorScheme.inversePrimary,
                collapsedTextColor: Theme.of(context).colorScheme.inversePrimary,
                collapsedIconColor: Theme.of(context).colorScheme.inversePrimary,
                leading: Icon(Icons.notifications, size: 18.0,color: Theme.of(context).colorScheme.onSecondary,),
                title: Text(AppBarTitle.notifications,style: titleStyle),
                children: <Widget>[
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.alert,
                            mainMenuTitle: AppBarTitle.notifications)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.alerts),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.alert,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.badge,
                            mainMenuTitle: AppBarTitle.notifications)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.badge),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.badge,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.toasts,
                            mainMenuTitle: AppBarTitle.notifications)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.toasts),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.toasts,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              ListTile(
                onTap: activeDeactivateMenuOnTap(menuTitle: AppBarTitle.widgets)
                    ? null
                    : () => GoRouter.of(context).go(RoutesName.widgets),
                leading: Icon(Icons.widgets,
                    size: 18.0,color: Theme.of(context).colorScheme.onSecondary,),
                title: Text(
                  AppBarTitle.widgets,
                  style: titleStyle
                ),
                trailing: Container(
                  height: 20.0,
                  width: 45.0,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Center(
                    child: Text(
                      "NEW",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 11.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              ListTile(
                title: Text("PLUGINS",style: titleStyle),
              ),
              const SizedBox(height: 10.0),
              ListTile(
                onTap:
                    activeDeactivateMenuOnTap(menuTitle: AppBarTitle.calendar)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.calender),
                leading: Icon(Icons.calendar_month ,
                    size: 18.0,color: Theme.of(context).colorScheme.onSecondary,),
                title: Text(
                  AppBarTitle.calendar,
                  style: titleStyle
                ),
                trailing: Container(
                  height: 20.0,
                  width: 45.0,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Center(
                    child: Text(
                      "PRO",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 11.0,
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                onTap: activeDeactivateMenuOnTap(menuTitle: AppBarTitle.charts)
                    ? null
                    : () => GoRouter.of(context).go(RoutesName.charts),
                leading: Icon(Icons.area_chart,
                    size: 18.0,color: Theme.of(context).colorScheme.onSecondary,),
                title: Text(
                  AppBarTitle.charts,
                  style: titleStyle
                ),
                trailing: Container(
                  height: 20.0,
                  width: 45.0,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Center(
                    child: Text(
                      "PRO",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 11.0,
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                onTap:
                    activeDeactivateMenuOnTap(menuTitle: AppBarTitle.dataTables)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.dataTables),
                leading: Icon(Icons.table_chart,
                    size: 18.0,color: Theme.of(context).colorScheme.onSecondary,),
                title: Text(
                  AppBarTitle.dataTables,
                  style: titleStyle
                ),
                trailing: Container(
                  height: 20.0,
                  width: 45.0,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Center(
                    child: Text(
                      "PRO",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 11.0,
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                onTap:
                    activeDeactivateMenuOnTap(menuTitle: AppBarTitle.googleMaps)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.googleMaps),
                leading: Icon(Icons.map,
                    size: 18.0,color: Theme.of(context).colorScheme.onSecondary,),
                title: Text(
                  AppBarTitle.googleMaps,
                  style: titleStyle
                ),
                trailing: Container(
                  height: 20.0,
                  width: 45.0,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Center(
                    child: Text(
                      "PRO",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 11.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              ListTile(
                title: Text("EXTRAS",style: titleStyle),
              ),
              const SizedBox(height: 10.0),
              ExpansionTile(
                initiallyExpanded: expandListTileOnTap(
                    mainMenuTitle: AppBarTitle.authentication),
                textColor: Theme.of(context).colorScheme.inversePrimary,
                iconColor: Theme.of(context).colorScheme.inversePrimary,
                collapsedTextColor: Theme.of(context).colorScheme.inversePrimary,
                collapsedIconColor: Theme.of(context).colorScheme.inversePrimary,
                leading: Icon(Icons.login, size: 18.0,color: Theme.of(context).colorScheme.onSecondary,),
                title: Text(AppBarTitle.authentication,style: titleStyle),
                children: <Widget>[
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.login,
                            mainMenuTitle: AppBarTitle.authentication)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.login),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.login,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.register,
                            mainMenuTitle: AppBarTitle.authentication)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.register),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.register,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.internalServerError,
                            mainMenuTitle: AppBarTitle.authentication)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.serverError),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.internalServerError,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.notFoundError,
                            mainMenuTitle: AppBarTitle.authentication)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.notFound),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.notFoundError,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.comingSoon,
                            mainMenuTitle: AppBarTitle.authentication)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.comingSoon),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.comingSoon,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.faq,
                            mainMenuTitle: AppBarTitle.authentication)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.faq),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.faq,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.maintenance,
                            mainMenuTitle: AppBarTitle.authentication)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.maintenance),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.maintenance,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.timeline,
                            mainMenuTitle: AppBarTitle.authentication)
                        ? null
                        : () =>
                            GoRouter.of(context).go(RoutesName.timelinePage),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.timeline,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.emailVerify,
                            mainMenuTitle: AppBarTitle.authentication)
                        ? null
                        : () => GoRouter.of(context).go(RoutesName.emailVerify),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.emailVerify,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: activeDeactivateSubMenuOnTap(
                            menuTitle: AppBarTitle.forgotPassword,
                            mainMenuTitle: AppBarTitle.authentication)
                        ? null
                        : () =>
                            GoRouter.of(context).go(RoutesName.forgotPassword),
                    leading: const SizedBox(),
                    title: Text(
                      AppBarTitle.forgotPassword,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              ListTile(
                leading: Icon(Icons.app_registration,
                    color: Theme.of(context).colorScheme.onSecondary, size: 18.0),
                title: Text(AppBarTitle.apps, style: titleStyle),
              ),
              ListTile(
                leading: Icon(Icons.insert_page_break_sharp,
                    color: Theme.of(context).colorScheme.onSecondary, size: 18.0),
                title: Text(AppBarTitle.docs, style: titleStyle),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }


  Color activeDeactivateSubMenu(
      {required String menuTitle, required String mainMenuTitle}) {
    if (title == menuTitle && mainMenu == mainMenuTitle) {
      return AppColors.white;
    } else {
      return AppColors.white.withOpacity(0.5);
    }
  }

  bool activeDeactivateMenuOnTap({required String menuTitle}) {
    if (title == menuTitle) {
      return true;
    } else {
      return false;
    }
  }

  bool activeDeactivateSubMenuOnTap(
      {required String menuTitle, required String mainMenuTitle}) {
    if (title == menuTitle && mainMenu == mainMenuTitle) {
      return true;
    } else {
      return false;
    }
  }

  bool expandListTileOnTap({required String mainMenuTitle}) {
    if (mainMenu == mainMenuTitle && isSubMenu) {
      return true;
    } else {
      return false;
    }
  }
}

class DrawerListTile extends StatelessWidget {
  final VoidCallback onTap;
  const DrawerListTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
    );
  }
}
