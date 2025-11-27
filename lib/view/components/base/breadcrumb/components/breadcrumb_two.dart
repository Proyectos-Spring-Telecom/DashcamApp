// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class BreadcrumbTwo extends StatefulWidget {
  final List<String> items;
  final Color textColor;
  final Color activeTextColor;
  final Color separatorColor;
  final double fontSize;
  final FontWeight fontWeight;
  final void Function(int)? onItemTap;

  const BreadcrumbTwo({super.key,required this.items,
    required this.textColor,
    required this.activeTextColor,
    required this.separatorColor,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.onItemTap});

  @override
  State<BreadcrumbTwo> createState() => _BreadcrumbTwoState();
}

class _BreadcrumbTwoState extends State<BreadcrumbTwo> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < widget.items.length; i++)
          _buildBreadcrumbItem(i),
      ],
    );
  }

  Widget _buildBreadcrumbItem(int index) {
    bool isActive = index == _activeIndex;
    return Row(
      children: [
        if (index > 0)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.chevron_right, color: widget.separatorColor),
          ),
        GestureDetector(
          onTap: () {
            setState(() {
              _activeIndex = index;
              if (widget.onItemTap != null) {
                widget.onItemTap!(index);
              }
            });
          },
          child: Column(
            children: [
              Text(
                widget.items[index],
                style: TextStyle(
                  color: isActive ? widget.activeTextColor : widget.textColor,
                  fontSize: widget.fontSize,
                  fontWeight: isActive ? FontWeight.w700 : widget.fontWeight,
                ),
              ),
              const SizedBox(height: 2),
              isActive
                  ? Container(
                height: 2,
                width: 32,
                decoration: BoxDecoration(
                  color: AppColors.sidebarBackgroundColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
                  : Container(),
            ],
          ),
        ),
      ],
    );
  }
}
