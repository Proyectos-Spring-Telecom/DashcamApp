import 'package:dashboardpro/dashboardpro.dart';

enum Gender { male, female, other } // Define an enumeration for the radio options.

class CustomRadioSelection extends StatefulWidget {
  const CustomRadioSelection({super.key});

  @override
  State<CustomRadioSelection> createState() => _CustomRadioSelectionState();
}

class _CustomRadioSelectionState extends State<CustomRadioSelection> {

  Gender _selectedGender = Gender.male;

  List<Widget> _buildGenderRadioList() {
    return Gender.values
        .map((gender) => RadioListTile<Gender>(
      title: Text(gender.toString().split('.').last),
      value: gender,
      groupValue: _selectedGender,
      onChanged: (value) {
        setState(() {
          _selectedGender = value!;
          Navigator.of(context).pop();
        });
      },
    ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: _selectedGender.name),
      decoration: const InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.arrow_drop_down)
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Select Gender'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: _buildGenderRadioList(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
