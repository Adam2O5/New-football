import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/field_player_attributes.dart';
import 'package:new_football/core/models/goalkeeper_attributes.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/team.dart';

/// Every natural position plus midfield duplicates for sorting ties.
/// Attribute and role unions remain coherent.
/// Presentation tests vary the relevant fields themselves; no league is generated.
Team presentationTeam() => Team(
  id: 'presentation-team',
  name: 'Presentation FC',
  city: 'Fixture',
  conference: Conference.europe,
  finance: const TeamFinance(salaryCap: 100000000),
  roster: [
    for (final (index, position) in [
      ...Position.values,
      Position.cm,
      Position.cm,
    ].indexed)
      Player(
        id: 'presentation-$index-${position.name}',
        name: 'Fixture ${position.name}',
        position: position,
        nationality: Nationality.poland,
        age: 25,
        attributes: position == Position.gk
            ? PlayerAttributes.goalkeeper(
                stats: GoalkeeperAttributes(
                  diving: 60 + (index % 5) * 4,
                  handling: 60 + (index % 5) * 4,
                  kicking: 60 + (index % 5) * 4,
                  reflexes: 60 + (index % 5) * 4,
                  speed: 60 + (index % 5) * 4,
                  positioning: 60 + (index % 5) * 4,
                ),
              )
            : PlayerAttributes.outfield(
                stats: FieldPlayerAttributes(
                  pace: 60 + (index % 5) * 4,
                  shooting: 60 + (index % 5) * 4,
                  passing: 60 + (index % 5) * 4,
                  dribbling: 60 + (index % 5) * 4,
                  defending: 60 + (index % 5) * 4,
                  physicality: 60 + (index % 5) * 4,
                ),
              ),
        contract: const Contract(
          salary: 1000000,
          yearsRemaining: 2,
          firstSeason: 2026,
          lastSeason: 2027,
        ),
        personality: PlayerPersonality.leader,
        potentialStars: 3,
        heightCm: 180,
        state: PlayerState(role: position.defaultAssignedRole),
        hidden: const PlayerHidden(
          injuryProne: 3,
          determination: 5,
          developmentOutcome: DevelopmentOutcome.hit,
        ),
        optimalRole: position.defaultAssignedRole,
      ),
  ],
);
