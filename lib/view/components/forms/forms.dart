import 'package:dashboardpro/dashboardpro.dart';

class FormScreen extends StatelessWidget {
  FormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
      title: AppBarTitle.forms,
      isSubMenu: false,
      body: bodyWidget(context: context),
    );
  }

  final _formKey = GlobalKey<FormState>();

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
                        "Form Control Basic Example",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding * 2,
                          vertical: SizeConfig.padding),
                      child: Padding(
                        padding: EdgeInsets.all(SizeConfig.padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: SizeConfig.spaceHeight/2),
                            Text(
                              "Email address",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            SizedBox(height: SizeConfig.spaceHeight),
                            TextFormField(
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: SizeConfig.padding),
                                border: const OutlineInputBorder(),
                                hintText: "name@example.com"
                              ),
                            ),
                            SizedBox(height: SizeConfig.spaceHeight),
                            Text(
                              "Example textarea",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            SizedBox(height: SizeConfig.spaceHeight),
                            TextFormField(
                              maxLines: 4,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: SizeConfig.padding,vertical: SizeConfig.padding*2),
                                  border: const OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
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
                        "Form Control Disabled",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding * 2,
                          vertical: SizeConfig.padding),
                      child: Padding(
                        padding: EdgeInsets.all(SizeConfig.padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                  enabled: false,
                                  contentPadding: EdgeInsets.only(left: SizeConfig.padding),
                                  border: const OutlineInputBorder(),
                                  hintText: "Disabled Input"
                              ),
                            ),
                            SizedBox(height: SizeConfig.spaceHeight),
                            TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                enabled: false,
                                contentPadding: EdgeInsets.only(left: SizeConfig.padding),
                                border: const OutlineInputBorder(),
                                  hintText: "Disabled Read Only"
                              ),
                            ),
                          ],
                        ),
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
                        "Form Control Read Only",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding * 2,
                          vertical: SizeConfig.padding),
                      child: Padding(
                        padding: EdgeInsets.all(SizeConfig.padding),
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: SizeConfig.padding),
                              border: const OutlineInputBorder(),
                              hintText: "Read Only"
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
                        "Form Control Validation",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding * 2,
                          vertical: SizeConfig.padding),
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: EdgeInsets.all(SizeConfig.padding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: SizeConfig.spaceHeight/2),
                              Text(
                                "Email address",
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              SizedBox(height: SizeConfig.spaceHeight),
                              TextFormField(
                                validator: (v) {
                                  if(v.toString().isEmpty) {
                                    return "Enter Email";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: SizeConfig.padding),
                                    border: const OutlineInputBorder(),
                                    hintText: "name@example.com"
                                ),
                              ),
                              SizedBox(height: SizeConfig.spaceHeight),
                              Text(
                                "Password",
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              SizedBox(height: SizeConfig.spaceHeight),
                              TextFormField(
                                validator: (v) {
                                  if(v.toString().isEmpty) {
                                    return "Enter Password";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: SizeConfig.padding),
                                    border: const OutlineInputBorder(),
                                    hintText: "password",
                                    suffixIcon: const Icon(Icons.remove_red_eye)
                                ),
                              ),
                              SizedBox(height: SizeConfig.spaceHeight),
                              FilledButton(
                                onPressed:   () {},
                                child: const Text('Submit'),
                              ),
                            ],
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
                        "Form Control DatePicker",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding * 2,
                          vertical: SizeConfig.padding),
                      child: const CustomDatePicker(),
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
                        "Form Control TimePicker",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding * 2,
                          vertical: SizeConfig.padding),
                      child: const CustomTimePicker(),
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
                        "Single Selection Dropdown",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding * 2,
                          vertical: SizeConfig.padding),
                      child: const CustomDropDown(),
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
                        "Multiple Selection Dropdown",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding * 2,
                          vertical: SizeConfig.padding),
                      child: const MultiSelectDropDown(),
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
                        "Radio Selection",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding * 2,
                          vertical: SizeConfig.padding),
                      child: const CustomRadioSelection(),
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
                        "Checkbox Selection",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding * 2,
                          vertical: SizeConfig.padding),
                      child: const CustomCheckboxSelection(),
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
                        "Multiple Checkbox Selection",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.padding * 2,
                          vertical: SizeConfig.padding),
                      child: const MultipleSelectCheckBox(),
                    )
                  ],
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
