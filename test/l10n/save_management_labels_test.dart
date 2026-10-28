import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

void main() {
  test(
    'save management has distinct localized actions and date/size labels',
    () async {
      const saveName = 'Localized checkpoint';
      for (final locale in const [Locale('pl'), Locale('en')]) {
        final l10n = await AppLocalizations.delegate.load(locale);
        final labels = [
          l10n.loadGame_loadSemantics(saveName),
          l10n.loadGame_deleteSemantics(saveName),
          l10n.loadGame_duplicateSemantics(saveName),
          l10n.loadGame_renameSemantics(saveName),
        ];
        expect(labels.toSet(), hasLength(4));
        expect(labels, everyElement(isNotEmpty));
        expect(l10n.loadGame_duplicateTooltip, isNotEmpty);
        expect(l10n.loadGame_renameTooltip, isNotEmpty);
        expect(l10n.loadGame_lastSaveDate, isNotEmpty);
        expect(l10n.loadGame_saveSize, isNotEmpty);
      }
    },
  );
}
