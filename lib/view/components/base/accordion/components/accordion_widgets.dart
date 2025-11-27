// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class AccordionWidgets extends StatefulWidget {
  const AccordionWidgets({
    super.key,
    required this.items,
    this.expanded = false,
  });
  final List<AccordionItem> items;
  final bool expanded;

  @override
  State<AccordionWidgets> createState() => _AccordionWidgetsState();
}

class _AccordionWidgetsState extends State<AccordionWidgets> {
  final List<bool> _expandedStates = [];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.items.length; i++) {
      _expandedStates.add(widget.expanded);
    }
  }

  Widget _buildAccordionItem(int index) {
    return Column(
      children: [
        SizedBox(height: SizeConfig.spaceHeight / 2),
        InkWell(
          onTap: () {
            setState(() {
              _expandedStates[index] = !_expandedStates[index];
            });
          },
          child: Container(

            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.items[index].header,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Icon(
                  _expandedStates[index]
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
        ),
        if (_expandedStates[index])
          Container(
            width: MediaQuery.of(context).size.width,
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: widget.items[index].body,
          ),
        SizedBox(height: SizeConfig.spaceHeight / 2),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < widget.items.length; i++)
          _buildAccordionItem(i),
      ],
    );
  }
}
