import 'package:dashboardpro/dashboardpro.dart';

class DataTableSix extends StatelessWidget {
  const DataTableSix({super.key});

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
            .map((item) => DataRow(
          color: WidgetStateColor.resolveWith(
                  (states) => Colors.grey.withOpacity(0.1)),
          cells: [
            DataCell(Text(item['id'].toString())),
            DataCell(Text(item['name'])),
            DataCell(Text(item['age'].toString())),
            DataCell(Text(item['city'])),
            DataCell(Text('\$${item['salary']}')),
            DataCell(Text(item['name']+"_"+item['id'].toString())),
          ],
        ))
            .toList(),
      ),
    );
  }
}
