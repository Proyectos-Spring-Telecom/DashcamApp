import 'package:dashboardpro/dashboardpro.dart';

class DataTableThree extends StatelessWidget {
  const DataTableThree({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: TextStyle(color: AppColors.white),
        headingRowColor: WidgetStateColor.resolveWith((states) => Theme.of(context).colorScheme.primary),
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
          DataCell(Text(item['id'].toString())),
          DataCell(Text(item['name'])),
          DataCell(Text(item['age'].toString())),
          DataCell(Text(item['city'])),
          DataCell(Text('\$${item['salary']}')),
          DataCell(Text(item['name']+"_"+item['id'].toString())),
        ]))
            .toList(),
      ),
    );
  }
}
