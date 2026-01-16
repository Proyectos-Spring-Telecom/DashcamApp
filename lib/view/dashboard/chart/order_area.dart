// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class OrderArea extends StatelessWidget {
  const OrderArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.padding + 5, vertical: SizeConfig.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Order"),
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Center(
                    child: Icon(Icons.people,color: Theme.of(context).colorScheme.primary,),
                  ),
                ),
              ],
            ),
            const Text("534",style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold),),
            Text("( +62.4% )",style: TextStyle(color: AppColors.success),)
          ],
        ),
      ),
    );
  }
}
