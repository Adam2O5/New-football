// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prospect.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Prospect _$ProspectFromJson(Map<String, dynamic> json) => _Prospect(
  id: json['id'] as String,
  name: json['name'] as String,
  nationality: $enumDecode(_$NationalityEnumMap, json['nationality']),
  position: $enumDecode(_$PositionEnumMap, json['position']),
  age: (json['age'] as num).toInt(),
  attributes: PlayerAttributes.fromJson(
    json['attributes'] as Map<String, dynamic>,
  ),
  scoutGrade: (json['scoutGrade'] as num?)?.toInt() ?? 0,
  combineScore: (json['combineScore'] as num?)?.toInt() ?? 0,
  potentialStars: (json['potentialStars'] as num).toDouble(),
  heightCm: (json['heightCm'] as num).toInt(),
  injuryProne: (json['injuryProne'] as num).toInt(),
  determination: (json['determination'] as num).toInt(),
  personality: $enumDecode(_$PlayerPersonalityEnumMap, json['personality']),
  optimalRole: AssignedRole.fromJson(
    json['optimalRole'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ProspectToJson(_Prospect instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'nationality': _$NationalityEnumMap[instance.nationality]!,
  'position': _$PositionEnumMap[instance.position]!,
  'age': instance.age,
  'attributes': instance.attributes,
  'scoutGrade': instance.scoutGrade,
  'combineScore': instance.combineScore,
  'potentialStars': instance.potentialStars,
  'heightCm': instance.heightCm,
  'injuryProne': instance.injuryProne,
  'determination': instance.determination,
  'personality': _$PlayerPersonalityEnumMap[instance.personality]!,
  'optimalRole': instance.optimalRole,
};

const _$NationalityEnumMap = {
  Nationality.poland: 'poland',
  Nationality.brazil: 'brazil',
  Nationality.france: 'france',
  Nationality.spain: 'spain',
  Nationality.england: 'england',
  Nationality.germany: 'germany',
  Nationality.argentina: 'argentina',
  Nationality.portugal: 'portugal',
  Nationality.italy: 'italy',
  Nationality.netherlands: 'netherlands',
  Nationality.belgium: 'belgium',
  Nationality.croatia: 'croatia',
  Nationality.nigeria: 'nigeria',
  Nationality.senegal: 'senegal',
  Nationality.japan: 'japan',
  Nationality.usa: 'usa',
  Nationality.mexico: 'mexico',
  Nationality.morocco: 'morocco',
  Nationality.colombia: 'colombia',
  Nationality.switzerland: 'switzerland',
  Nationality.uruguay: 'uruguay',
  Nationality.egypt: 'egypt',
  Nationality.china: 'china',
};

const _$PositionEnumMap = {
  Position.gk: 'gk',
  Position.cb: 'cb',
  Position.lb: 'lb',
  Position.rb: 'rb',
  Position.lwb: 'lwb',
  Position.rwb: 'rwb',
  Position.cdm: 'cdm',
  Position.cm: 'cm',
  Position.cam: 'cam',
  Position.lw: 'lw',
  Position.rw: 'rw',
  Position.st: 'st',
};

const _$PlayerPersonalityEnumMap = {
  PlayerPersonality.professional: 'professional',
  PlayerPersonality.leader: 'leader',
  PlayerPersonality.temperamental: 'temperamental',
  PlayerPersonality.ambitious: 'ambitious',
  PlayerPersonality.loyal: 'loyal',
  PlayerPersonality.balanced: 'balanced',
};
