import 'package:new_football/core/models/enums.dart';

/// Parameters used when creating a new game and its initial squads.
class SeedBalance {
  const SeedBalance({
    this.rosterFormationCopies = 2,
    this.rosterExtraPositions = const [
      Position.gk,
      Position.cb,
      Position.cm,
      Position.st,
    ],
    this.gkAttributeOffsetMin = -2,
    this.gkAttributeOffsetMax = 2,
    this.potentialRoundingSteps = 2,
    this.salaryOvrBase = 50,
    this.salaryOvrScale = 2,
    this.salaryOvrDivisor = 100,
    this.salaryExponent = 3,
    this.initialContractYearsMin = 1,
    this.initialContractYearsMax = 4,
    this.playerFormMin = 3,
    this.playerFormMax = 8,
    this.prospectFormMin = 1,
    this.prospectFormMax = 10,
    this.youngProgressMaxAge = 26,
    this.youngProgressMin = 40,
    this.youngProgressMax = 89,
    this.matureProgressMin = 0,
    this.matureProgressMax = 29,
    this.prospectProgressMin = 40,
    this.prospectProgressMax = 89,
    this.initialProgressMin = 0.0,
    this.initialProgressMax = 99.0,
    this.freeAgentCountMin = 25,
    this.freeAgentCountMax = 35,
    this.freeAgentOvrMin = 73,
    this.freeAgentOvrMax = 78,
    this.freeAgentAgeMin = 22,
    this.freeAgentAgeMax = 32,
    this.freeAgentPotentialMin = 2.5,
    this.freeAgentPotentialMax = 4.0,
    this.staffAgeMin = 35,
    this.staffAgeMax = 50,
    this.draftGkEligibleSlots = 3,
    this.scoutGradeOffsetMin = -4,
    this.scoutGradeOffsetMax = 3,
    this.combineOffsetMin = -6,
    this.combineOffsetMax = 5,
    this.defaultHeightRange = (160, 190),
    this.heightRanges = const {
      Position.gk: (175, 200),
      Position.cb: (175, 200),
      Position.st: (170, 195),
      Position.cdm: (170, 195),
    },
    this.attributeOffsets = defaultAttributeOffsets,
    this.potentialProfiles = defaultPotentialProfiles,
    this.draftProfiles = defaultDraftProfiles,
    this.staffStarWeights = defaultStaffStarWeights,

    this.startYear = defaultStartYear,
    this.rosterProfiles = defaultRosterProfiles,
    this.initialStaff = defaultInitialStaff,
    this.staffPoolSize = 90,
  });

  final int rosterFormationCopies;
  final List<Position> rosterExtraPositions;
  final int gkAttributeOffsetMin;
  final int gkAttributeOffsetMax;
  final int potentialRoundingSteps;
  final int salaryOvrBase;
  final int salaryOvrScale;
  final int salaryOvrDivisor;
  final int salaryExponent;
  final int initialContractYearsMin;
  final int initialContractYearsMax;
  final int playerFormMin;
  final int playerFormMax;
  final int prospectFormMin;
  final int prospectFormMax;
  final int youngProgressMaxAge;
  final int youngProgressMin;
  final int youngProgressMax;
  final int matureProgressMin;
  final int matureProgressMax;
  final int prospectProgressMin;
  final int prospectProgressMax;
  final double initialProgressMin;
  final double initialProgressMax;
  final int freeAgentCountMin;
  final int freeAgentCountMax;
  final int freeAgentOvrMin;
  final int freeAgentOvrMax;
  final int freeAgentAgeMin;
  final int freeAgentAgeMax;
  final double freeAgentPotentialMin;
  final double freeAgentPotentialMax;
  final int staffAgeMin;
  final int staffAgeMax;
  final int draftGkEligibleSlots;
  final int scoutGradeOffsetMin;
  final int scoutGradeOffsetMax;
  final int combineOffsetMin;
  final int combineOffsetMax;
  final (int min, int max) defaultHeightRange;
  final Map<Position, (int min, int max)> heightRanges;
  final Map<int, (int lo, int hi)> attributeOffsets;
  final List<(int ageMax, List<(int ovrMax, double starMin, double starMax)>)>
  potentialProfiles;
  final List<
    (int count, int ovrMin, int ovrMax, double starMin, double starMax)
  >
  draftProfiles;
  final List<(double stars, double probability)> staffStarWeights;

