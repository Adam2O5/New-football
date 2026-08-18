import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/trade_models.dart';

part 'league_state.freezed.dart';
part 'league_state.g.dart';

@freezed
abstract class LeagueState with _$LeagueState {
  const factory LeagueState({
    required List<Team> teams,
    required Season currentSeason,
    @Default([]) List<SeasonHistory> history,
    String? playerTeamId,
    @Default(0) int currentRound,
    @Default(1) int currentWeek,

    /// 1 = Monday … 7 = Sunday within [currentWeek].
    @Default(1) int currentDay,

    /// Hourly contract mode clock. Null outside extensions/FA phase I;
    /// otherwise 1–10 identifies the current offer slot.
    int? currentHour,
    @Default(false) bool hourlyPlayerOfferUsed,
    @Default(false) bool hourlyStaffOfferUsed,
    @Default(Inbox()) Inbox inbox,
    @Default(MessageSettings()) MessageSettings messageSettings,

    /// Sztab bez klubu — pula dostępna do zatrudnienia (`docs/staff_rules.md`).
    @Default([]) List<StaffMember> staffFreeAgents,

    /// Zawodnicy bez klubu — niedraftowani + wygasłe kontrakty
    /// (`docs/contract_signing.md`, `docs/offseason.md`).
    @Default([]) List<Player> freeAgents,

    /// Tabela siły ligi (`team_management.md`). Jedno źródło prawdy dla
    /// `teamStatus`, `expectedRank` i `teamPower` wszystkich 30 drużyn.
    /// `null` = jeszcze nie przeliczona (zostanie obliczona przy pierwszym
    /// `shouldRecalculate` w `DaySimulator`).
    LeagueStrengthTable? strengthTable,

    /// Persistent player/staff negotiation records. A score reaction is not
    /// enough to reconstruct deadlines, counters or finalization after load.
    @Default([]) List<ContractNegotiation> negotiations,

    /// Temporary subject × club blocks created by hard rejects or expired
    /// finalization windows.
    @Default([]) List<NegotiationBlock> negotiationBlocks,

    /// Completed and rejected trade attempts. Only accepted entries affect
    /// draft-pick Stepien validation; other outcomes remain for the history UI.
    @Default([]) List<TradeHistoryEntry> tradeHistory,

    /// Active and terminal offer records for trade/counter threads.
    @Default([]) List<TradeOffer> tradeOffers,

    /// Temporary player × destination blocks created by NTC refusals.
    @Default([]) List<NtcTradeBlock> ntcTradeBlocks,

    /// Drafted players under team control but not yet signed. Rights are not
    /// roster entries and therefore do not affect roster size or matchday.
    @Default([]) List<DraftedPlayerRights> draftedRights,

    /// Explicit RFA state. A player has matching rights only while a
    /// qualifying offer is present in this list.
    @Default([]) List<RfaQualifyingOffer> rfaQualifyingOffers,
    @Default([]) List<RfaOfferSheet> rfaOfferSheets,
  }) = _LeagueState;

  factory LeagueState.fromJson(Map<String, dynamic> json) =>
      _$LeagueStateFromJson(json);
}

extension LeagueStateX on LeagueState {
  Team? get playerTeam {
    if (playerTeamId == null) return null;
    return teams.firstWhere((t) => t.id == playerTeamId);
  }

  Team? teamById(String id) {
    try {
      return teams.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Team> teamsInConference(Conference conference) =>
      teams.where((t) => t.conference == conference).toList();

  LeagueState updateTeam(Team team) {
    return copyWith(
      teams: teams.map((t) => t.id == team.id ? team : t).toList(),
    );
  }

  ContractNegotiation? negotiationById(String id) {
    for (final negotiation in negotiations) {
      if (negotiation.id == id) return negotiation;
    }
    return null;
  }

  LeagueState upsertNegotiation(ContractNegotiation negotiation) {
    return copyWith(
      negotiations: [
        ...negotiations.where((item) => item.id != negotiation.id),
        negotiation,
      ],
    );
  }

  LeagueState upsertTradeOffer(TradeOffer offer) {
    return copyWith(
      tradeOffers: [...tradeOffers.where((item) => item.id != offer.id), offer],
    );
  }

  TradeOffer? tradeOfferById(String id) {
    for (final offer in tradeOffers) {
      if (offer.id == id) return offer;
    }
    return null;
  }

  List<TradeOffer> get activeTradeOffers =>
      tradeOffers.where((offer) => !offer.isTerminal).toList();

  LeagueState addNegotiationBlock(NegotiationBlock block) {
    return copyWith(
      negotiationBlocks: [
        ...negotiationBlocks.where(
          (item) =>
              !(item.subjectId == block.subjectId &&
                  item.subjectKind == block.subjectKind &&
                  item.teamId == block.teamId),
        ),
        block,
      ],
    );
  }
}
