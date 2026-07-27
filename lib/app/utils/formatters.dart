import 'package:flutter/widgets.dart';

import 'package:new_football/l10n/generated/app_localizations.dart';

String formatMoney(BuildContext context, int amount) {
  final l10n = AppLocalizations.of(context)!;
  final abs = amount.abs();
  if (abs >= 1000000) {
    return l10n.money_million((amount / 1000000).toStringAsFixed(1));
  }
  if (abs >= 1000) {
    return l10n.money_thousand((amount / 1000).toStringAsFixed(0));
  }
  return '$amount';
}
