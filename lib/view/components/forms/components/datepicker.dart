import 'package:dashboardpro/dashboardpro.dart';

class CustomDatePicker extends StatefulWidget {
  const CustomDatePicker({super.key});

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {

  final TextEditingController _controller = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _controller.text = picked.toString(); // Update the selected date in the text field.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true, // Prevents manual editing of the text field.
      onTap: () {
        _selectDate(context); // Shows the date picker when the text field is tapped.
      },
      decoration: const InputDecoration(
        labelText: 'Select Date',
        border: OutlineInputBorder(),
      ),
    );
  }
}
