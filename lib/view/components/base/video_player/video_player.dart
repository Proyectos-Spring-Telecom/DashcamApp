import 'package:dashboardpro/dashboardpro.dart';

class VideoPlayerScreen extends StatelessWidget {
  const VideoPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
        title: AppBarTitle.videoPlayer,
        isSubMenu: true,
        mainMenu: AppBarTitle.base,
        body: bodyWidget(context: context));
  }

  Widget bodyWidget({required BuildContext context}) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.padding * 2),
        child: const VideoPage(),
      ),
    );
  }
}
