enum Conference {
  east('European'),
  west('Rest of World');

  const Conference(this.label);
  final String label;
}

enum Position {
  gk('GK'),
  cb('CB'),
  lb('LB'),
  rb('RB'),
  lwb('LWB'),
  rwb('RWB'),
  cdm('CDM'),
  cm('CM'),
  cam('CAM'),
  lw('LW'),
  rw('RW'),
  st('ST');

  const Position(this.code);
  final String code;
}

enum SeasonPhase { preseason, regular, playIn, playoff, draft, offseason }

enum Formation {
  f343('3-4-3'),
  f352('3-5-2'),
  f424('4-2-4'),
  f433('4-3-3'),
  f442Wide('4-4-2 (szerokie)'),
  f442Narrow('4-4-2 (wąskie)'),
  f451Wide('4-5-1 (szerokie)'),
  f451Narrow('4-5-1 (wąskie)'),
  f523('5-2-3'),
  f532('5-3-2'),
  f541Wide('5-4-1 (szerokie)'),
  f541Narrow('5-4-1 (wąskie)');

  const Formation(this.label);
  final String label;
}

enum GkRole {
  standard('A classic goalkeeper focused mainly on stopping shots.'),
  sweeperKeeper(
    'A goalkeeper who actively comes off the line and helps in build-up play.',
  );

  const GkRole(this.description);
  final String description;
}

enum CbRole {
  standard('A versatile centre-back focused on protecting the defense.'),
  ballPlayingDefender(
    'A defender who is comfortable on the ball and starts attacks with passing.',
  ),
  noNonsenseCentreBack(
    'A highly defensive centre-back who clears danger simply and safely.',
  );

  const CbRole(this.description);
  final String description;
}

enum FullBackRole {
  standard(
    'A classic full-back who balances defense with moderate attacking support.',
  ),
  defensiveFullBack(
    'A more conservative full-back who stays deeper and prioritizes defending.',
  ),
  attackingFullBack(
    'An aggressive full-back who pushes high up the pitch and joins the attack often.',
  );

  const FullBackRole(this.description);
  final String description;
}

enum WingBackRole {
  standard('A balanced wing-back who contributes in both defense and attack.'),
  wingBack(
    'A dynamic wide player who works up and down the flank with high energy.',
  ),
  invertedWingBack(
    'A wing-back who drifts inside to help control and build play through the middle.',
  );

  const WingBackRole(this.description);
  final String description;
}

enum CdmRole {
  standard(
    'A classic defensive midfielder who shields the back line and breaks up play.',
  ),
  regista(
    'A deep-lying orchestrator who dictates tempo and distributes the ball.',
  ),
  deepLyingPlaymaker(
    'A deeper playmaker who builds attacks from behind the midfield line.',
  ),
  anchorMan(
    'A holding midfielder who stays disciplined in front of the defense.',
  );

  const CdmRole(this.description);
  final String description;
}

enum CmRole {
  standard(
    'A versatile central midfielder without a highly specialized function.',
  ),
  ballWinning(
    'An aggressive midfielder focused on pressing and winning the ball back.',
  ),
  playmaker(
    'A creative midfielder responsible for key passes and controlling possession.',
  ),
  boxToBox(
    'A midfielder who covers the full pitch and contributes in both defense and attack.',
  ),
  mezzala(
    'A wider, attack-minded central midfielder who exploits half-spaces and supports attacks.',
  );

  const CmRole(this.description);
  final String description;
}

enum CamRole {
  standard(
    'A general attacking midfielder who links play and supports the attack.',
  ),
  playmaker(
    'A creative midfielder who looks for the final pass and controls attacking rhythm.',
  ),
  shadowStriker(
    'An attacking midfielder who makes late runs into the box like a second striker.',
  );

  const CamRole(this.description);
  final String description;
}

enum WingerRole {
  standard('A classic balanced winger.'),
  invertedWinger(
    'A wide player who cuts inside and is more likely to shoot than cross.',
  ),
  winger(
    'A natural wide attacker who relies on dribbling and crossing from the flank.',
  );

