import 'enums.dart';

String seedTeamId(Conference conference, int index) =>
    'team_${conference.name}_$index';

final seedTeamCatalog =
    List<
      ({String id, String name, String city, Conference conference})
    >.unmodifiable([
      for (var i = 0; i < europeTeams.length; i++)
        (
          id: seedTeamId(Conference.europe, i),
          name: europeTeams[i].$2,
          city: europeTeams[i].$1,
          conference: Conference.europe,
        ),
      for (var i = 0; i < restOfTheWorldTeams.length; i++)
        (
          id: seedTeamId(Conference.restOfTheWorld, i + europeTeams.length),
          name: restOfTheWorldTeams[i].$2,
          city: restOfTheWorldTeams[i].$1,
          conference: Conference.restOfTheWorld,
        ),
    ]);

const europeTeams = [
  ('Warsaw', 'Syrenka FC'),
  ('Paris', 'Eiffel Town'),
  ('Marseille', 'Marseille CF'),
  ('Madrid', 'Madrid Royals'),
  ('Barcelona', 'Gaudi Athletic'),
  ('London', 'London Rovers'),
  ('Manchester', 'Manchester Wanderers'),
  ('Liverpool', 'Mersey United'),
  ('Berlin', 'Berlin Bears'),
  ('Brussels', 'Brussels City'),
  ('Amsterdam', 'Amsterdam Club'),
  ('Lisbon', 'Lisbon FC'),
  ('Rome', 'Rome Eagles'),
  ('Milan', 'Lombardy Milan'),
  ('Neapol', 'Neapol Athletic'),
];

const restOfTheWorldTeams = [
  ('Sao Paulo', 'Sao Paulo FC'),
  ('Rio de Janeiro', 'Joga Bonito CF'),
  ('Buenos Aires', 'Buenos Aires Wanderers'),
  ('Tokyo', 'Tokyo Emperors'),
  ('New York City', 'Liberty New York'),
  ('Los Angeles', 'Hollywood FC'),
  ('Chicago', 'Chicago Wanderers'),
  ('Philadelphia', 'Philadelphia Warriors'),
  ('Kyoto', 'Kyoto Samurais'),
  ('Shanghai', 'Shanghai Dragons'),
  ('Beijing', 'Imperial Beijing'),
  ('Mexico City', 'Mexico City SC'),
  ('Casablanca', 'Dynamo Casablanca'),
  ('Cairo', 'Cairo United'),
  ('Lagos', 'Lagos Rovers'),
];
