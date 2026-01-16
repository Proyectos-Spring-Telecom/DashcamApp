import 'package:dashboardpro/dashboardpro.dart';

class Buttons extends StatelessWidget {
  const Buttons({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
      title: AppBarTitle.buttons,
      isSubMenu: false,
      body: bodyWidget(context: context),
    );
  }

  Widget bodyWidget({required BuildContext context}) {
    TextStyle fontColor = TextStyle(color: AppColors.white);
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
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.padding*2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("MATERIAL 3", style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: SizeConfig.spaceHeight/2),
                      Text("Buttons Without Icon", style: Theme.of(context).textTheme.labelMedium),
                      SizedBox(height: SizeConfig.spaceHeight),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed:   () {},
                            child: const Text('Elevated'),
                          ),
                          FilledButton(
                            onPressed:   () {},
                            child: const Text('Filled'),
                          ),
                          FilledButton.tonal(
                            onPressed:  () {},
                            child: const Text('Filled tonal'),
                          ),
                          OutlinedButton(
                            onPressed:   () {},
                            child: const Text('Outlined'),
                          ),
                          TextButton(
                            onPressed:  () {},
                            child: const Text('Text'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 12,
              md: 12,
              xl: 12,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.padding*2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("MATERIAL 3", style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: SizeConfig.spaceHeight/2),
                      Text("Buttons With Icon", style: Theme.of(context).textTheme.labelMedium),
                      SizedBox(height: SizeConfig.spaceHeight),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: <Widget>[
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add),
                            label: const Text('Icon'),
                          ),
                          FilledButton.icon(
                            onPressed: () {},
                            label: const Text('Icon'),
                            icon: const Icon(Icons.add),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () {},
                            label: const Text('Icon'),
                            icon: const Icon(Icons.add),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add),
                            label: const Text('Icon'),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add),
                            label: const Text('Icon'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 12,
              md: 12,
              xl: 12,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.padding*2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("MATERIAL 3", style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: SizeConfig.spaceHeight/2),
                      Text("Floating Action Buttons ", style: Theme.of(context).textTheme.labelMedium),
                      SizedBox(height: SizeConfig.spaceHeight),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: <Widget>[
                          FloatingActionButton.small(
                            onPressed: () {},
                            tooltip: 'Small',
                            child: const Icon(Icons.add),
                          ),
                          FloatingActionButton.extended(
                            onPressed: () {},
                            tooltip: 'Extended',
                            icon: const Icon(Icons.add),
                            label: const Text('Create'),
                          ),
                          FloatingActionButton(
                            onPressed: () {},
                            tooltip: 'Standard',
                            child: const Icon(Icons.add),
                          ),
                          FloatingActionButton.large(
                            onPressed: () {},
                            tooltip: 'Large',
                            child: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 12,
              md: 12,
              xl: 12,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.padding*2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Colors", style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: SizeConfig.spaceHeight/2),
                      Text("The color prop is used to change the background color of the alert.", style: Theme.of(context).textTheme.labelMedium),
                      SizedBox(height: SizeConfig.spaceHeight),
                      Wrap(
                        spacing: 8.0, // gap between adjacent buttons
                        runSpacing: 8.0, // gap between rows of buttons
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            child: Text('PRIMARY',style: fontColor,),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gray),
                            child: Text('SECONDARY',style: fontColor,),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success),
                            child: Text('SUCCESS',style: fontColor,),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.info),
                            child: Text('INFO',style: fontColor,),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.warning),
                            child: Text('WARNING',style: fontColor,),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.danger),
                            child: Text('ERROR',style: fontColor,),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 12,
              md: 12,
              xl: 12,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.padding*2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Outlined", style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: SizeConfig.spaceHeight/2),
                      Text("The outlined variant option is used to create outlined buttons.", style: Theme.of(context).textTheme.labelMedium),
                      SizedBox(height: SizeConfig.spaceHeight),
                      Wrap(
                        spacing: 8.0, // gap between adjacent buttons
                        runSpacing: 8.0, // gap between rows of buttons
                        children: <Widget>[
                          OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.primary)),
                              child: Text('PRIMARY',
                                  style: TextStyle(color: AppColors.primary))),
                          OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.gray)),
                              child: Text('SECONDARY',
                                  style: TextStyle(color: AppColors.gray))),
                          OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.success)),
                              child: Text('SUCCESS',
                                  style: TextStyle(color: AppColors.success))),
                          OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.cyan)),
                              child: Text('INFO',
                                  style: TextStyle(color: AppColors.cyan))),
                          OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.warning)),
                              child: Text('WARNING',
                                  style: TextStyle(color: AppColors.warning))),
                          OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.danger)),
                              child: Text('ERROR',
                                  style: TextStyle(color: AppColors.danger))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 12,
              md: 12,
              xl: 12,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.padding*2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Flat", style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: SizeConfig.spaceHeight/2),
                      Text("The flat buttons still maintain their background color, but have no box shadow.", style: Theme.of(context).textTheme.labelMedium),
                      SizedBox(height: SizeConfig.spaceHeight),
                      Wrap(
                        spacing: 8.0, // gap between adjacent buttons
                        runSpacing: 8.0, // gap between rows of buttons
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: AppColors.primary // set the background color
                            ),
                            child: Text('PRIMARY',style: fontColor,),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: AppColors.gray),
                            child: Text('SECONDARY',style: fontColor,),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: AppColors.success),
                            child: Text('SUCCESS',style: fontColor,),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: AppColors.cyan),
                            child: Text('INFO',style: fontColor,),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: AppColors.warning),
                            child: Text('WARNING',style: fontColor,),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: AppColors.primary),
                            child: Text('ERROR',style: fontColor,),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 12,
              md: 12,
              xl: 12,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.padding*2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Rounded", style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: SizeConfig.spaceHeight/2),
                      Text("Use the rounded prop to control the border radius of buttons.", style: Theme.of(context).textTheme.labelMedium),
                      SizedBox(height: SizeConfig.spaceHeight),
                      Wrap(
                        spacing: 8.0, // gap between adjacent buttons
                        runSpacing: 8.0, // gap between rows of buttons
                        children: <Widget>[
                          ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary, // set the background color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              child: Text('NORMAL BUTTON',style: fontColor,)),
                          ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gray,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  )),
                              child: Text('ROUNDED BUTTON',style: fontColor,)),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0.0),
                                )),
                            child: Text('TILE BUTTON',style: fontColor,),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.info,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                )),
                            child: Text('PILL BUTTON',style: fontColor,),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              sm: 12,
              lg: 12,
              md: 12,
              xl: 12,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.padding*2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("TEXT", style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: SizeConfig.spaceHeight/2),
                      Text("Use text variant option to create text button. Text buttons have no box shadow and no background.", style: Theme.of(context).textTheme.labelMedium),
                      SizedBox(height: SizeConfig.spaceHeight),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: <Widget>[
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                            child: const Text('PRIMARY'),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.gray),
                            child: const Text('SECONDARY'),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.success,
                            ),
                            child: const Text('SUCCESS'),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.info,
                            ),
                            child: const Text('INFO'),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.warning,
                            ),
                            child: const Text('WARNING'),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.danger,
                            ),
                            child: const Text('ERROR'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: SizeConfig.spaceHeight * 2),
        Responsive.isDesktop(context) ? const Row(
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
            )
          ],
        ) : const SizedBox()
      ],
    );
  }
}
