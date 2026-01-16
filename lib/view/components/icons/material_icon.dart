// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class MaterialIcons extends StatelessWidget {
  const MaterialIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
      title: AppBarTitle.materialIcon,
      isSubMenu: true,
      mainMenu: AppBarTitle.icons,
      body: bodyWidget(context: context),
    );
  }

  Widget bodyWidget({required BuildContext context}) {
    return Card(
      child: Column(
        children: [
          ResponsiveGridList(
              shrinkWrap: true,
              scroll: false,
              desiredItemWidth: 150,
              minSpacing: 10,
              children: materialIcon.map((i) {
                return SizedBox(
                  height: 150,
                  child: Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: SizeConfig.spaceHeight),
                      Icon(i['icon']),
                      SizedBox(height: SizeConfig.spaceHeight),
                      Text("${i['label']}",textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,maxLines: 2,)
                    ],
                  )),
                );
              }).toList()
          ),
          const Text("Please Visit For More Icons"),
          SizedBox(height: SizeConfig.spaceHeight),
          InkWell(
              onTap: () async {
                if (!await launchUrl(Uri.parse('https://api.flutter.dev/flutter/material/Icons-class.html'))) {
                throw Exception('Could not launch ${Uri.parse('https://api.flutter.dev/flutter/material/Icons-class.html')}');
                }
              },
              child: Text("Material Icons",style: TextStyle(color: AppColors.primary),)),
          SizedBox(height: SizeConfig.spaceHeight),
        ],
      ),
    );
  }
}

