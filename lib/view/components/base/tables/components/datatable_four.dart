// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class DataTableFour extends StatelessWidget {
  const DataTableFour({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 50,
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Age')),
          DataColumn(label: Text('City')),
          DataColumn(label: Text('Salary')),
          DataColumn(label: Text('COD')),
        ],
        rows: data
            .map((item) => DataRow(cells: [
          DataCell(Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(item['id'].toString()),
            ),
          )),
          DataCell(Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(item['name']),
            ),
          )),
          DataCell(Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(item['age'].toString()),
            ),
          )),
          DataCell(Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(item['city']),
            ),
          )),
          DataCell(Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('\$${item['salary']}'),
            ),
          )),
          DataCell(IconButton(
            icon: Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.primary),
            onPressed: () {
              // Handle COD action
            },
          )),
        ]))
            .toList(),
      ),
    );
  }
}
