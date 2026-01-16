// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
      title: AppBarTitle.faq,
      isSubMenu: true,
      mainMenu: AppBarTitle.authentication,
      body: bodyWidget(context),
    );
  }

  Widget bodyWidget(context) {
    return Card(
      child: ListView(
        shrinkWrap: true,
        children: [
          ExpansionTile(
            title: Text(
              'What is your return policy?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            children: [
              ListTile(
                title: Text(
                  'We have a 30-day return policy for all items. If you are not satisfied with your purchase, you can return it for a full refund.',
               style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
              'How can I track my order?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            children: [
              ListTile(
                title: Text(
                  'You can track your order by clicking on the "Track Order" link in the navigation menu. Enter your order number and email address to get the latest updates on your shipment.',
                style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
              'What payment methods do you accept?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            children: [
              ListTile(
                title: Text(
                  'We accept all major credit cards, PayPal, and Apple Pay.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