  static const defaultStartYear = 2026;
  final int startYear;
  final List<(int ovr, int ageMin, int ageMax)> rosterProfiles;
  final List<(double stars, int years, int salary)> initialStaff;
  final int staffPoolSize;

  static const defaultRosterProfiles = [
    (85, 27, 30),
    (85, 27, 30),
    (84, 32, 35),
    (82, 23, 26),
    (82, 23, 26),
    (81, 23, 24),
    (80, 27, 32),
    (80, 27, 32),
    (79, 27, 32),
    (79, 27, 32),
    (79, 23, 26),
    (79, 33, 40),
    (77, 27, 32),
    (77, 27, 32),
    (77, 27, 32),
    (77, 23, 26),
    (77, 23, 26),
    (77, 33, 40),
    (75, 18, 22),
    (75, 18, 22),
    (73, 27, 32),
    (72, 33, 40),
    (70, 38, 40),
    (68, 18, 22),
    (66, 18, 22),
    (63, 18, 22),
  ];
  static const defaultInitialStaff = [
    (2.0, 1, 750000),
    (2.0, 1, 750000),
    (2.0, 1, 750000),
    (2.5, 1, 1000000),
    (3.0, 2, 1500000),
    (3.5, 2, 2000000),
  ];

  static const Map<int, (int lo, int hi)> defaultAttributeOffsets = {
    5: (-18, -13),
    8: (-8, -5),
    10: (-6, -3),
    12: (-4, -2),
    14: (-3, 0),
    15: (-2, 0),
    18: (0, 1),
    20: (-1, 1),
    25: (2, 3),
    28: (3, 4),
    30: (3, 4),
    35: (4, 6),
    40: (3, 5),
  };

  static const List<
    (int ageMax, List<(int ovrMax, double starMin, double starMax)>)
  >
  defaultPotentialProfiles = [
    (
      22,
      [
        (59, 2.0, 3.0),
        (69, 3.5, 4.5),
        (77, 3.0, 4.0),
        (83, 3.5, 4.5),
        (89, 4.5, 5.0),
        (95, 5.0, 5.0),
      ],
    ),
    (
      26,
      [
        (59, 2.0, 2.5),
        (69, 3.0, 4.0),
        (77, 3.0, 3.5),
        (83, 3.5, 4.0),
        (89, 4.5, 5.0),
        (95, 5.0, 5.0),
      ],
    ),
    (
      32,
      [
        (59, 1.0, 2.0),
        (69, 2.0, 3.5),
        (77, 2.5, 3.0),
        (83, 3.0, 4.0),
        (89, 4.5, 4.5),
        (95, 5.0, 5.0),
      ],
    ),
    (
      40,
      [
        (59, 0.5, 1.5),
        (69, 1.5, 2.5),
        (77, 2.5, 3.0),
        (83, 3.0, 3.5),
        (89, 4.5, 4.5),
        (95, 5.0, 5.0),
      ],
    ),
  ];

  static const List<
    (int count, int ovrMin, int ovrMax, double starMin, double starMax)
  >
  defaultDraftProfiles = [
    (3, 77, 79, 4.0, 5.0),
    (8, 74, 76, 3.5, 4.5),
    (12, 70, 73, 3.5, 4.0),
    (10, 65, 75, 3.0, 4.5),
    (20, 66, 69, 3.0, 3.5),
    (20, 62, 65, 2.5, 3.0),
    (20, 58, 61, 2.0, 2.5),
    (27, 58, 79, 2.0, 5.0),
  ];

  static const List<(double stars, double probability)>
  defaultStaffStarWeights = [
    (0.5, 0.10),
    (1.0, 0.10),
    (1.5, 0.10),
    (2.0, 0.15),
    (2.5, 0.20),
    (3.0, 0.15),
    (3.5, 0.10),
    (4.0, 0.06),
    (4.5, 0.03),
    (5.0, 0.01),
  ];
}
