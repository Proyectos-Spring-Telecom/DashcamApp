import 'package:dashboardpro/dashboardpro.dart';

class InternalServerErrorPage extends StatelessWidget {
  const InternalServerErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/500.jpeg', // This is the path of your image asset
                height: 150,
                width: 150,
              ),
              const SizedBox(height: 16),
              const Text(
                '500 Internal Server Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Oops! Something went wrong on our end. We are working on it and will be back soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).go(RoutesName.dashboard);
                },
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
