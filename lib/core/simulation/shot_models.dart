/// Runtime-only shot and goalkeeper categories used by Task 18.
enum SequenceShotKind { distance, box, header, oneOnOne, penalty }

enum ShotOutcome {
  goal,
  goalkeeperError,
  saved,
  offTarget,
  blocked,
  post,
  reboundGoal,
}

enum SetPieceType { corner, directFreeKick, penalty }
