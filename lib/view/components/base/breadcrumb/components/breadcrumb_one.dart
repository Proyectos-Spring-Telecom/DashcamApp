import 'package:dashboardpro/dashboardpro.dart';

class BreadcrumbOne extends StatefulWidget {
  final List<String> items;
  final Color textColor;
  final Color activeTextColor;
  final Color separatorColor;
  final double fontSize;
  final FontWeight fontWeight;
  final void Function(int)? onItemTap;
  const BreadcrumbOne({super.key, required this.items,
    required this.textColor,
    required this.activeTextColor,
    required this.separatorColor,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.onItemTap});

  @override
  State<BreadcrumbOne> createState() => _BreadcrumbOneState();
}

class _BreadcrumbOneState extends State<BreadcrumbOne> {
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
            margin: const EdgeInsets.symmetric(horizontal: 4),
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
          child: Text(
            widget.items[index],
            style: TextStyle(
              color: isActive ? widget.activeTextColor : widget.textColor,
              fontSize: widget.fontSize,
              fontWeight: isActive ? FontWeight.bold : widget.fontWeight,
            ),
          ),
        ),
      ],
    );
  }
}
