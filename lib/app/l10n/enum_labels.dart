import 'package:flutter/widgets.dart';

import 'package:new_football/core/models/enums.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

String seasonPhaseLabel(BuildContext context, SeasonPhase phase) {
  final l10n = AppLocalizations.of(context)!;
  return switch (phase) {
    SeasonPhase.preseason => l10n.seasonPhase_preseason,
    SeasonPhase.regular => l10n.seasonPhase_regular,
    SeasonPhase.playIn => l10n.seasonPhase_playIn,
    SeasonPhase.playoff => l10n.seasonPhase_playoff,
    SeasonPhase.draft => l10n.seasonPhase_draft,
    SeasonPhase.offseason => l10n.seasonPhase_offseason,
  };
}

/// Maps a `CalendarEventSlot.id` to its display label.
String? calendarEventLabel(BuildContext context, String eventId) {
  final l10n = AppLocalizations.of(context)!;
  return switch (eventId) {
    // TODO: brak dedykowanego klucza l10n — dodać do app_*.arb.
    'staffGrowth' => 'Rozwój i emerytury sztabu',
    'awards' => l10n.calendar_event_awards,
    'retirements' => l10n.calendar_event_retirements,
    'lottery' => l10n.calendar_event_draftLottery,
    'scoutReport' => l10n.calendar_event_scoutReport,
    'combine' => l10n.calendar_event_combine,
    'finalMock' => l10n.calendar_event_mockDraft,
    'draft' => l10n.calendar_event_draft,
    // TODO: brak dedykowanego klucza l10n — dodać do app_*.arb.
    'nextClassGeneration' => 'Generacja nowej klasy draftowej',
    'freeAgencyOpen' => l10n.calendar_event_freeAgency,
    'tradeDeadline' => l10n.calendar_event_tradeDeadline,
    _ => null,
  };
}

String matchEventLabel(BuildContext context, MatchEventType type) {
  final l10n = AppLocalizations.of(context)!;
  return switch (type) {
    MatchEventType.goal => l10n.matchEvent_goal,
    MatchEventType.yellowCard => l10n.matchEvent_yellowCard,
    MatchEventType.redCard => l10n.matchEvent_redCard,
    MatchEventType.minorInjury => l10n.matchEvent_minorInjury,
    MatchEventType.majorInjury => l10n.matchEvent_majorInjury,
    MatchEventType.substitution => l10n.matchEvent_substitution,
    MatchEventType.scoredPenalty => l10n.matchEvent_scoredPenalty,
    MatchEventType.missedPenalty => l10n.matchEvent_missedPenalty,
    MatchEventType.halfTime => l10n.matchEvent_halfTime,
    MatchEventType.fullTime => l10n.matchEvent_fullTime,
  };
}

String messageTypeLabel(BuildContext context, MessageType type) {
  final l10n = AppLocalizations.of(context)!;
  return switch (type) {
    MessageType.injury => l10n.messageType_injury,
    MessageType.retirementPlayer => l10n.messageType_retirementPlayer,
    MessageType.retirementStaff => l10n.messageType_retirementStaff,
    MessageType.staffGrowth => l10n.messageType_staffGrowth,
    MessageType.award => l10n.messageType_award,
    MessageType.lottery => l10n.messageType_lottery,
    MessageType.scoutReport => l10n.messageType_scoutReport,
    MessageType.combine => l10n.messageType_combine,
    MessageType.mockDraft => l10n.messageType_mockDraft,
    MessageType.draftPick => l10n.messageType_draftPick,
    MessageType.contractOffer => l10n.messageType_contractOffer,
    MessageType.contractSigned => l10n.messageType_contractSigned,
    MessageType.trade => l10n.messageType_trade,
    MessageType.walkover => l10n.messageType_walkover,
    MessageType.matchPreview => l10n.messageType_matchPreview,
    MessageType.matchResult => l10n.messageType_matchResult,
    MessageType.atmosphere => l10n.messageType_atmosphere,
    MessageType.calendar => l10n.messageType_calendar,
    MessageType.system => l10n.messageType_system,
  };
}

String notificationLevelLabel(BuildContext context, NotificationLevel level) {
  final l10n = AppLocalizations.of(context)!;
  return switch (level) {
    NotificationLevel.important => l10n.notificationLevel_important,
    NotificationLevel.normal => l10n.notificationLevel_normal,
    NotificationLevel.muted => l10n.notificationLevel_muted,
  };
}

String tempoLabel(BuildContext context, Tempo tempo) {
  final l10n = AppLocalizations.of(context)!;
  return switch (tempo) {
    Tempo.slow => l10n.tempo_slow,
    Tempo.balanced => l10n.tempo_balanced,
    Tempo.fast => l10n.tempo_fast,
  };
}

String pressingLabel(BuildContext context, PressingIntensity pressing) {
  final l10n = AppLocalizations.of(context)!;
  return switch (pressing) {
    PressingIntensity.low => l10n.pressing_low,
    PressingIntensity.medium => l10n.pressing_medium,
    PressingIntensity.high => l10n.pressing_high,
    PressingIntensity.gegenpressing => l10n.pressing_gegenpressing,
  };
}

String defensiveLineLabel(BuildContext context, DefensiveLine line) {
  final l10n = AppLocalizations.of(context)!;
  return switch (line) {
    DefensiveLine.deep => l10n.defensiveLine_deep,
    DefensiveLine.normal => l10n.defensiveLine_normal,
    DefensiveLine.high => l10n.defensiveLine_high,
  };
}

String attackWidthLabel(BuildContext context, AttackWidth width) {
  final l10n = AppLocalizations.of(context)!;
  return switch (width) {
    AttackWidth.narrow => l10n.attackWidth_narrow,
    AttackWidth.balanced => l10n.attackWidth_balanced,
    AttackWidth.wide => l10n.attackWidth_wide,
  };
}

String staffRoleLabel(BuildContext context, StaffRole role) {
  final l10n = AppLocalizations.of(context)!;
  return switch (role) {
    StaffRole.headCoach => l10n.staffRole_headCoach,
    StaffRole.youthCoach => l10n.staffRole_youthCoach,
    StaffRole.scout => l10n.staffRole_scout,
    StaffRole.physio => l10n.staffRole_physio,
    StaffRole.doctor => l10n.staffRole_doctor,
    StaffRole.cfo => l10n.staffRole_cfo,
  };
}

String dayName(BuildContext context, int weekday1to7) {
  final l10n = AppLocalizations.of(context)!;
  return switch (weekday1to7) {
    1 => l10n.day_mon,
    2 => l10n.day_tue,
    3 => l10n.day_wed,
    4 => l10n.day_thu,
    5 => l10n.day_fri,
    6 => l10n.day_sat,
    _ => l10n.day_sun,
  };
}
