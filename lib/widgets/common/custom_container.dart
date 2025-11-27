import 'package:dashboardpro/dashboardpro.dart';

class CustomContainer extends StatelessWidget {
  final Widget child;
  const CustomContainer({super.key,required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: SizeConfig.padding,
          vertical: SizeConfig.padding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
