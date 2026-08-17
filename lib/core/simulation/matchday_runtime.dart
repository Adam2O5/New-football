/// Failure reasons for runtime-only Task 19 match commands.
enum SimulationActionFailure {
  matchFinished,
  playerNotOnPitch,
  playerNotOnBench,
  playerUnavailable,
  playerCannotReenter,
  substitutionsLimit,
  substitutionWindowsLimit,
  formationChangeOutsideHalfTime,
  invalidHalfTimePhase,
  noAvailableSubstitute,
}

/// Result of a runtime-only substitution or tactics command.
///
/// The production provider does not consume this type yet. It gives the
/// future match UI a stable way to show why a command was accepted or
/// rejected without putting ephemeral command state into MatchState.
class SimulationActionResult {
  const SimulationActionResult({
    required this.accepted,
    this.failure,
    this.message,
  });

  const SimulationActionResult.accepted()
    : accepted = true,
      failure = null,
      message = null;

  const SimulationActionResult.rejected(
    SimulationActionFailure this.failure, {
    this.message,
  }) : accepted = false;

  final bool accepted;
  final SimulationActionFailure? failure;
  final String? message;

  bool get rejected => !accepted;
}
