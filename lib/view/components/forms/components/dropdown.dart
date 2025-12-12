import 'package:dashboardpro/dashboardpro.dart';

class CustomDropDown extends StatefulWidget {
  const CustomDropDown({super.key});

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {

  String _selectedItem = 'Option 1'; // Track the selected dropdown item.

  final List<String> _dropdownItems = ['Option 1', 'Option 2', 'Option 3']; // Define the dropdown options.

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      decoration: const InputDecoration(
        labelText: 'Select an option',
        border: OutlineInputBorder(),
      ),
      value: _selectedItem, // Set the selected item to be displayed in the dropdown.
      items: _dropdownItems.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedItem = value.toString(); // Update the selected dropdown item.
        });
      },
    );
  }
}
