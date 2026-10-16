import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/message_text_service.dart';
import 'package:new_football/core/services/negotiation_service.dart';
import 'package:new_football/core/services/staff_service.dart';

import 'support/game_fixtures.dart';

bool _scoreFits(double score, String kind) => switch (kind) {
  'reject' => score > 24 && score <= 39,
  'counter' => score >= 40 && score <= 54,
  _ => score >= 70,
};

ContractOffer _playerOffer(Player player, String kind) {
  final service = ContractService();
  final cap = BalanceConfig.defaults.salaryCap;
  for (var years = 1; years <= 4; years++) {
    for (var i = 0; i <= 200; i++) {
      final offer = ContractOffer(
        salary: cap.minSalary + (cap.maxSalary - cap.minSalary) * i ~/ 200,
        years: years,
      );
      if (_scoreFits(service.playerOfferScore(player, offer), kind)) {
        return offer;
      }
    }
  }
  throw StateError('No player offer in $kind band');
}

StaffOffer _staffOffer(StaffMember member, String kind) {
  final service = StaffService();
  final balance = BalanceConfig.defaults.staff;
  for (var years = 1; years <= 4; years++) {
    for (var i = 0; i <= 200; i++) {
      final offer = StaffOffer(
        salary:
            balance.minSalary +
            (balance.maxSalary - balance.minSalary) * i ~/ 200,
        years: years,
      );
      if (_scoreFits(service.staffOfferScore(member, offer), kind)) {
        return offer;
      }
    }
  }
  throw StateError('No staff offer in $kind band');
}

void _renders(GameMessage message, String name) {
  for (final language in ['pl', 'en']) {
    final text = MessageTextService.resolve(message, languageCode: language);
    expect(text.title, isNotEmpty);
    expect(text.body, contains(name));
    expect(text.body, isNot(contains('{')));
    expect(text.body, isNot(contains('null')));
  }
}

void main() {
  for (final kind in ['reject', 'counter', 'accept']) {
    test('player $kind and finalization render in both languages', () {
      final league = controllerSave().leagueState;
      final player = league.freeAgents.single;
      final market = ContractMarketService();
      final response = market.submitPlayerOffer(
        league: league,
        playerId: player.id,
        offer: _playerOffer(player, kind),
        saveSeed: fixtureSeed,
      )!;
      expect(response.reaction.name, kind);
      final record = response.league.negotiations.single;
      final message = response.league.inbox.messages.last;
      _renders(message, player.name);
      if (kind == 'counter') {
        expect(message.args['salary'], record.counterOffer!.salary);
        expect(message.args['years'], record.counterOffer!.years);
      }
      if (kind == 'accept') {
        final signed = market.finalizeNegotiation(
          response.league,
          record.id,
          saveSeed: fixtureSeed,
        )!;
        expect(signed.playerTeam!.roster.any((p) => p.id == player.id), isTrue);
        _renders(signed.inbox.messages.last, player.name);
      }
    });
    test('staff $kind and finalization render in both languages', () {
      final base = controllerSave().leagueState;
      final candidate = beforeRollover().staffFreeAgents.single.copyWith(
        age: 40,
        attributes: const StaffAttributes(coverage: 3, evaluation: 3),
      );
      final league = base.copyWith(staffFreeAgents: [candidate]);
      final market = ContractMarketService();
      final response = market.submitStaffOffer(
        league: league,
        candidate: candidate,
        offer: _staffOffer(candidate, kind),
        saveSeed: fixtureSeed,
      )!;
      expect(response.reaction.name, kind);
      final record = response.league.negotiations.single;
      final message = response.league.inbox.messages.last;
      _renders(message, candidate.name);
      if (kind == 'counter') {
        expect(message.args['salary'], record.counterOffer!.salary);
        expect(message.args['years'], record.counterOffer!.years);
      }
      if (kind == 'accept') {
        final signed = market.finalizeNegotiation(
          response.league,
          record.id,
          saveSeed: fixtureSeed,
        )!;
        expect(signed.playerTeam!.staff.scout!.id, candidate.id);
        _renders(signed.inbox.messages.last, candidate.name);
      }
    });
  }
  test(
    'submitted QO confirms the recorded terms without a second decision',
    () {
      final base = controllerSave().leagueState;
      final player = base.freeAgents.single.copyWith(
        contract: base.freeAgents.single.contract.copyWith(
          isRookieScale: true,
          salary: 1000000,
          rookiePickSlot: 1,
        ),
      );
      final league = base.copyWith(freeAgents: [player]);
      final result = ContractMarketService().submitQualifyingOffer(
        league: league,
        ownerTeamId: league.playerTeamId!,
        playerId: player.id,
      )!;
      final message = result.inbox.messages.last;
      _renders(message, player.name);
      expect(message.args['salary'], result.rfaQualifyingOffers.single.salary);
      expect(message.decision, isNull);
      expect(message.expiresAt, isNull);
    },
  );
  for (final kind in ['reject', 'counter']) {
    test('a waiting staff member resolves to $kind with role and terms', () {
      final base = controllerSave().leagueState;
      final member = beforeRollover().staffFreeAgents.single.copyWith(
        age: 40,
        attributes: const StaffAttributes(coverage: 3, evaluation: 3),
      );
      final offer = _staffOffer(member, kind);
      final record = const NegotiationService()
          .start(
            id: 'waiting-staff',
            subjectId: member.id,
            subjectKind: NegotiationSubjectKind.staff,
            teamId: base.playerTeamId!,
            phase: NegotiationPhase.freeAgencyPhaseII,
            offer: NegotiationOffer(salary: offer.salary, years: offer.years),
            seasonYear: 2026,
            week: 1,
          )
          .copyWith(
            status: NegotiationStatus.waiting,
            waitingUntilSeasonYear: 2026,
            waitingUntilWeek: 1,
            waitingUntilDay: 1,
            waitingUntilHour: 0,
          );
      final result = ContractMarketService().resolveDay(
        base.copyWith(negotiations: [record], staffFreeAgents: [member]),
        saveSeed: fixtureSeed,
      );
      expect(result.inbox.messages.last.kind, kind);
      _renders(result.inbox.messages.last, member.name);
      expect(result.inbox.messages.last.args['staffRole'], member.role.name);
    });
    test('a waiting player resolves to $kind with complete message data', () {
      final base = controllerSave().leagueState;
      final player = base.freeAgents.single;
      final offer = _playerOffer(player, kind);
      final record = const NegotiationService()
          .start(
            id: 'waiting-player',
            subjectId: player.id,
            subjectKind: NegotiationSubjectKind.player,
            teamId: base.playerTeamId!,
            phase: NegotiationPhase.freeAgencyPhaseII,
            offer: NegotiationOffer(salary: offer.salary, years: offer.years),
            seasonYear: 2026,
            week: 1,
          )
          .copyWith(
            status: NegotiationStatus.waiting,
            waitingUntilSeasonYear: 2026,
            waitingUntilWeek: 1,
            waitingUntilDay: 1,
            waitingUntilHour: 0,
          );
      final result = ContractMarketService().resolveDay(
        base.copyWith(negotiations: [record]),
        saveSeed: fixtureSeed,
      );
      expect(result.inbox.messages.last.kind, kind);
      _renders(result.inbox.messages.last, player.name);
    });
  }
}
