// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class CustomCardWidgets extends StatelessWidget {
  final Widget child;
  final double? containerHeight;
  final Color? containerColor;
  final AlignmentGeometry? alignment;
  const CustomCardWidgets({super.key,required this.child, this.containerColor,this.containerHeight,this.alignment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.padding),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          height: containerHeight,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: alignment,
          child: child,
        ),
      ),
    );
  }
}
