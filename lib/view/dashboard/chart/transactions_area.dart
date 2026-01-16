// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class TransactionListTile extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String trailingText;

  const TransactionListTile({
    super.key,
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Center(
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.labelSmall,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(trailingText),
    );
  }
}

class TransactionsArea extends StatelessWidget {
  const TransactionsArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: SizeConfig.padding + 5,
          horizontal: SizeConfig.padding,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(
                title: Text(
                  "Transactions",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                trailing: Icon(Icons.more_vert_outlined),
              ),
              const SizedBox(height: 30.0),
              TransactionListTile(
                backgroundColor: AppColors.danger,
                icon: Icons.mobile_screen_share,
                iconColor: AppColors.danger,
                title: "Paypal",
                subtitle: "Send money",
                trailingText: "+34 USD",
              ),
              TransactionListTile(
                backgroundColor: AppColors.info,
                icon: Icons.wallet,
                iconColor: AppColors.info,
                title: "Wallet",
                subtitle: "Mac'D",
                trailingText: "+67 USD",
              ),
              TransactionListTile(
                backgroundColor: AppColors.cyan,
                icon: Icons.transfer_within_a_station,
                iconColor: AppColors.cyan,
                title: "Transfer",
                subtitle: "Refund",
                trailingText: "+584 USD",
              ),
              TransactionListTile(
                backgroundColor: AppColors.green,
                icon: Icons.mobile_screen_share,
                iconColor: AppColors.green,
                title: "Credit Card",
                subtitle: "Ordered Food",
                trailingText: "-874 USD",
              ),
              TransactionListTile(
                backgroundColor: AppColors.info,
                icon: Icons.wallet,
                iconColor: AppColors.info,
                title: "Wallet",
                subtitle: "Starbucks",
                trailingText: "+204 USD",
              ),
              TransactionListTile(
                backgroundColor: AppColors.warning,
                icon: Icons.add_card_rounded,
                iconColor: AppColors.warning,
                title: "Mastercard",
                subtitle: "Ordered Food",
                trailingText: "+134 USD",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
