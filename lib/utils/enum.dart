import 'package:dashboardpro/dashboardpro.dart';

/// ColorSeed
enum ColorSeed {
  baseColor('M3 Baseline', Color(0xff6750a4)),
  indigo('Indigo', Colors.indigo),
  blue('Blue', Colors.blue),
  teal('Teal', Colors.teal),
  green('Green', Colors.green),
  yellow('Yellow', Colors.yellow),
  orange('Orange', Colors.orange),
  deepOrange('Deep Orange', Colors.deepOrange),
  pink('Pink', Colors.pink);

  const ColorSeed(this.label, this.color);
  final String label;
  final Color color;
}

/// Language
enum LanguageSeed {
  baseLanguage('English', "assets/images/english.png", 'en', 'US'),
  spanish('Spanish', 'assets/images/spanish.png', 'es', 'ES');

  const LanguageSeed(this.name, this.imagePath, this.languageCode, this.countryCode);
  final String name;
  final String imagePath;
  final String languageCode;
  final String countryCode;
}