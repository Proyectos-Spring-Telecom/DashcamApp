import 'package:dashboardpro/dashboardpro.dart';

class DataTableFive extends StatelessWidget {
  const DataTableFive({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        
        dataRowColor: WidgetStateColor.resolveWith((states) => AppColors.sidebarBackgroundColor),
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
            .asMap()
            .map((index, item) => MapEntry(
            index,
            DataRow(
                cells: [
                  DataCell(Text(item['id'].toString())),
                  DataCell(Text(item['name'])),
                  DataCell(Text(item['age'].toString())),
                  DataCell(Text(item['city'])),
                  DataCell(Text('\$${item['salary']}')),
                  DataCell(Text(item['name']+"_"+item['id'].toString())),
                ],
                color: WidgetStateColor.resolveWith((states) =>
                index % 2 == 0
                    ? AppColors.sidebarBackgroundColor.withOpacity(0.2)
                    : Colors.transparent))))
            .values
            .toList(),
      ),
    );
  }
}
