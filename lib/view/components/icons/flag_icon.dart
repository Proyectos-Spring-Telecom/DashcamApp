// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class FlagIcons extends StatelessWidget {
  const FlagIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
      title: AppBarTitle.flagIcon,
      isSubMenu: true,
      mainMenu: AppBarTitle.icons,
      body: bodyWidget(context: context),
    );
  }

  Widget bodyWidget({required BuildContext context}) {
    return Card(
      child: ResponsiveGridList(
        shrinkWrap: true,
          scroll: false,
          desiredItemWidth: 100,
          minSpacing: 10,
          children: _languageCodes.map((i) {
            return SizedBox(
              height: 100,
              child: Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CountryFlag.fromLanguageCode(
                    i,
                    height: 30,
                    width: 50,
                    borderRadius: 8,
                  ),
                  SizedBox(height: SizeConfig.spaceHeight),
                  Text(i)
                ],
              )),
            );
          }).toList()
      ),
    );
  }
}

const List<String> _languageCodes = [
  'af',
  'za',
  'ar-ae',
  'ar-bh',
  'ar-dz',
  'ar-eg',
  'ar-iq',
  'ar-jo',
  'ar-kw',
  'ar-lb',
  'ar-ly',
  'ar-ma',
  'ar-om',
  'ar-qa',
  'ar-sa',
  'ar-sy',
  'ar-tn',
  'ar-ye',
  'az',
  'be',
  'be-by',
  'bg',
  'ca',
  'cs-cz',
  'cy',
  'da-dk',
  'de',
  'de-at',
  'de-ch',
  'de-li',
  'de-lu',
  'dv-mv',
  'el',
  'en',
  'en-au',
  'en-bz',
  'en-ie',
  'en-jm',
  'en-nz',
  'en-ph',
  'en-tt',
  'en-us',
  'en-zw',
  'es',
  'es-ar',
  'es-bo',
  'es-cl',
  'es-co',
  'es-cr',
  'es-do',
  'es-ec',
  'es-gt',
  'es-hn',
  'es-mx',
  'es-ni',
  'es-pa',
  'es-pe',
  'es-pr',
  'es-py',
  'es-sv',
  'es-uy',
  'es-ve',
  'et',
  'et-ee',
  'fa',
  'fi',
  'fo',
  'fr',
  'fr-mc',
  'gl',
  'gu',
  'he',
  'hi',
  'hr',
  'ba',
  'hu',
  'hy',
  'id',
  'is',
  'it',
];