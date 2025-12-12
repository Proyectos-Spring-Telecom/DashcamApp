import 'package:dashboardpro/dashboardpro.dart';

class Toasts extends StatelessWidget {
  const Toasts({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
      title: AppBarTitle.toasts,
      isSubMenu: true,
      mainMenu: AppBarTitle.notifications,
      body: bodyWidget(context: context),
    );
  }

  Widget bodyWidget({required BuildContext context}) {
    return Column(
      children: [
        ResponsiveGridRow(
          children: [
            ResponsiveGridCol(
              sm: 12,
              lg: 12,
              md: 12,
              xl: 12,
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10.0,),
                    ListTile(
                      title: Text(
                        "Toast Live example",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding * 2,
                          vertical: SizeConfig.padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Click the button the below to show as toast (positioning with our utilities in the lower right corner) that has been hidden by default with .hide.",
                          ),
                          SizedBox(height: SizeConfig.spaceHeight),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: EdgeInsets.all(SizeConfig.padding),
                              child: SizedBox(
                                height: 60,
                                width: MediaQuery.of(context).size.width / 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.all(SizeConfig.padding),
                                      child: FilledButton(
                                        onPressed:   () {
                                          const snackBar = SnackBar(
                                            content: Text('Yay! A SnackBar!'),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                        },
                                        child: const Text('Show Live Toast'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 12,
              md: 12,
              xl: 12,
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10.0,),
                    ListTile(
                      title: Text(
                        "Toast Translucent",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding * 2,
                          vertical: SizeConfig.padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Toasts are slightly translucent, too, so they blend over whatever they might appear over.",
                          ),
                          SizedBox(height: SizeConfig.spaceHeight),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: EdgeInsets.all(SizeConfig.padding),
                              child: Container(
                                height: 110,
                                color: Theme.of(context).colorScheme.inversePrimary,
                                width: MediaQuery.of(context).size.width / 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      color: Theme.of(context).colorScheme.primary,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(SizeConfig.padding),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: AppColors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                  height: 20,
                                                  width: 20,
                                                ),
                                                SizedBox(
                                                    width:
                                                        SizeConfig.spaceWidth),
                                                Text(
                                                  "DashboardPro",
                                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                    color: AppColors.white
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "11 mins ago",
                                                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                                      color: AppColors.white
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                        SizeConfig.spaceWidth),
                                                Icon(Icons.clear,
                                                    color: AppColors.white),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: SizeConfig.padding,
                                          vertical: SizeConfig.padding * 2),
                                      child: const Text(
                                          "Hello, world! This is a toast message."),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 12,
              md: 12,
              xl: 12,
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10.0,),
                    ListTile(
                      title: Text(
                        "Toast Custom content",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding * 2,
                          vertical: SizeConfig.padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Customize your toasts by removing sub-components, tweaking with utilities, or adding your own markup. Here we’ve created a simpler toast by removing the default .toast-header, adding a custom hide icon from CoreUI Icons, and using some flexbox utilities to adjust the layout.",
                          ),
                          SizedBox(height: SizeConfig.spaceHeight),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: EdgeInsets.all(SizeConfig.padding),
                              child: SizedBox(
                                height: 80,
                                width: MediaQuery.of(context).size.width / 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.all(SizeConfig.padding),
                                      child: const ListTile(
                                        title: Text(
                                            "Hello, world! This is a toast message."),
                                        trailing: Icon(Icons.clear),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 12,
              md: 12,
              xl: 12,
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10.0,),
                    ListTile(
                      title: Text(
                        "Toast Color schemes",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding * 2,
                          vertical: SizeConfig.padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Building on the above example, you can create different toast color schemes with our color and background utilities. Here we’ve added .bg-primary and .text-white to the .toast, and then added .btn-close-white to our close button. For a crisp edge, we remove the default border with .border-0.",
                          ),
                          SizedBox(height: SizeConfig.spaceHeight),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: EdgeInsets.all(SizeConfig.padding),
                              child: SizedBox(
                                height: 80,
                                width: MediaQuery.of(context).size.width / 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.all(SizeConfig.padding),
                                      child: Container(
                                        color: Theme.of(context).colorScheme.primary,
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              SizeConfig.padding),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: AppColors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                    ),
                                                    height: 20,
                                                    width: 20,
                                                  ),
                                                  SizedBox(
                                                      width: SizeConfig
                                                          .spaceWidth),
                                                  Text(
                                                    "DashboardPro",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors.white),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "11 mins ago",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors.white),
                                                  ),
                                                  SizedBox(
                                                      width: SizeConfig
                                                          .spaceWidth),
                                                  Icon(Icons.clear,
                                                      color: AppColors.white),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: SizeConfig.spaceHeight * 2),
        Responsive.isDesktop(context)
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("© 2023, Made with ❤️  by TGI"),
                  Row(
                    children: [
                      Text("License"),
                      SizedBox(width: 10.0),
                      Text("Support"),
                      SizedBox(width: 10.0),
                      Text("Documentation"),
                      SizedBox(width: 60.0)
                    ],
                  ),
                ],
              )
            : const SizedBox(),
      ],
    );
  }
}
