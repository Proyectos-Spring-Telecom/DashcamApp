// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class Alerts extends StatelessWidget {
  const Alerts({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
      title: AppBarTitle.alert,
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
              lg: 6,
              md: 6,
              xl: 6,
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10.0,),
                    ListTile(
                      title: Text(
                        "Alerts",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding * 2,
                          vertical: SizeConfig.padding),
                      child: Column(
                        children: [
                          customContainer(
                            context: context,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: SizeConfig.spaceHeight),
                          customContainer(
                            context: context,
                            color: AppColors.success,
                          ),
                          SizedBox(height: SizeConfig.spaceHeight),
                          customContainer(
                            context: context,
                            color: AppColors.danger,
                          ),
                          SizedBox(height: SizeConfig.spaceHeight),
                          customContainer(
                            context: context,
                            color: AppColors.warning,
                          ),
                          SizedBox(height: SizeConfig.spaceHeight),
                          customContainer(
                            context: context,
                            color: AppColors.info,
                          ),
                          SizedBox(height: SizeConfig.spaceHeight),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 6,
              md: 6,
              xl: 6,
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10.0,),
                    ListTile(
                      title: Text(
                        "Alerts - Link color",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding * 2,
                          vertical: SizeConfig.padding),
                      child: Column(
                        children: [
                          customContainerWithLinkText(
                            context: context,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: SizeConfig.spaceHeight),
                          customContainerWithLinkText(
                            context: context,
                            color: AppColors.success,
                          ),
                          SizedBox(height: SizeConfig.spaceHeight),
                          customContainerWithLinkText(
                            context: context,
                            color: AppColors.danger,
                          ),
                          SizedBox(height: SizeConfig.spaceHeight),
                          customContainerWithLinkText(
                            context: context,
                            color: AppColors.warning,
                          ),
                          SizedBox(height: SizeConfig.spaceHeight),
                          customContainerWithLinkText(
                            context: context,
                            color: AppColors.info,
                          ),
                          SizedBox(height: SizeConfig.spaceHeight),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 6,
              md: 6,
              xl: 6,
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10.0,),
                    ListTile(
                      title: Text(
                        "Alerts - Additional content",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding * 2,
                          vertical: SizeConfig.padding * 2),
                      child: Container(
                        decoration: BoxDecoration(
                            color: AppColors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5.0)),
                        width: MediaQuery.of(context).size.width,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(SizeConfig.padding + 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: SizeConfig.spaceHeight / 2),
                                Text(
                                  "Well done!",
                                  style: TextStyle(
                                      color: AppColors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25.0),
                                ),
                                SizedBox(height: SizeConfig.spaceHeight),
                                Text(
                                  "Aww yeah, you successfully read this important alert message. This example text is going to run a bit longer so that you can see how spacing within an alert works with this kind of content.",
                                  style: TextStyle(color: AppColors.green),
                                ),
                                SizedBox(height: SizeConfig.spaceHeight / 2),
                                Divider(color: AppColors.success),
                                SizedBox(height: SizeConfig.spaceHeight / 2),
                                Text(
                                  "Whenever you need to, be sure to use margin utilities to keep things nice and tidy.",
                                  style: TextStyle(color: AppColors.green),
                                ),
                                SizedBox(height: SizeConfig.spaceHeight),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 6,
              md: 6,
              xl: 6,
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10.0,),
                    ListTile(
                      title: Text(
                        "Alerts - Additional content",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding * 2,
                          vertical: SizeConfig.padding * 2),
                      child: Container(
                        decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5.0)),
                        width: MediaQuery.of(context).size.width,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(SizeConfig.padding + 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: SizeConfig.spaceHeight / 2),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Holy guacamole!",
                                      style: TextStyle(
                                          color: AppColors.warning,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0),
                                    ),
                                    IconButton(
                                      onPressed: null,
                                      icon: Icon(
                                        Icons.close,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: SizeConfig.spaceHeight / 2),
                                Text(
                                  "Aww yeah, you successfully read this important alert message. This example text is going to run a bit longer so that you can see how spacing within an alert works with this kind of content.",
                                  style: TextStyle(color: AppColors.warning),
                                ),
                                SizedBox(height: SizeConfig.spaceHeight / 2),
                                Divider(color: AppColors.success),
                                SizedBox(height: SizeConfig.spaceHeight / 2),
                                Text(
                                  "Whenever you need to, be sure to use margin utilities to keep things nice and tidy.",
                                  style: TextStyle(color: AppColors.warning),
                                ),
                                SizedBox(height: SizeConfig.spaceHeight),
                              ],
                            ),
                          ),
                        ),
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

  Widget customContainer(
      {required BuildContext context, required Color color}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(5.0)),
      width: MediaQuery.of(context).size.width,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: SizeConfig.padding),
          child: Text(
            "This is a primary alert—check it out!",
            style: TextStyle(color: color),
          ),
        ),
      ),
    );
  }

  Widget customContainerWithLinkText(
      {required BuildContext context, required Color color}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(5.0)),
      width: MediaQuery.of(context).size.width,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: SizeConfig.padding),
          child: RichText(
            // Controls visual overflow
            overflow: TextOverflow.clip,
            softWrap: true,
            maxLines: 1,
            text: TextSpan(
              text: 'This is a primary alert — ',
              style: TextStyle(color: color),
              children: <TextSpan>[
                TextSpan(
                  text: 'check it out!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      if (!await launchUrl(Uri.parse('https://flutter.dev/'))) {
                        throw Exception(
                            'Could not launch ${Uri.parse('https://flutter.dev/')}');
                      }
                    },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
