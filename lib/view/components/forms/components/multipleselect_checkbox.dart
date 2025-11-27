import 'package:dashboardpro/dashboardpro.dart';

class MultipleSelectCheckBox extends StatefulWidget {
  const MultipleSelectCheckBox({super.key});

  @override
  State<MultipleSelectCheckBox> createState() => _MultipleSelectCheckBoxState();
}

class _MultipleSelectCheckBoxState extends State<MultipleSelectCheckBox> {
  final List<String> _selectedFruits = [];

  _buildFruitCheckboxList() {
    return ['Apple', 'Banana', 'Cherry', 'Durian']
        .map(
          (fruit) => CheckboxListTile(
            title: Text(fruit),
            value: _selectedFruits.contains(fruit),
            onChanged: (bool? checked) {
              setState(() {
                if (checked ?? false) {
                  _selectedFruits.add(fruit);
                } else {
                  _selectedFruits.remove(fruit);
                }
              });
            },
          ),
        ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _buildFruitCheckboxList(),
    );
  }
}
