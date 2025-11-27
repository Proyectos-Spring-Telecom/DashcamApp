import 'package:dashboardpro/dashboardpro.dart';

class Widgets extends StatelessWidget {
  const Widgets({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
      title: AppBarTitle.widgets,
      isSubMenu: false,
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
              child: ResponsiveGridRow(
                children: [
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Container(
                      height: 150,
                      margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding,
                          vertical: SizeConfig.padding),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          ListTile(
                            title: Text("26K (-12.4% )",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: AppColors.white)),
                            subtitle: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: Text("Users",style: TextStyle(color: AppColors.white),),
                            ),
                            trailing: Icon(Icons.more_vert,color: AppColors.white),
                          ),
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          Sparkline(
                            lineWidth: 3,
                            pointSize: 10.0,
                            fallbackHeight: 40.0,
                            data: const [0.0,1.3,1.2,3.0,0.0],
                          )
                        ],
                      ),
                    ),
                  ),
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Container(
                      height: 150,
                      margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding,
                          vertical: SizeConfig.padding),
                      decoration: BoxDecoration(
                        color: AppColors.info,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          ListTile(
                            title: Text("\$6.200 (40.9%)",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: AppColors.white)),
                            subtitle: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: Text("Income",style: TextStyle(color: AppColors.white),),
                            ),
                            trailing: Icon(Icons.more_vert,color: AppColors.white),
                          ),
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          Sparkline(
                            lineColor: AppColors.white.withOpacity(0.2),
                            lineWidth: 3,
                            pointSize: 10.0,
                            fallbackHeight: 40.0,
                            data: const [0.0,2.3,5.2,1.0,0.0],
                          )
                        ],
                      ),
                    ),
                  ),
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Container(
                      height: 150,
                      margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding,
                          vertical: SizeConfig.padding),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          ListTile(
                            title: Text("2.49% (84.7% )",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: AppColors.white)),
                            subtitle: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: Text("Conversion Rate",style: TextStyle(color: AppColors.white),),
                            ),
                            trailing: Icon(Icons.more_vert,color: AppColors.white),
                          ),
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          Sparkline(
                            lineWidth: 3,
                            lineColor: AppColors.white.withOpacity(0.2),
                            pointSize: 10.0,
                            fallbackHeight: 40.0,
                            data: const [0.0,1.3,1.2,3.0,0.0],
                          )
                        ],
                      ),
                    ),
                  ),
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Container(
                      height: 150,
                      margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding,
                          vertical: SizeConfig.padding),
                      decoration: BoxDecoration(
                        color: AppColors.pink,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          ListTile(
                            title: Text("44K (-23.6% )",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: AppColors.white)),
                            subtitle: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: Text("Sessions",style: TextStyle(color: AppColors.white),),
                            ),
                            trailing: Icon(Icons.more_vert,color: AppColors.white),
                          ),
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          Sparkline(
                            lineColor: AppColors.white.withOpacity(0.2),
                            lineWidth: 3,
                            pointSize: 10.0,
                            fallbackHeight: 40.0,
                            data: const [0.0,2.3,0.2,2.0,0.0],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 12,
              md: 12,
              xl: 12,
              child: ResponsiveGridRow(
                children: [
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Card(
                      child: Container(
                        height: 150,
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.padding,
                            vertical: SizeConfig.padding),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: SizeConfig.spaceHeight/2),
                            ListTile(
                              title: Text("89.9%",style: Theme.of(context).textTheme.titleLarge),
                              subtitle: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                child: Text("Widget title",style: Theme.of(context).textTheme.bodyMedium,),
                              ),
                            ),
                            SizedBox(height: SizeConfig.spaceHeight/2),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 7.0),
                              child: LinearPercentIndicator(
                                animationDuration: 50,
                                barRadius: const Radius.circular(5.0),
                                animation: true,
                                lineHeight: 5.0,
                                percent: 0.2,
                                progressColor: AppColors.success,
                              ),
                            ),
                            SizedBox(height: SizeConfig.spaceHeight),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: SizeConfig.padding + 5),
                              child: Text("Widget helper text",style: Theme.of(context).textTheme.labelMedium,),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Card(
                      child: Container(
                        height: 150,
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.padding,
                            vertical: SizeConfig.padding),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: SizeConfig.spaceHeight/2),
                            ListTile(
                              title: Text("12.124",style: Theme.of(context).textTheme.titleLarge),
                              subtitle: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                child: Text("Widget title",style: Theme.of(context).textTheme.bodyMedium,),
                              ),
                            ),
                            SizedBox(height: SizeConfig.spaceHeight/2),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 7.0),
                              child: LinearPercentIndicator(
                                animationDuration: 50,
                                barRadius: const Radius.circular(5.0),
                                animation: true,
                                lineHeight: 5.0,
                                percent: 0.2,
                                progressColor: AppColors.info,
                              ),
                            ),
                            SizedBox(height: SizeConfig.spaceHeight),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: SizeConfig.padding + 5),
                              child: Text("Widget helper text",style: Theme.of(context).textTheme.labelMedium,),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Card(
                      child: Container(
                        height: 150,
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.padding,
                            vertical: SizeConfig.padding),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: SizeConfig.spaceHeight/2),
                            ListTile(
                              title: Text("\$62,939.0",style: Theme.of(context).textTheme.titleLarge),
                              subtitle: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                child: Text("Widget title",style: Theme.of(context).textTheme.bodyMedium),
                              ),
                            ),
                            SizedBox(height: SizeConfig.spaceHeight/2),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 7.0),
                              child: LinearPercentIndicator(
                                animationDuration: 50,
                                barRadius: const Radius.circular(5.0),
                                animation: true,
                                lineHeight: 5.0,
                                percent: 0.2,
                                progressColor: AppColors.warning,
                              ),
                            ),
                            SizedBox(height: SizeConfig.spaceHeight),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: SizeConfig.padding + 5),
                              child: Text("Widget helper text",style: Theme.of(context).textTheme.labelMedium),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Card(
                      child: Container(
                        height: 150,
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.padding,
                            vertical: SizeConfig.padding),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: SizeConfig.spaceHeight/2),
                            ListTile(
                              title: Text("4TB",style: Theme.of(context).textTheme.titleLarge),
                              subtitle: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                child: Text("Widget title",style: Theme.of(context).textTheme.bodyMedium),
                              ),
                            ),
                            SizedBox(height: SizeConfig.spaceHeight/2),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 7.0),
                              child: LinearPercentIndicator(
                                animationDuration: 50,
                                barRadius: const Radius.circular(5.0),
                                animation: true,
                                lineHeight: 5.0,
                                percent: 0.2,
                                progressColor: AppColors.pink,
                              ),
                            ),
                            SizedBox(height: SizeConfig.spaceHeight),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: SizeConfig.padding + 5),
                              child: Text("Widget helper text",style: Theme.of(context).textTheme.labelMedium),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 12,
              md: 12,
              xl: 12,
              child: ResponsiveGridRow(
                children: [
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Container(
                      height: 150,
                      margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding,
                          vertical: SizeConfig.padding),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          ListTile(
                            title: Text("89.9%",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: AppColors.white)),
                            subtitle: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: Text("Widget title",style: TextStyle(color: AppColors.white),),
                            ),
                          ),
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7.0),
                            child: LinearPercentIndicator(
                              animationDuration: 50,
                              barRadius: const Radius.circular(5.0),
                              animation: true,
                              lineHeight: 5.0,
                              percent: 0.2,
                              progressColor: AppColors.white,
                            ),
                          ),
                          SizedBox(height: SizeConfig.spaceHeight),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: SizeConfig.padding + 5),
                            child: Text("Widget helper text",style: TextStyle(color: AppColors.white.withOpacity(0.7),fontSize: 10.0),),
                          )
                        ],
                      ),
                    ),
                  ),
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Container(
                      height: 150,
                      margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding,
                          vertical: SizeConfig.padding),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          ListTile(
                            title: Text("12.124",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: AppColors.white)),
                            subtitle: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: Text("Widget title",style: TextStyle(color: AppColors.white),),
                            ),
                          ),
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7.0),
                            child: LinearPercentIndicator(
                              animationDuration: 50,
                              barRadius: const Radius.circular(5.0),
                              animation: true,
                              lineHeight: 5.0,
                              percent: 0.2,
                              progressColor: AppColors.white,
                            ),
                          ),
                          SizedBox(height: SizeConfig.spaceHeight),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: SizeConfig.padding + 5),
                            child: Text("Widget helper text",style: TextStyle(color: AppColors.white.withOpacity(0.7),fontSize: 10.0),),
                          )
                        ],
                      ),
                    ),
                  ),
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Container(
                      height: 150,
                      margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding,
                          vertical: SizeConfig.padding),
                      decoration: BoxDecoration(
                        color: AppColors.pink,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          ListTile(
                            title: Text("\$98.111,00",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: AppColors.white)),
                            subtitle: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: Text("Widget title",style: TextStyle(color: AppColors.white),),
                            ),
                          ),
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7.0),
                            child: LinearPercentIndicator(
                              animationDuration: 50,
                              barRadius: const Radius.circular(5.0),
                              animation: true,
                              lineHeight: 5.0,
                              percent: 0.2,
                              progressColor: AppColors.white,
                            ),
                          ),
                          SizedBox(height: SizeConfig.spaceHeight),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: SizeConfig.padding + 5),
                            child: Text("Widget helper text",style: TextStyle(color: AppColors.white.withOpacity(0.7),fontSize: 10.0),),
                          )
                        ],
                      ),
                    ),
                  ),
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Container(
                      height: 150,
                      margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding,
                          vertical: SizeConfig.padding),
                      decoration: BoxDecoration(
                        color: AppColors.info,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          ListTile(
                            title: Text("2 TB",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: AppColors.white)),
                            subtitle: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: Text("Widget title",style: TextStyle(color: AppColors.white),),
                            ),
                          ),
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7.0),
                            child: LinearPercentIndicator(
                              animationDuration: 50,
                              barRadius: const Radius.circular(5.0),
                              animation: true,
                              lineHeight: 5.0,
                              percent: 0.2,
                              progressColor: AppColors.white,
                            ),
                          ),
                          SizedBox(height: SizeConfig.spaceHeight),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: SizeConfig.padding + 5),
                            child: Text("Widget helper text",style: TextStyle(color: AppColors.white.withOpacity(0.7),fontSize: 10.0),),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 12,
              md: 12,
              xl: 12,
              child: ResponsiveGridRow(
                children: [
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Card(
                      child: Container(
                        height: 85,
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.padding,
                            vertical: SizeConfig.padding*1.5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ListTile(
                              leading: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    color: AppColors.cyan.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5.0)
                                ),
                                child: Center(
                                  child: Icon(Icons.person,color: AppColors.cyan),
                                ),
                              ),
                              title: Text("89.9%",style: Theme.of(context).textTheme.titleLarge),
                              subtitle: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                child: Text("Widget title",style: Theme.of(context).textTheme.labelMedium),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Card(
                      child: Container(
                        height: 85,
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.padding,
                            vertical: SizeConfig.padding*1.5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ListTile(
                              leading: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    color: AppColors.pink.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5.0)
                                ),
                                child: Center(
                                  child: Icon(Icons.person,color: AppColors.pink),
                                ),
                              ),
                              title: Text("29.9%",style: Theme.of(context).textTheme.titleLarge),
                              subtitle: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                child: Text("Widget title",style: Theme.of(context).textTheme.labelMedium),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Card(
                      child: Container(
                        height: 85,
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.padding,
                            vertical: SizeConfig.padding*1.5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ListTile(
                              leading: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5.0)
                                ),
                                child: Center(
                                  child: Icon(Icons.person,color: AppColors.success),
                                ),
                              ),
                              title: Text("\$273.00",style: Theme.of(context).textTheme.titleLarge),
                              subtitle: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                child: Text("Widget title",style: Theme.of(context).textTheme.labelMedium),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Card(
                      child: Container(
                        height: 85,
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.padding,
                            vertical: SizeConfig.padding*1.5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ListTile(
                              leading: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    color: AppColors.info.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5.0)
                                ),
                                child: Center(
                                  child: Icon(Icons.person,color: AppColors.info),
                                ),
                              ),
                              title: Text("-9.9%",style: Theme.of(context).textTheme.titleLarge),
                              subtitle: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                child: Text("Widget title",style: Theme.of(context).textTheme.labelMedium),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 12,
              md: 12,
              xl: 12,
              child: ResponsiveGridRow(
                children: [
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Container(
                      height: 110,
                      margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding,
                          vertical: SizeConfig.padding),
                      decoration: BoxDecoration(
                        color: AppColors.cyan,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(5.0)
                              ),
                              child: Center(
                                child: Icon(Icons.person,color: AppColors.cyan),
                              ),
                            ),
                            title: Text("89.9%",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: AppColors.white)),
                            subtitle: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: Text("Widget title",style: TextStyle(color: AppColors.white),),
                            ),
                          ),
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7.0),
                            child: LinearPercentIndicator(
                              animationDuration: 50,
                              barRadius: const Radius.circular(5.0),
                              animation: true,
                              lineHeight: 5.0,
                              percent: 0.2,
                              progressColor: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Container(
                      height: 110,
                      margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding,
                          vertical: SizeConfig.padding),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(5.0)
                              ),
                              child: Center(
                                child: Icon(Icons.person,color: AppColors.danger),
                              ),
                            ),
                            title: Text("12.124",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: AppColors.white)),
                            subtitle: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: Text("Widget title",style: TextStyle(color: AppColors.white),),
                            ),
                          ),
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7.0),
                            child: LinearPercentIndicator(
                              animationDuration: 50,
                              barRadius: const Radius.circular(5.0),
                              animation: true,
                              lineHeight: 5.0,
                              percent: 0.2,
                              progressColor: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Container(
                      height: 110,
                      margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding,
                          vertical: SizeConfig.padding),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(5.0)
                              ),
                              child: Center(
                                child: Icon(Icons.person,color: AppColors.warning),
                              ),
                            ),
                            title: Text("\$98.111,00",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: AppColors.white)),
                            subtitle: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: Text("Widget title",style: TextStyle(color: AppColors.white),),
                            ),
                          ),
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7.0),
                            child: LinearPercentIndicator(
                              animationDuration: 50,
                              barRadius: const Radius.circular(5.0),
                              animation: true,
                              lineHeight: 5.0,
                              percent: 0.2,
                              progressColor: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ResponsiveGridCol(
                    sm: 12,
                    lg: 12,
                    md: 6,
                    xl: 3,
                    child: Container(
                      height: 110,
                      margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding,
                          vertical: SizeConfig.padding),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(5.0)
                              ),
                              child: Center(
                                child: Icon(Icons.person,color: AppColors.success),
                              ),
                            ),
                            title: Text("2 TB",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: AppColors.white)),
                            subtitle: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: Text("Widget title",style: TextStyle(color: AppColors.white),),
                            ),
                          ),
                          SizedBox(height: SizeConfig.spaceHeight/2),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7.0),
                            child: LinearPercentIndicator(
                              animationDuration: 50,
                              barRadius: const Radius.circular(5.0),
                              animation: true,
                              lineHeight: 5.0,
                              percent: 0.2,
                              progressColor: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
