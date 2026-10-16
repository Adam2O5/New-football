import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';

part 'playoff_bracket.freezed.dart';
part 'playoff_bracket.g.dart';

@freezed
abstract class PlayoffBracket with _$PlayoffBracket {
  const factory PlayoffBracket({
    required Conference conference,
    @Default([]) List<PlayoffSeries> quarterFinals,
    @Default([]) List<PlayoffSeries> semiFinals,
    @Default([]) List<PlayoffSeries> conferenceFinal,
    PlayoffSeries? leagueFinal,
  }) = _PlayoffBracket;

  factory PlayoffBracket.fromJson(Map<String, dynamic> json) =>
      _$PlayoffBracketFromJson(json);
}
