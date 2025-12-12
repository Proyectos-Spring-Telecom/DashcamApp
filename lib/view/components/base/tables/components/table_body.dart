// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class TablePage extends StatelessWidget {
  TablePage({super.key});

  final List<String> _columns = ['Name', 'Age', 'Gender', 'Location'];
  final List<Map<String, dynamic>> _data = [
    {'name': 'John', 'age': 30, 'gender': 'Male', 'location': 'New York'},
    {'name': 'Jane', 'age': 25, 'gender': 'Female', 'location': 'Los Angeles'},
    {'name': 'Bob', 'age': 40, 'gender': 'Male', 'location': 'Chicago'},
    {'name': 'Alice', 'age': 35, 'gender': 'Female', 'location': 'Houston'},
  ];

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.symmetric(
        inside: BorderSide(width: 1, color: AppColors.gray.withOpacity(0.3)),
      ),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(3),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: AppColors.sidebarBackgroundColor,
          ),
          children: _columns
              .map(
                (column) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    column.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        ..._data.map(
          (rowData) => TableRow(
            children: rowData.entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      entry.value.toString(),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
