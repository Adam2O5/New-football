import 'package:new_football/app/branding/club_branding_record.dart';

/// The explicit presentation table for every seeded team.
///
/// The table is intentionally keyed only by the stable team identifier. It
/// does not mirror display names, so preview text can change without changing
/// the selected logo or colours.
abstract final class ClubBrandingData {
  static const List<ClubBrandingRecord> productionRecords =
      <ClubBrandingRecord>[
        ClubBrandingRecord(
          teamId: 'team_europe_0',
          logoAsset: 'assets/images/Syrenka_FC.png',
          primaryColorName: 'Czerwony',
          secondaryColorName: 'Biały',
        ),
        ClubBrandingRecord(
          teamId: 'team_europe_1',
          logoAsset: 'assets/images/Eiffel_Town.png',
          primaryColorName: 'Granatowy',
          secondaryColorName: 'Czerwony',
        ),
        ClubBrandingRecord(
          teamId: 'team_europe_2',
          logoAsset: 'assets/images/Marseille_FC.png',
          primaryColorName: 'Jasnoniebieski',
          secondaryColorName: 'Biały',
        ),
        ClubBrandingRecord(
          teamId: 'team_europe_3',
          logoAsset: 'assets/images/Madrid_Royals.png',
          primaryColorName: 'Złoty',
          secondaryColorName: 'Biały',
        ),
        ClubBrandingRecord(
          teamId: 'team_europe_4',
          logoAsset: 'assets/images/Gaudi_Athletic.png',
          primaryColorName: 'Bordo',
          secondaryColorName: 'Żółty',
        ),
        ClubBrandingRecord(
          teamId: 'team_europe_5',
          logoAsset: 'assets/images/London_Rovers.png',
          primaryColorName: 'Czerwony',
          secondaryColorName: 'Bordo',
        ),
        ClubBrandingRecord(
          teamId: 'team_europe_6',
          logoAsset: 'assets/images/Manchester_Wanderers.png',
          primaryColorName: 'Błękitny',
          secondaryColorName: 'Czerwony',
        ),
        ClubBrandingRecord(
          teamId: 'team_europe_7',
          logoAsset: 'assets/images/Mersey_United.png',
          primaryColorName: 'Zielony',
          secondaryColorName: 'Czerwony',
        ),
        ClubBrandingRecord(
          teamId: 'team_europe_8',
          logoAsset: 'assets/images/Berlin_Bears.png',
          primaryColorName: 'Czarny',
          secondaryColorName: 'Czerwony',
        ),
        ClubBrandingRecord(
          teamId: 'team_europe_9',
          logoAsset: 'assets/images/Brussels_City.png',
          primaryColorName: 'Fioletowy',
          secondaryColorName: 'Złoty',
        ),
        ClubBrandingRecord(
          teamId: 'team_europe_10',
          logoAsset: 'assets/images/Amsterdam_Club.png',
          primaryColorName: 'Pomarańczowy',
          secondaryColorName: 'Czarny',
        ),
        ClubBrandingRecord(
          teamId: 'team_europe_11',
          logoAsset: 'assets/images/Lisbon_FC.png',
          primaryColorName: 'Zielony',
          secondaryColorName: 'Złoty',
        ),
        ClubBrandingRecord(
          teamId: 'team_europe_12',
          logoAsset: 'assets/images/Rome_Eagles.png',
          primaryColorName: 'Bordo',
          secondaryColorName: 'Złoty',
        ),
        ClubBrandingRecord(
          teamId: 'team_europe_13',
          logoAsset: 'assets/images/Lombardy_Milan.png',
          primaryColorName: 'Czerwony',
          secondaryColorName: 'Biały',
        ),
        ClubBrandingRecord(
          teamId: 'team_europe_14',
          logoAsset: 'assets/images/Neapol_Athletic.png',
          primaryColorName: 'Błękitny',
          secondaryColorName: 'Złoty',
        ),
        ClubBrandingRecord(
          teamId: 'team_restOfTheWorld_15',
          logoAsset: 'assets/images/Sao_Paulo_FC.png',
          primaryColorName: 'Czarny',
          secondaryColorName: 'Biały',
        ),
        ClubBrandingRecord(
          teamId: 'team_restOfTheWorld_16',
          logoAsset: 'assets/images/Joga_Bonito_FC.png',
          primaryColorName: 'Żółty',
          secondaryColorName: 'Zielony',
        ),
        ClubBrandingRecord(
          teamId: 'team_restOfTheWorld_17',
          logoAsset: 'assets/images/Buenos_Aires_Wanderers.png',
          primaryColorName: 'Błękitny',
          secondaryColorName: 'Biały',
        ),
        ClubBrandingRecord(
          teamId: 'team_restOfTheWorld_18',
          logoAsset: 'assets/images/Tokyo_Emperors.png',
          primaryColorName: 'Różowy',
          secondaryColorName: 'Złoty',
        ),
        ClubBrandingRecord(
          teamId: 'team_restOfTheWorld_19',
          logoAsset: 'assets/images/Liberty_New_York.png',
          primaryColorName: 'Granatowy',
          secondaryColorName: 'Pomarańczowy',
        ),
        ClubBrandingRecord(
          teamId: 'team_restOfTheWorld_20',
          logoAsset: 'assets/images/Hollywood_FC.png',
          primaryColorName: 'Złoty',
          secondaryColorName: 'Fioletowy',
        ),
        ClubBrandingRecord(
          teamId: 'team_restOfTheWorld_21',
          logoAsset: 'assets/images/Chicago_Aces.png',
          primaryColorName: 'Czerwony',
          secondaryColorName: 'Jasnoniebieski',
        ),
        ClubBrandingRecord(
          teamId: 'team_restOfTheWorld_22',
          logoAsset: 'assets/images/Philadelphia_Warriors.png',
          primaryColorName: 'Ciemnoniebieski',
          secondaryColorName: 'Złoty',
        ),
        ClubBrandingRecord(
          teamId: 'team_restOfTheWorld_23',
          logoAsset: 'assets/images/Kyoto_Samurais.png',
          primaryColorName: 'Czarny',
          secondaryColorName: 'Ciemnoczerwony',
        ),
        ClubBrandingRecord(
          teamId: 'team_restOfTheWorld_24',
          logoAsset: 'assets/images/Shanghai_Dragons.png',
          primaryColorName: 'Czerwony',
          secondaryColorName: 'Złoty',
        ),
        ClubBrandingRecord(
          teamId: 'team_restOfTheWorld_25',
          logoAsset: 'assets/images/Imperial_Beijing.png',
          primaryColorName: 'Złoty',
          secondaryColorName: 'Czerwony',
        ),
        ClubBrandingRecord(
          teamId: 'team_restOfTheWorld_26',
          logoAsset: 'assets/images/Mexico_City_SC.png',
          primaryColorName: 'Zielony',
          secondaryColorName: 'Biały',
        ),
        ClubBrandingRecord(
          teamId: 'team_restOfTheWorld_27',
          logoAsset: 'assets/images/Dynamo_Casablanca.png',
          primaryColorName: 'Czerwony',
          secondaryColorName: 'Żółty',
        ),
        ClubBrandingRecord(
          teamId: 'team_restOfTheWorld_28',
          logoAsset: 'assets/images/Cairo_United.png',
          primaryColorName: 'Złoty',
          secondaryColorName: 'Czarny',
        ),
        ClubBrandingRecord(
          teamId: 'team_restOfTheWorld_29',
          logoAsset: 'assets/images/Lagos_Rovers.png',
          primaryColorName: 'Zielony',
          secondaryColorName: 'Biały',
        ),
      ];

  static const Set<String> expectedTeamIds = <String>{
    'team_europe_0',
    'team_europe_1',
    'team_europe_2',
    'team_europe_3',
    'team_europe_4',
    'team_europe_5',
    'team_europe_6',
    'team_europe_7',
    'team_europe_8',
    'team_europe_9',
    'team_europe_10',
    'team_europe_11',
    'team_europe_12',
    'team_europe_13',
    'team_europe_14',
    'team_restOfTheWorld_15',
    'team_restOfTheWorld_16',
    'team_restOfTheWorld_17',
    'team_restOfTheWorld_18',
    'team_restOfTheWorld_19',
    'team_restOfTheWorld_20',
    'team_restOfTheWorld_21',
    'team_restOfTheWorld_22',
    'team_restOfTheWorld_23',
    'team_restOfTheWorld_24',
    'team_restOfTheWorld_25',
    'team_restOfTheWorld_26',
    'team_restOfTheWorld_27',
    'team_restOfTheWorld_28',
    'team_restOfTheWorld_29',
  };

  static const List<ClubBrandingRecord> records = productionRecords;
  static const Set<String> expectedIds = expectedTeamIds;
}
