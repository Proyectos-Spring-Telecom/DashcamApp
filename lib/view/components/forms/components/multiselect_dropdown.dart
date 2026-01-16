// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class MultiSelectDropDown extends StatefulWidget {
  const MultiSelectDropDown({super.key});

  @override
  State<MultiSelectDropDown> createState() => _MultiSelectDropDownState();
}

class _MultiSelectDropDownState extends State<MultiSelectDropDown> {

  List? _myActivities;
  late String _myActivitiesResult;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _myActivities = [];
    _myActivitiesResult = '';
  }

  _saveForm() {
    var form = formKey.currentState!;
    if (form.validate()) {
      form.save();
      setState(() {
        _myActivitiesResult = _myActivities.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            child: MultiSelectFormField(
              autovalidate: AutovalidateMode.disabled,
              chipBackGroundColor: AppColors.primary,
              chipLabelStyle: TextStyle(color: AppColors.white),
              checkBoxActiveColor: AppColors.primary,
              checkBoxCheckColor: AppColors.white,
              dialogShapeBorder: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0))),
              title: const Text(
                "My workouts",
                style: TextStyle(fontSize: 16),
              ),
              validator: (value) {
                if (value == null || value.length == 0) {
                  return 'Please select one or more options';
                }
                return null;
              },
              dataSource: const [
                {
                  "display": "Running",
                  "value": "Running",
                },
                {
                  "display": "Climbing",
                  "value": "Climbing",
                },
                {
                  "display": "Walking",
                  "value": "Walking",
                },
                {
                  "display": "Swimming",
                  "value": "Swimming",
                },
                {
                  "display": "Soccer Practice",
                  "value": "Soccer Practice",
                },
                {
                  "display": "Baseball Practice",
                  "value": "Baseball Practice",
                },
                {
                  "display": "Football Practice",
                  "value": "Football Practice",
                },
              ],
              textField: 'display',
              valueField: 'value',
              okButtonLabel: 'OK',
              cancelButtonLabel: 'CANCEL',
              hintWidget: const Text('Please choose one or more'),
              initialValue: _myActivities,
              onSaved: (value) {
                if (value == null) return;
                setState(() {
                  _myActivities = value;
                });
              },
            ),
          ),
          FilledButton(
            onPressed: _saveForm,
            child: const Text('Submit'),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(_myActivitiesResult),
          )
        ],
      ),
    );
  }
}