const List<dynamic> materialIcon = [
  {"icon" : Icons.abc,"label" : 'abc'},
  {"icon" : Icons.abc_outlined,"label" : 'abc_outlined'},
  {"icon" : Icons.abc_rounded,"label" : 'abc_rounded'},
  {"icon" : Icons.abc_sharp,"label" : 'abc_sharp'},
  {"icon" : Icons.ac_unit,"label" : 'ac_unit'},
  {"icon" : Icons.ac_unit_outlined,"label" : 'ac_unit_outlined'},
  {"icon" : Icons.ac_unit_rounded,"label" : 'ac_unit_rounded'},
  {"icon" : Icons.ac_unit_sharp,"label" : 'ac_unit_sharp'},
  {"icon" : Icons.access_alarm,"label" : 'access_alarm'},
  {"icon" : Icons.access_alarm_outlined,"label" : 'access_alarm_outlined'},
  {"icon" : Icons.access_alarm_rounded,"label" : 'access_alarm_rounded'},
  {"icon" : Icons.access_alarm_sharp,"label" : 'access_alarm_sharp'},
  {"icon" : Icons.access_alarms,"label" : 'access_alarms'},
  {"icon" : Icons.access_alarms_outlined,"label" : 'access_alarms_outlined'},
  {"icon" : Icons.access_alarms_rounded,"label" : 'access_alarms_rounded'},
  {"icon" : Icons.access_alarms_sharp,"label" : 'access_alarms_sharp'},
  {"icon" : Icons.access_time,"label" : 'access_time'},
  {"icon" : Icons.access_time_filled,"label" : 'access_time_filled'},
  {"icon" : Icons.access_time_filled_outlined,"label" : 'access_time_filled_outlined'},
  {"icon" : Icons.access_time_filled_rounded,"label" : 'access_time_filled_rounded'},
  {"icon" : Icons.access_time_filled_sharp,"label" : 'access_time_filled_sharp'},
  {"icon" : Icons.access_time_outlined,"label" : 'access_time_outlined'},
  {"icon" : Icons.access_time_rounded,"label" : 'access_time_rounded'},
  {"icon" : Icons.access_time_sharp,"label" : 'access_time_sharp'},
  {"icon" : Icons.accessibility,"label" : 'accessibility'},
  {"icon" : Icons.accessibility_new,"label" : 'accessibility_new'},
  {"icon" : Icons.accessibility_new_outlined,"label" : 'accessibility_new_outlined'},
  {"icon" : Icons.accessibility_new_rounded,"label" : 'accessibility_new_rounded'},
  {"icon" : Icons.accessibility_new_sharp,"label" : 'accessibility_new_sharp'},
  {"icon" : Icons.accessibility_outlined,"label" : 'accessibility_outlined'},
  {"icon" : Icons.accessibility_rounded,"label" : 'accessibility_rounded'},
  {"icon" : Icons.accessibility_sharp,"label" : 'accessibility_sharp'},
  {"icon" : Icons.accessible,"label" : 'accessible'},
  {"icon" : Icons.accessible_forward,"label" : 'accessible_forward'},
  {"icon" : Icons.accessible_forward_outlined,"label" : 'accessible_forward_outlined'},
  {"icon" : Icons.accessible_forward_rounded,"label" : 'accessible_forward_rounded'},
  {"icon" : Icons.accessible_forward_sharp,"label" : 'accessible_forward_sharp'},
  {"icon" : Icons.accessible_outlined,"label" : 'accessible_outlined'},
  {"icon" : Icons.accessible_rounded,"label" : 'accessible_rounded'},
  {"icon" : Icons.accessible_sharp,"label" : 'accessible_sharp'},
  {"icon" : Icons.account_balance,"label" : 'account_balance'},
  {"icon" : Icons.account_balance_outlined,"label" : 'account_balance_outlined'},
  {"icon" : Icons.account_balance_rounded,"label" : 'account_balance_rounded'},
  {"icon" : Icons.account_balance_sharp,"label" : 'account_balance_sharp'},
  {"icon" : Icons.account_balance_wallet,"label" : 'account_balance_wallet'},
  {"icon" : Icons.account_balance_wallet_outlined,"label" : 'account_balance_wallet_outlined'},
  {"icon" : Icons.account_balance_wallet_rounded,"label" : 'account_balance_wallet_rounded'},
  {"icon" : Icons.account_balance_wallet_sharp,"label" : 'account_balance_wallet_sharp'},
  {"icon" : Icons.account_box,"label" : 'account_box'},
  {"icon" : Icons.account_box_outlined,"label" : 'account_box_outlined'},
  {"icon" : Icons.account_box_rounded,"label" : 'account_box_rounded'},
  {"icon" : Icons.account_box_sharp,"label" : 'account_box_sharp'},
  {"icon" : Icons.account_circle,"label" : 'account_circle'},
  {"icon" : Icons.account_circle_outlined,"label" : 'account_circle_outlined'},
  {"icon" : Icons.account_circle_rounded,"label" : 'account_circle_rounded'},
  {"icon" : Icons.account_circle_sharp,"label" : 'account_circle_sharp'},
  {"icon" : Icons.account_tree,"label" : 'account_tree'},
  {"icon" : Icons.account_tree_outlined,"label" : 'account_tree_outlined'},
  {"icon" : Icons.account_tree_rounded,"label" : 'account_tree_rounded'},
  {"icon" : Icons.account_tree_sharp,"label" : 'account_tree_sharp'},
  {"icon" : Icons.ad_units,"label" : 'ad_units'},
  {"icon" : Icons.ad_units_outlined,"label" : 'ad_units_outlined'},
  {"icon" : Icons.ad_units_rounded,"label" : 'ad_units_sharp'},
  {"icon" : Icons.adb,"label" : 'adb'},
  {"icon" : Icons.adb_outlined,"label" : 'adb_outlined'},
  {"icon" : Icons.adb_rounded,"label" : 'adb_rounded'},
  {"icon" : Icons.adb_sharp,"label" : 'adb_sharp'},
  {"icon" : Icons.add,"label" : 'add'},
  {"icon" : Icons.add_a_photo,"label" : 'add_a_photo'},
  {"icon" : Icons.add_a_photo_outlined,"label" : 'add_a_photo_outlined'},
  {"icon" : Icons.add_a_photo_rounded,"label" : 'add_a_photo_rounded'},
  {"icon" : Icons.add_a_photo_sharp,"label" : 'add_a_photo_sharp'},
  {"icon" : Icons.add_alarm,"label" : 'add_alarm'},
  {"icon" : Icons.add_alarm_outlined,"label" : 'add_alarm_outlined'},
  {"icon" : Icons.add_alarm_rounded,"label" : 'add_alarm_rounded'},
  {"icon" : Icons.add_alarm_sharp,"label" : 'add_alarm_sharp'},
  {"icon" : Icons.add_alert,"label" : 'add_alert'},
  {"icon" : Icons.add_alert_outlined,"label" : 'add_alert_outlined'},
];