  const WingerRole(this.description);
  final String description;
}

enum StrikerRole {
  standard('A basic striker focused on finishing chances.'),
  falseNine('A striker who drops deeper to create space for others.'),
  deepLyingForward(
    'A striker who links play and helps bring teammates into attack.',
  ),
  pressingForward(
    'A striker who presses defenders aggressively and forces mistakes.',
  ),
  completeForward(
    'A highly versatile striker capable of contributing in many phases of play.',
  );

  const StrikerRole(this.description);
  final String description;
}

enum Nationality {
  poland('POL', 'Poland'),
  brazil('BRA', 'Brazil'),
  france('FRA', 'France'),
  spain('ESP', 'Spain'),
  england('ENG', 'England'),
  germany('GER', 'Germany'),
  argentina('ARG', 'Argentina'),
  portugal('POR', 'Portugal'),
  italy('ITA', 'Italy'),
  netherlands('NED', 'Netherlands'),
  belgium('BEL', 'Belgium'),
  croatia('CRO', 'Croatia'),
  nigeria('NGA', 'Nigeria'),
  senegal('SEN', 'Senegal'),
  japan('JPN', 'Japan'),
  usa('USA', 'USA'),
  mexico('MEX', 'Mexico'),
  morocco('MAR', 'Morocco'),
  colombia('COL', 'Colombia'),
  switzerland('SUI', 'Switzerland'),
  uruguay('URU', 'Uruguay'),
  egypt('EGY', 'Egypt'),
  china('CHN', 'China');

  const Nationality(this.code, this.label);
  final String code;
  final String label;
}

enum PressingIntensity { low, medium, high, gegenpressing }

enum DefensiveLine { deep, normal, high }

enum AttackWidth { narrow, balanced, wide }

enum Tempo { slow, balanced, fast }

enum CapExceptionType {
  birdRights,
  midLevelException,
  rookieScale,
  tradedPlayerException,
}

enum PlayerPersonality {
  professional('Chance of injury is reduced.'),
  leader('Boosts team chemistry and dressing-room morale.'),
  temperamental('Higher peak performance, but more cards and form swings.'),
  ambitious('Develops faster when challenging for titles or minutes.'),
  loyal('Less likely to demand a trade or reject a contract extension.'),
  balanced('No extreme traits; steady all-round temperament.');

  const PlayerPersonality(this.description);
  final String description;
}

enum ManagerProfile { cautious, balanced, aggressive }

enum MatchEventType {
  goal,
  yellowCard,
  redCard,
  minorInjury,
  majorInjury,
  substitution,
  scoredPenalty,
  missedPenalty,
  halfTime,
  fullTime,
}

enum PlayoffRound {
  conferenceQuarter,
  conferenceSemi,
  conferenceFinal,
  leagueFinal,
}

enum Difficulty { easy, normal, hard }

enum StaffRole { headCoach, youthCoach, scout, physio, doctor, cfo }

enum MessageType {
  injury,
  retirementPlayer,
  retirementStaff,
  staffGrowth,
  award,
  lottery,
  scoutReport,
  combine,
  mockDraft,
  draftPick,
  contractOffer,
  contractSigned,
  trade,
  walkover,
  matchPreview,
  matchResult,
  atmosphere,
  calendar,
  system,
}

enum MessagePriority { normal, urgent }

enum NotificationLevel { important, normal, muted }

enum InjuryType { minor, major }

enum DevelopmentOutcome { exceed, hit, under }

enum Weather { clear, rain, snow, heat }

// 1-5 poziom wiedzy scouta o prospectcie
enum ScoutingTier { tier1, tier2, tier3, tier4, tier5 }

/// Estymowany slot draftu wg scouta (mock finalny).
enum EstimatedDraftSlot { top1, top3, top5, top10, r1, r2, r3, x }

enum TeamOfSeasonSlot { gk, lb, cb1, cb2, rb, mid1, mid2, mid3, lw, st, rw }
