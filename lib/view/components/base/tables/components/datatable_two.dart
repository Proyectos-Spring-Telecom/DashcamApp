import 'package:dashboardpro/dashboardpro.dart';

class DataTableTwo extends StatelessWidget {
  const DataTableTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 50,
        columns: const [
          DataColumn(
              label: Text(
                'ID',
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          DataColumn(label: Text('Name',style: TextStyle(fontWeight: FontWeight.bold),)),
          DataColumn(label: Text('Age',style: TextStyle(fontWeight: FontWeight.bold),)),
          DataColumn(label: Text('City',style: TextStyle(fontWeight: FontWeight.bold),)),
          DataColumn(label: Text('Salary',style: TextStyle(fontWeight: FontWeight.bold),)),
          DataColumn(label: Text('COD',style: TextStyle(fontWeight: FontWeight.bold),)),
        ],
        rows: data
            .map((item) => DataRow(cells: [
          DataCell(Text(
            item['id'].toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          )),
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
