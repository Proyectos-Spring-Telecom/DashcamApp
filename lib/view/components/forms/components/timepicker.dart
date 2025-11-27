import 'package:dashboardpro/dashboardpro.dart';

class CustomTimePicker extends StatefulWidget {
  const CustomTimePicker({super.key});

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {

  final TextEditingController _controller = TextEditingController();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _controller.text = picked.format(context); // Update the selected time in the text field.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true, // Prevents manual editing of the text field.
      onTap: () {
        _selectTime(context); // Shows the time picker when the text field is tapped.
      },
      decoration: const InputDecoration(
        labelText: 'Select Time',
        border: OutlineInputBorder(),
      ),
    );
  }
}
