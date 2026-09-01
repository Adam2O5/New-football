import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:new_football/core/models/enums.dart';

/// Mała ikona flagi narodowości zawodnika.
///
/// Dla narodowości z odpowiednikiem ISO 3166-1 alpha-2 korzysta z pakietu
/// `country_flags`. Dla Anglii (brak kodu ISO) renderuje dedykowany asset
/// SVG z `assets/flags/england.svg`.
class NationalityFlagIcon extends StatelessWidget {
  const NationalityFlagIcon(this.nationality, {super.key, this.height = 16});

  final Nationality nationality;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isoCode = nationality.isoCode;
    final width = height * 5 / 3;

    if (isoCode == null) {
      return SvgPicture.asset(
        'assets/flags/england.svg',
        height: height,
        width: width,
        fit: BoxFit.cover,
      );
    }

    return CountryFlag.fromCountryCode(
      isoCode,
      theme: ImageTheme(width: width, height: height),
    );
  }
}
