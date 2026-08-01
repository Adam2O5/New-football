import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/balance/balance_config.dart';

part 'draft_pick.freezed.dart';
part 'draft_pick.g.dart';

/// Reprezentuje zarówno slot w bieżącym drafcie (`pickNumber` znany po
/// zbudowaniu kolejności), jak i przyszły, handlowalny pick (`pickNumber`
/// nieznany do czasu loterii/budowy `DraftState.order` dla danego roku).
///
/// [id] jest stały przez cały cykl życia picka — nie zmienia się przy
/// wymianach (`trade_rules.md`), tylko [teamId] (aktualny właściciel).
/// [year] określa rocznik draftu, którego pick dotyczy — niezbędne dla
/// picków przechowywanych poza `DraftState` (`Team.ownedPicks`), zanim
/// zostaną zmaterializowane w kolejności bieżącego sezonu.
/// [originalTeamId] pozostaje niezmienne od momentu utworzenia i jest
/// używane do wyceny (`computeTradeValue`) oraz reguły Stepiena.
@freezed
class DraftPick with _$DraftPick {
  const factory DraftPick({
    required String id,
    required int year,
    required int round,
    int? pickNumber,
    required String teamId,
    required String originalTeamId,
    String? prospectId,
    String? playerName,
    int? protectedTopN,
    @Default(0) int tradeValue,
  }) = _DraftPick;

  factory DraftPick.fromJson(Map<String, dynamic> json) =>
      _$DraftPickFromJson(json);
}

extension DraftPickX on DraftPick {
  /// Wycena handlowa picka (`TradeValueBalance`): pasmo rundy skalowane
  /// prognozowanym miejscem [originalTeamId] w tabeli oraz dyskontowane za
  /// odległość w czasie do [year], w którym pick stanie się realnym
  /// wyborem.
  int computeTradeValue({
    required int currentYear,
    BalanceConfig balance = BalanceConfig.defaults,
  }) {
    final tv = balance.tradeValue;
    final range = tv.rangeForRound(round);
    final finish = tv.projectedFinish(originalTeamId);
    final rankT =
        (tv.leagueTeamsCount - finish) / (tv.leagueTeamsCount - 1);

    final yearsUntilUsable = (year - currentYear).clamp(0, 100);
    final timeDiscount = (1.0 - tv.yearsDecayPerYear * yearsUntilUsable)
        .clamp(tv.minTimeDiscount, 1.0);

    final effectiveT = (rankT * timeDiscount).clamp(0.0, 1.0);
    final value =
        range.valueLow + effectiveT * (range.valueHigh - range.valueLow);
    return value.round();
  }

  /// Przelicza i zapisuje [DraftPick.tradeValue] — wołać po utworzeniu
  /// picka, po wymianie oraz co sezon (prognoza miejsca w tabeli się
  /// zmienia).
  DraftPick recalculateTradeValue({
    required int currentYear,
    BalanceConfig balance = BalanceConfig.defaults,
  }) => copyWith(
    tradeValue: computeTradeValue(currentYear: currentYear, balance: balance),
  );
}
