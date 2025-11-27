import 'package:dashboardpro/dashboardpro.dart';

class DragList extends StatefulWidget {
  const DragList({super.key});
  @override
  State<DragList> createState() => _DragListState();
}

class _DragListState extends State<DragList> {
  List<String> items = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
    'Item 6',
    'Item 7',
    'Item 8',
    'Item 9',
    'Item 10'
  ];

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      shrinkWrap: true,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final String item = items.removeAt(oldIndex);
          items.insert(newIndex, item);
        });
      },
      children: items
          .map(
            (item) => ListTile(
              key: ValueKey(item),
              title: Text(item),
              leading: const Icon(Icons.drag_handle),
            ),
          )
          .toList(),
    );
  }
}
