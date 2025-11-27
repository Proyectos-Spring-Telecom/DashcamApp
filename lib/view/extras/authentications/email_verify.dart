// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class EmailVerificationWaitingScreen extends StatelessWidget {
  const EmailVerificationWaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Theme.of(context).colorScheme.primary,),
            const SizedBox(height: 20),
            Text(
              'Verifying your email...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'This may take a few moments.',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
