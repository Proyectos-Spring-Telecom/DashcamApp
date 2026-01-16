// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class DataTableSeven extends StatelessWidget {
  const DataTableSeven({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 50,
        sortColumnIndex: 0,
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
          DataCell(Text(item['id'].toString())),
          DataCell(Text(item['name'])),
          DataCell(Text(item['age'].toString())),
          DataCell(Text(item['city'])),
          DataCell(Text('\$${item['salary']}')),
          DataCell(Text(item['name']+"_"+item['id'].toString())),
        ]))
            .toList(),
        dividerThickness: 2,
        showBottomBorder: true,
        showCheckboxColumn: false,
        border: TableBorder.all(),
      ),
    );
  }
}
