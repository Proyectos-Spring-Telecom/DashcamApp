import 'package:dashboardpro/dashboardpro.dart';

class TableScreen extends StatelessWidget {
  const TableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
        title: AppBarTitle.tables,
        isSubMenu: true,
        mainMenu: AppBarTitle.base,
        body: bodyWidget(context: context)
    );
  }

  Widget bodyWidget({required BuildContext context}) {
    return ResponsiveGridList(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      desiredItemWidth: Responsive.isMobile(context) ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width / 3,
      minSpacing: 10,
      children: [const DataTableOne(),const DataTableTwo(),const DataTableThree(),const DataTableFour(),const DataTableFive(),const DataTableSix(),const DataTableSeven()].map(
            (i) {
          return SizedBox(
            width: Responsive.isMobile(context) ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width / 2,
            child: Padding(
              padding: EdgeInsets.all(SizeConfig.padding),
              child: Card(
                child: i,
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}
List tableTitle = [
  "BASIC EXAMPLE",
  "BASIC BOLD EXAMPLE",
  "TABLE HEAD OPTIONS",
  "INVERSE TABLE",
  "STRIPED ROWS",
  "HOVERABLE ROWS",
  "BORDERED TABLE"
];

final List<Map<String, dynamic>> data = [
  {'id': 1, 'name': 'John Doe', 'age': 30, 'city': 'New York', 'salary': 5000},
  {'id': 2, 'name': 'Jane Smith', 'age': 25, 'city': 'Los Angeles', 'salary': 6000},
  {'id': 3, 'name': 'Bob Johnson', 'age': 40, 'city': 'Chicago', 'salary': 7000},
  {'id': 4, 'name': 'Alice Brown', 'age': 35, 'city': 'Houston', 'salary': 8000},
];

