import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/prospect.dart';

part 'draft_class.freezed.dart';
part 'draft_class.g.dart';

@freezed
abstract class DraftClass with _$DraftClass {
  const factory DraftClass({
    required int year,
    @Default([]) List<Prospect> prospects,
  }) = _DraftClass;

  factory DraftClass.fromJson(Map<String, dynamic> json) =>
      _$DraftClassFromJson(json);
}

/// Kolejność wyświetlania klasy draftowej (`draft.md` §"Dwa mock drafty"),
/// oddzielna od `DraftState.order` (kolejność picków klubów w loterii).
/// `displayedRank` to aktualnie obowiązujący board (1-based, 1 = najlepszy).
/// `previousDisplayedRank` to board sprzed poprzedniego mocka — pusty po
/// mocku wstępnym (brak punktu odniesienia), wypełniony po mocku finalnym,
/// żeby UI mógł pokazać wskaźnik zmiany pozycji. Klucz w obu mapach to
/// `Prospect.id`.
@freezed
abstract class MockDraftBoard with _$MockDraftBoard {
  const factory MockDraftBoard({
    @Default({}) Map<String, int> displayedRank,
    @Default({}) Map<String, int> previousDisplayedRank,
  }) = _MockDraftBoard;

  factory MockDraftBoard.fromJson(Map<String, dynamic> json) =>
      _$MockDraftBoardFromJson(json);
}
