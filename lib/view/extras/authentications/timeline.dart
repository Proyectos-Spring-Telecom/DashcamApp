import 'package:dashboardpro/dashboardpro.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
      title: AppBarTitle.timeline,
      isSubMenu: true,
      mainMenu: AppBarTitle.authentication,
      body: bodyWidget(),
    );
  }

  Widget bodyWidget() {
    return Card(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        children: [
          const TimelineItem(
            title: 'Project Started',
            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
            date: '2022-01-01',
            iconData: Icons.ac_unit,
            color: Colors.redAccent,
          ),
          SizedBox(height: SizeConfig.spaceHeight),
          const TimelineItem(
            title: 'First Milestone',
            description: 'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            date: '2022-03-15',
            iconData: Icons.check_circle_outline,
            color: Colors.green,
          ),
          SizedBox(height: SizeConfig.spaceHeight),
          const TimelineItem(
            title: 'Second Milestone',
            description: 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
            date: '2022-07-01',
            iconData: Icons.check_circle_outline,
            color: Colors.green,
          ),
          SizedBox(height: SizeConfig.spaceHeight),
          const TimelineItem(
            title: 'Project Completed',
            description: 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
            date: '2022-12-31',
            iconData: Icons.ac_unit,
            color: Colors.redAccent,
          ),
          SizedBox(height: SizeConfig.spaceHeight),
        ],
      ),
    );
  }
}

class TimelineItem extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final IconData iconData;
  final Color color;

  const TimelineItem({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.iconData,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Column(
            children: [
              Icon(iconData, color: color),
              Text(date, style: TextStyle(color: color)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 5),
                Text(description,style: Theme.of(context).textTheme.labelLarge,),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
