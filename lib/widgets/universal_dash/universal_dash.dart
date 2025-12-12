import 'package:badges/badges.dart' as badges;

// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class UniversalDash extends StatelessWidget {
  final Widget body;
  final String title;
  final bool isSubMenu;
  final String? mainMenu;
  const UniversalDash(
      {super.key,
      required this.body,
      required this.title,
      required this.isSubMenu,
      this.mainMenu});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: mobileView(),
      tablet: tabView(),
      desktop: desktopView(),
    );
  }

  Widget mobileView() {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer:
          SidebarDrawer(title: title, isSubMenu: isSubMenu, mainMenu: mainMenu),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        backgroundColor: AppColors.sidebarBackgroundColor,
        child: Icon(Icons.message_sharp,color: AppColors.white,),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.padding + 3),
            child: body,
          ),
        ),
      ),
    );
  }

  Widget tabView() {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer:
          SidebarDrawer(title: title, isSubMenu: isSubMenu, mainMenu: mainMenu),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        backgroundColor: AppColors.sidebarBackgroundColor,
        child: Icon(Icons.message_sharp,color: AppColors.white,),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.padding * 3),
            child: body,
          ),
        ),
      ),
    );
  }

  Widget desktopView() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        backgroundColor: AppColors.sidebarBackgroundColor,
        child: Icon(Icons.message_sharp,color: AppColors.white,),
      ),
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: SidebarDrawer(
                  title: title, isSubMenu: isSubMenu, mainMenu: mainMenu),
            ),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  AppBar(
                    centerTitle: false,
                    automaticallyImplyLeading: false,
                    title: Padding(
                      padding: EdgeInsets.symmetric(vertical: (SizeConfig.padding * 2) - 2),
                      child: SizedBox(
                        width: 250,
                        height: 43,
                        child: Center(
                          child: TextFormField(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              prefixIcon: const Icon(Icons.search),
                              hintText: "Search...",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  )),
                            ),
                          ),
                        ),
                      ),
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    actions: [
                      StreamBuilder<AppTheme>(
                        stream: themeBloc.themeStream,
                        initialData: themeBloc.currentTheme,
                        builder: (context, snapshot) {
                          return IconButton(
                            onPressed: () {
                              themeBloc.toggleDarkMode(!themeBloc.isDarkMode); // Light mode
                            },
                            icon: Icon(themeBloc.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                          );
                        },
                      ),
                      const SizedBox(width: 10.0),
                      StreamBuilder<AppTheme>(
                        stream: themeBloc.themeStream,
                        initialData: themeBloc.currentTheme,
                        builder: (context, snapshot) {
                          return PopupMenuButton<ColorSeed>(
                            initialValue: themeBloc.currentColorSeed,
                            onSelected: (ColorSeed colorSeed) {
                              themeBloc.updateColorSeed(colorSeed);
                            },
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: themeBloc.currentColorSeed.color,
                            ),
                            itemBuilder: (BuildContext context) {
                              return ColorSeed.values.map((colorSeed) {
                                return PopupMenuItem<ColorSeed>(
                                  value: colorSeed,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: colorSeed.color,
                                    ),
                                    title: Text(colorSeed.label),
                                  ),
                                );
                              }).toList();
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 10.0),
                      notificationBadge(),
                      const SizedBox(width: 10.0),
                      menuBadge(),
                      const SizedBox(width: 10.0),
                      emailBadge(),
                      const SizedBox(width: 20.0),
                      profileAvatar(),
                      const SizedBox(width: 20.0),
                      drawerMenu(),
                      const SizedBox(width: 30.0),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(SizeConfig.padding * 3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            body,
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget menuBadge() {
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: 5, end: 3),
      showBadge: true,
      badgeStyle: badges.BadgeStyle(badgeColor: AppColors.pink),
      badgeContent: Text(
        "3",
        style: TextStyle(color: AppColors.white, fontSize: 9.0),
      ),
      child: Center(
        child: IconButton(
          icon: Icon(Icons.dashboard_rounded, color: AppColors.gray),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget notificationBadge() {
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: 5, end: 3),
      showBadge: true,
      badgeStyle: badges.BadgeStyle(badgeColor: AppColors.pink),
      badgeContent: Text(
        "8",
        style: TextStyle(color: AppColors.white, fontSize: 9.0),
      ),
      child: Center(
        child: IconButton(
            icon: Icon(Icons.notifications, color: AppColors.gray),
            onPressed: () {}),
      ),
    );
  }

  Widget emailBadge() {
    return Center(
      child: badges.Badge(
        position: badges.BadgePosition.topEnd(top: 5, end: 3),
        showBadge: true,
        badgeStyle: badges.BadgeStyle(badgeColor: AppColors.pink),
        badgeContent: Text(
          "6",
          style: TextStyle(color: AppColors.white, fontSize: 9.0),
        ),
        child: Center(
          child: IconButton(
            icon: Icon(Icons.email, color: AppColors.gray),
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  Widget profileAvatar() {
    return Center(
      child: badges.Badge(
        position: badges.BadgePosition.bottomEnd(bottom: 1, end: -1),
        showBadge: true,
        badgeStyle: badges.BadgeStyle(
          badgeColor: AppColors.success,
        ),
        child: CircleAvatar(
          radius: 18.0,
          backgroundColor: AppColors.sidebarBackgroundColor,
          backgroundImage: const AssetImage(
              "assets/images/profile.png"),
        ),
      ),
    );
  }

  Widget drawerMenu() {
    return const Center(
      child: IconButton(
        onPressed: null,
        icon: Icon(Icons.dashboard_outlined),
      ),
    );
  }
}
