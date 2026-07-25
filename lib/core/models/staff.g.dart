// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StaffAttributesImpl _$$StaffAttributesImplFromJson(
  Map<String, dynamic> json,
) => _$StaffAttributesImpl(
  tactics: (json['tactics'] as num?)?.toDouble() ?? 0.0,
  motivation: (json['motivation'] as num?)?.toDouble() ?? 0.0,
  development: (json['development'] as num?)?.toDouble() ?? 0.0,
  mentoring: (json['mentoring'] as num?)?.toDouble() ?? 0.0,
  coverage: (json['coverage'] as num?)?.toDouble() ?? 0.0,
  evaluation: (json['evaluation'] as num?)?.toDouble() ?? 0.0,
  rehabilitation: (json['rehabilitation'] as num?)?.toDouble() ?? 0.0,
  regenaration: (json['regenaration'] as num?)?.toDouble() ?? 0.0,
  prevention: (json['prevention'] as num?)?.toDouble() ?? 0.0,
  care: (json['care'] as num?)?.toDouble() ?? 0.0,
  negotiation: (json['negotiation'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$$StaffAttributesImplToJson(
  _$StaffAttributesImpl instance,
) => <String, dynamic>{
  'tactics': instance.tactics,
  'motivation': instance.motivation,
  'development': instance.development,
  'mentoring': instance.mentoring,
  'coverage': instance.coverage,
  'evaluation': instance.evaluation,
  'rehabilitation': instance.rehabilitation,
  'regenaration': instance.regenaration,
  'prevention': instance.prevention,
  'care': instance.care,
  'negotiation': instance.negotiation,
};

_$StaffContractImpl _$$StaffContractImplFromJson(Map<String, dynamic> json) =>
    _$StaffContractImpl(
      salary: (json['salary'] as num).toInt(),
      yearsRemaining: (json['yearsRemaining'] as num).toInt(),
    );

Map<String, dynamic> _$$StaffContractImplToJson(_$StaffContractImpl instance) =>
    <String, dynamic>{
      'salary': instance.salary,
      'yearsRemaining': instance.yearsRemaining,
    };

_$StaffMemberImpl _$$StaffMemberImplFromJson(Map<String, dynamic> json) =>
    _$StaffMemberImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      nationality: $enumDecode(_$NationalityEnumMap, json['nationality']),
      age: (json['age'] as num).toInt(),
      role: $enumDecode(_$StaffRoleEnumMap, json['role']),
      attributes: json['attributes'] == null
          ? const StaffAttributes()
          : StaffAttributes.fromJson(
              json['attributes'] as Map<String, dynamic>,
            ),
      contract: json['contract'] == null
          ? null
          : StaffContract.fromJson(json['contract'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$StaffMemberImplToJson(_$StaffMemberImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nationality': _$NationalityEnumMap[instance.nationality]!,
      'age': instance.age,
      'role': _$StaffRoleEnumMap[instance.role]!,
      'attributes': instance.attributes,
      'contract': instance.contract,
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

const _$StaffRoleEnumMap = {
  StaffRole.headCoach: 'headCoach',
  StaffRole.youthCoach: 'youthCoach',
  StaffRole.scout: 'scout',
  StaffRole.physio: 'physio',
  StaffRole.doctor: 'doctor',
  StaffRole.cfo: 'cfo',
};

_$TeamStaffImpl _$$TeamStaffImplFromJson(Map<String, dynamic> json) =>
    _$TeamStaffImpl(
      headCoach: json['headCoach'] == null
          ? null
          : StaffMember.fromJson(json['headCoach'] as Map<String, dynamic>),
      youthCoach: json['youthCoach'] == null
          ? null
          : StaffMember.fromJson(json['youthCoach'] as Map<String, dynamic>),
      scout: json['scout'] == null
          ? null
          : StaffMember.fromJson(json['scout'] as Map<String, dynamic>),
      physio: json['physio'] == null
          ? null
          : StaffMember.fromJson(json['physio'] as Map<String, dynamic>),
      doctor: json['doctor'] == null
          ? null
          : StaffMember.fromJson(json['doctor'] as Map<String, dynamic>),
      cfo: json['cfo'] == null
          ? null
          : StaffMember.fromJson(json['cfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TeamStaffImplToJson(_$TeamStaffImpl instance) =>
    <String, dynamic>{
      'headCoach': instance.headCoach,
      'youthCoach': instance.youthCoach,
      'scout': instance.scout,
      'physio': instance.physio,
      'doctor': instance.doctor,
      'cfo': instance.cfo,
    };
