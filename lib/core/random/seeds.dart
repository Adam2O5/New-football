import 'dart:convert';

/// Kinds of deterministic AI decisions.
enum DecisionType {
  lineup,
  formation,
  tactics,
  subs,
  tradeEval,
  tradeInit,
  faOffer,
  extension,
  draftPick,
  scoutAssign,
  eventResolve,
  rosterFix,
}

/// Returns the deterministic seed for one match in a save.
int matchSeed(int saveSeed, int seasonYear, String matchId) {
  return _stableHash(['match', saveSeed, seasonYear, matchId]);
}

/// Returns the deterministic seed for one AI decision in a save.
int aiSeed(
  int saveSeed,
  int seasonYear,
  int week,
  String teamId,
  DecisionType decisionType,
) {
  return _stableHash([
    'ai',
    saveSeed,
    seasonYear,
    week,
    teamId,
    decisionType.name,
  ]);
}

/// Returns a deterministic seed for one individual-player event roll.
///
/// The player id and event kind are part of the key, so changing roster order
/// or adding another event cannot silently change an existing result.
int playerEventSeed(
  int saveSeed,
  int seasonYear,
  int week,
  String playerId,
  String eventKind, {
  int salt = 0,
}) {
  return _stableHash([
    'player-event',
    saveSeed,
    seasonYear,
    week,
    playerId,
    eventKind,
    salt,
  ]);
}

int teamEventSeed(
  int saveSeed,
  int seasonYear,
  int week,
  String teamId,
  String eventKind, {
  String? playerId,
  int salt = 0,
}) {
  return _stableHash([
    'team-event',
    saveSeed,
    seasonYear,
    week,
    teamId,
    eventKind,
    playerId ?? '',
    salt,
  ]);
}

/// A stable 31-bit FNV-1a hash.
///
/// [Object.hash] is deliberately avoided here: seeds are persisted game
/// contracts and must not depend on the runtime's hash implementation.
int _stableHash(List<Object?> parts) {
  var hash = 2166136261;
  for (final part in parts) {
    for (final byte in utf8.encode('$part\u001f')) {
      hash ^= byte;
      hash = (hash * 16777619) & 0x7fffffff;
    }
  }
  return hash;
}
