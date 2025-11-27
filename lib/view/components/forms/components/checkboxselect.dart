import 'package:dashboardpro/dashboardpro.dart';

class CustomCheckboxSelection extends StatefulWidget {
  const CustomCheckboxSelection({super.key});

  @override
  State<CustomCheckboxSelection> createState() => _CustomCheckboxSelectionState();
}

class _CustomCheckboxSelectionState extends State<CustomCheckboxSelection> {
  bool _isSelected = false;
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: const Text('I accept the terms and conditions'),
      value: _isSelected,
      onChanged: (bool? newValue) {
        setState(() {
          _isSelected = newValue!;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
