// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assigned_role.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
AssignedRole _$AssignedRoleFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'gk':
          return AssignedGkRole.fromJson(
            json
          );
                case 'cb':
          return AssignedCbRole.fromJson(
            json
          );
                case 'fullBack':
          return AssignedFullBackRole.fromJson(
            json
          );
                case 'wingBack':
          return AssignedWingBackRole.fromJson(
            json
          );
                case 'cdm':
          return AssignedCdmRole.fromJson(
            json
          );
                case 'cm':
          return AssignedCmRole.fromJson(
            json
          );
                case 'cam':
          return AssignedCamRole.fromJson(
            json
          );
                case 'winger':
          return AssignedWingerRole.fromJson(
            json
          );
                case 'striker':
          return AssignedStrikerRole.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'AssignedRole',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$AssignedRole {

 Enum get role;

  /// Serializes this AssignedRole to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignedRole&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role);

@override
String toString() {
  return 'AssignedRole(role: $role)';
}


}

/// @nodoc
class $AssignedRoleCopyWith<$Res>  {
$AssignedRoleCopyWith(AssignedRole _, $Res Function(AssignedRole) __);
}


/// Adds pattern-matching-related methods to [AssignedRole].
extension AssignedRolePatterns on AssignedRole {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AssignedGkRole value)?  gk,TResult Function( AssignedCbRole value)?  cb,TResult Function( AssignedFullBackRole value)?  fullBack,TResult Function( AssignedWingBackRole value)?  wingBack,TResult Function( AssignedCdmRole value)?  cdm,TResult Function( AssignedCmRole value)?  cm,TResult Function( AssignedCamRole value)?  cam,TResult Function( AssignedWingerRole value)?  winger,TResult Function( AssignedStrikerRole value)?  striker,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AssignedGkRole() when gk != null:
return gk(_that);case AssignedCbRole() when cb != null:
return cb(_that);case AssignedFullBackRole() when fullBack != null:
return fullBack(_that);case AssignedWingBackRole() when wingBack != null:
return wingBack(_that);case AssignedCdmRole() when cdm != null:
return cdm(_that);case AssignedCmRole() when cm != null:
return cm(_that);case AssignedCamRole() when cam != null:
return cam(_that);case AssignedWingerRole() when winger != null:
return winger(_that);case AssignedStrikerRole() when striker != null:
return striker(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AssignedGkRole value)  gk,required TResult Function( AssignedCbRole value)  cb,required TResult Function( AssignedFullBackRole value)  fullBack,required TResult Function( AssignedWingBackRole value)  wingBack,required TResult Function( AssignedCdmRole value)  cdm,required TResult Function( AssignedCmRole value)  cm,required TResult Function( AssignedCamRole value)  cam,required TResult Function( AssignedWingerRole value)  winger,required TResult Function( AssignedStrikerRole value)  striker,}){
final _that = this;
switch (_that) {
case AssignedGkRole():
return gk(_that);case AssignedCbRole():
return cb(_that);case AssignedFullBackRole():
return fullBack(_that);case AssignedWingBackRole():
return wingBack(_that);case AssignedCdmRole():
return cdm(_that);case AssignedCmRole():
return cm(_that);case AssignedCamRole():
return cam(_that);case AssignedWingerRole():
return winger(_that);case AssignedStrikerRole():
return striker(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AssignedGkRole value)?  gk,TResult? Function( AssignedCbRole value)?  cb,TResult? Function( AssignedFullBackRole value)?  fullBack,TResult? Function( AssignedWingBackRole value)?  wingBack,TResult? Function( AssignedCdmRole value)?  cdm,TResult? Function( AssignedCmRole value)?  cm,TResult? Function( AssignedCamRole value)?  cam,TResult? Function( AssignedWingerRole value)?  winger,TResult? Function( AssignedStrikerRole value)?  striker,}){
final _that = this;
switch (_that) {
case AssignedGkRole() when gk != null:
return gk(_that);case AssignedCbRole() when cb != null:
return cb(_that);case AssignedFullBackRole() when fullBack != null:
return fullBack(_that);case AssignedWingBackRole() when wingBack != null:
return wingBack(_that);case AssignedCdmRole() when cdm != null:
return cdm(_that);case AssignedCmRole() when cm != null:
return cm(_that);case AssignedCamRole() when cam != null:
return cam(_that);case AssignedWingerRole() when winger != null:
return winger(_that);case AssignedStrikerRole() when striker != null:
return striker(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( GkRole role)?  gk,TResult Function( CbRole role)?  cb,TResult Function( FullBackRole role)?  fullBack,TResult Function( WingBackRole role)?  wingBack,TResult Function( CdmRole role)?  cdm,TResult Function( CmRole role)?  cm,TResult Function( CamRole role)?  cam,TResult Function( WingerRole role)?  winger,TResult Function( StrikerRole role)?  striker,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AssignedGkRole() when gk != null:
return gk(_that.role);case AssignedCbRole() when cb != null:
return cb(_that.role);case AssignedFullBackRole() when fullBack != null:
return fullBack(_that.role);case AssignedWingBackRole() when wingBack != null:
return wingBack(_that.role);case AssignedCdmRole() when cdm != null:
return cdm(_that.role);case AssignedCmRole() when cm != null:
return cm(_that.role);case AssignedCamRole() when cam != null:
return cam(_that.role);case AssignedWingerRole() when winger != null:
return winger(_that.role);case AssignedStrikerRole() when striker != null:
return striker(_that.role);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( GkRole role)  gk,required TResult Function( CbRole role)  cb,required TResult Function( FullBackRole role)  fullBack,required TResult Function( WingBackRole role)  wingBack,required TResult Function( CdmRole role)  cdm,required TResult Function( CmRole role)  cm,required TResult Function( CamRole role)  cam,required TResult Function( WingerRole role)  winger,required TResult Function( StrikerRole role)  striker,}) {final _that = this;
switch (_that) {
case AssignedGkRole():
return gk(_that.role);case AssignedCbRole():
return cb(_that.role);case AssignedFullBackRole():
return fullBack(_that.role);case AssignedWingBackRole():
return wingBack(_that.role);case AssignedCdmRole():
return cdm(_that.role);case AssignedCmRole():
return cm(_that.role);case AssignedCamRole():
return cam(_that.role);case AssignedWingerRole():
return winger(_that.role);case AssignedStrikerRole():
return striker(_that.role);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( GkRole role)?  gk,TResult? Function( CbRole role)?  cb,TResult? Function( FullBackRole role)?  fullBack,TResult? Function( WingBackRole role)?  wingBack,TResult? Function( CdmRole role)?  cdm,TResult? Function( CmRole role)?  cm,TResult? Function( CamRole role)?  cam,TResult? Function( WingerRole role)?  winger,TResult? Function( StrikerRole role)?  striker,}) {final _that = this;
switch (_that) {
case AssignedGkRole() when gk != null:
return gk(_that.role);case AssignedCbRole() when cb != null:
return cb(_that.role);case AssignedFullBackRole() when fullBack != null:
return fullBack(_that.role);case AssignedWingBackRole() when wingBack != null:
return wingBack(_that.role);case AssignedCdmRole() when cdm != null:
return cdm(_that.role);case AssignedCmRole() when cm != null:
return cm(_that.role);case AssignedCamRole() when cam != null:
return cam(_that.role);case AssignedWingerRole() when winger != null:
return winger(_that.role);case AssignedStrikerRole() when striker != null:
return striker(_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class AssignedGkRole implements AssignedRole {
  const AssignedGkRole({this.role = GkRole.standard, final  String? $type}): $type = $type ?? 'gk';
  factory AssignedGkRole.fromJson(Map<String, dynamic> json) => _$AssignedGkRoleFromJson(json);

@override@JsonKey() final  GkRole role;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of AssignedRole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignedGkRoleCopyWith<AssignedGkRole> get copyWith => _$AssignedGkRoleCopyWithImpl<AssignedGkRole>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignedGkRoleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignedGkRole&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role);

@override
String toString() {
  return 'AssignedRole.gk(role: $role)';
}


}

/// @nodoc
abstract mixin class $AssignedGkRoleCopyWith<$Res> implements $AssignedRoleCopyWith<$Res> {
  factory $AssignedGkRoleCopyWith(AssignedGkRole value, $Res Function(AssignedGkRole) _then) = _$AssignedGkRoleCopyWithImpl;
@useResult
$Res call({
 GkRole role
});




}
/// @nodoc
class _$AssignedGkRoleCopyWithImpl<$Res>
    implements $AssignedGkRoleCopyWith<$Res> {
  _$AssignedGkRoleCopyWithImpl(this._self, this._then);

  final AssignedGkRole _self;
  final $Res Function(AssignedGkRole) _then;

/// Create a copy of AssignedRole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? role = null,}) {
  return _then(AssignedGkRole(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as GkRole,
  ));
}


}

/// @nodoc
@JsonSerializable()

class AssignedCbRole implements AssignedRole {
  const AssignedCbRole({this.role = CbRole.standard, final  String? $type}): $type = $type ?? 'cb';
  factory AssignedCbRole.fromJson(Map<String, dynamic> json) => _$AssignedCbRoleFromJson(json);

@override@JsonKey() final  CbRole role;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of AssignedRole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignedCbRoleCopyWith<AssignedCbRole> get copyWith => _$AssignedCbRoleCopyWithImpl<AssignedCbRole>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignedCbRoleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignedCbRole&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role);

@override
String toString() {
  return 'AssignedRole.cb(role: $role)';
}


}

/// @nodoc
abstract mixin class $AssignedCbRoleCopyWith<$Res> implements $AssignedRoleCopyWith<$Res> {
  factory $AssignedCbRoleCopyWith(AssignedCbRole value, $Res Function(AssignedCbRole) _then) = _$AssignedCbRoleCopyWithImpl;
@useResult
$Res call({
 CbRole role
});




}
/// @nodoc
class _$AssignedCbRoleCopyWithImpl<$Res>
    implements $AssignedCbRoleCopyWith<$Res> {
  _$AssignedCbRoleCopyWithImpl(this._self, this._then);

  final AssignedCbRole _self;
  final $Res Function(AssignedCbRole) _then;

/// Create a copy of AssignedRole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? role = null,}) {
  return _then(AssignedCbRole(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as CbRole,
  ));
}


}

/// @nodoc
@JsonSerializable()

class AssignedFullBackRole implements AssignedRole {
  const AssignedFullBackRole({this.role = FullBackRole.standard, final  String? $type}): $type = $type ?? 'fullBack';
  factory AssignedFullBackRole.fromJson(Map<String, dynamic> json) => _$AssignedFullBackRoleFromJson(json);

@override@JsonKey() final  FullBackRole role;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of AssignedRole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignedFullBackRoleCopyWith<AssignedFullBackRole> get copyWith => _$AssignedFullBackRoleCopyWithImpl<AssignedFullBackRole>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignedFullBackRoleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignedFullBackRole&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role);

@override
String toString() {
  return 'AssignedRole.fullBack(role: $role)';
}


}

/// @nodoc
abstract mixin class $AssignedFullBackRoleCopyWith<$Res> implements $AssignedRoleCopyWith<$Res> {
  factory $AssignedFullBackRoleCopyWith(AssignedFullBackRole value, $Res Function(AssignedFullBackRole) _then) = _$AssignedFullBackRoleCopyWithImpl;
@useResult
$Res call({
 FullBackRole role
});




}
/// @nodoc
class _$AssignedFullBackRoleCopyWithImpl<$Res>
    implements $AssignedFullBackRoleCopyWith<$Res> {
  _$AssignedFullBackRoleCopyWithImpl(this._self, this._then);

  final AssignedFullBackRole _self;
  final $Res Function(AssignedFullBackRole) _then;

/// Create a copy of AssignedRole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? role = null,}) {
  return _then(AssignedFullBackRole(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as FullBackRole,
  ));
}


}

/// @nodoc
@JsonSerializable()

class AssignedWingBackRole implements AssignedRole {
  const AssignedWingBackRole({this.role = WingBackRole.standard, final  String? $type}): $type = $type ?? 'wingBack';
  factory AssignedWingBackRole.fromJson(Map<String, dynamic> json) => _$AssignedWingBackRoleFromJson(json);

@override@JsonKey() final  WingBackRole role;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of AssignedRole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignedWingBackRoleCopyWith<AssignedWingBackRole> get copyWith => _$AssignedWingBackRoleCopyWithImpl<AssignedWingBackRole>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignedWingBackRoleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignedWingBackRole&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role);

@override
String toString() {
  return 'AssignedRole.wingBack(role: $role)';
}


}

/// @nodoc
abstract mixin class $AssignedWingBackRoleCopyWith<$Res> implements $AssignedRoleCopyWith<$Res> {
  factory $AssignedWingBackRoleCopyWith(AssignedWingBackRole value, $Res Function(AssignedWingBackRole) _then) = _$AssignedWingBackRoleCopyWithImpl;
@useResult
$Res call({
 WingBackRole role
});




}
/// @nodoc
class _$AssignedWingBackRoleCopyWithImpl<$Res>
    implements $AssignedWingBackRoleCopyWith<$Res> {
  _$AssignedWingBackRoleCopyWithImpl(this._self, this._then);

  final AssignedWingBackRole _self;
  final $Res Function(AssignedWingBackRole) _then;

/// Create a copy of AssignedRole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? role = null,}) {
  return _then(AssignedWingBackRole(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as WingBackRole,
  ));
}


}

/// @nodoc
@JsonSerializable()

class AssignedCdmRole implements AssignedRole {
  const AssignedCdmRole({this.role = CdmRole.standard, final  String? $type}): $type = $type ?? 'cdm';
  factory AssignedCdmRole.fromJson(Map<String, dynamic> json) => _$AssignedCdmRoleFromJson(json);

@override@JsonKey() final  CdmRole role;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of AssignedRole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignedCdmRoleCopyWith<AssignedCdmRole> get copyWith => _$AssignedCdmRoleCopyWithImpl<AssignedCdmRole>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignedCdmRoleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignedCdmRole&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role);

@override
String toString() {
  return 'AssignedRole.cdm(role: $role)';
}


}

/// @nodoc
abstract mixin class $AssignedCdmRoleCopyWith<$Res> implements $AssignedRoleCopyWith<$Res> {
  factory $AssignedCdmRoleCopyWith(AssignedCdmRole value, $Res Function(AssignedCdmRole) _then) = _$AssignedCdmRoleCopyWithImpl;
@useResult
$Res call({
 CdmRole role
});




}
/// @nodoc
class _$AssignedCdmRoleCopyWithImpl<$Res>
    implements $AssignedCdmRoleCopyWith<$Res> {
  _$AssignedCdmRoleCopyWithImpl(this._self, this._then);

  final AssignedCdmRole _self;
  final $Res Function(AssignedCdmRole) _then;

/// Create a copy of AssignedRole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? role = null,}) {
  return _then(AssignedCdmRole(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as CdmRole,
  ));
}


}

/// @nodoc
@JsonSerializable()

class AssignedCmRole implements AssignedRole {
  const AssignedCmRole({this.role = CmRole.standard, final  String? $type}): $type = $type ?? 'cm';
  factory AssignedCmRole.fromJson(Map<String, dynamic> json) => _$AssignedCmRoleFromJson(json);

@override@JsonKey() final  CmRole role;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of AssignedRole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignedCmRoleCopyWith<AssignedCmRole> get copyWith => _$AssignedCmRoleCopyWithImpl<AssignedCmRole>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignedCmRoleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignedCmRole&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role);

@override
String toString() {
  return 'AssignedRole.cm(role: $role)';
}


}

/// @nodoc
abstract mixin class $AssignedCmRoleCopyWith<$Res> implements $AssignedRoleCopyWith<$Res> {
  factory $AssignedCmRoleCopyWith(AssignedCmRole value, $Res Function(AssignedCmRole) _then) = _$AssignedCmRoleCopyWithImpl;
@useResult
$Res call({
 CmRole role
});




}
/// @nodoc
class _$AssignedCmRoleCopyWithImpl<$Res>
    implements $AssignedCmRoleCopyWith<$Res> {
  _$AssignedCmRoleCopyWithImpl(this._self, this._then);

  final AssignedCmRole _self;
  final $Res Function(AssignedCmRole) _then;

/// Create a copy of AssignedRole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? role = null,}) {
  return _then(AssignedCmRole(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as CmRole,
  ));
}


}

/// @nodoc
@JsonSerializable()

class AssignedCamRole implements AssignedRole {
  const AssignedCamRole({this.role = CamRole.standard, final  String? $type}): $type = $type ?? 'cam';
  factory AssignedCamRole.fromJson(Map<String, dynamic> json) => _$AssignedCamRoleFromJson(json);

@override@JsonKey() final  CamRole role;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of AssignedRole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignedCamRoleCopyWith<AssignedCamRole> get copyWith => _$AssignedCamRoleCopyWithImpl<AssignedCamRole>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignedCamRoleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignedCamRole&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role);

@override
String toString() {
  return 'AssignedRole.cam(role: $role)';
}


}

/// @nodoc
abstract mixin class $AssignedCamRoleCopyWith<$Res> implements $AssignedRoleCopyWith<$Res> {
  factory $AssignedCamRoleCopyWith(AssignedCamRole value, $Res Function(AssignedCamRole) _then) = _$AssignedCamRoleCopyWithImpl;
@useResult
$Res call({
 CamRole role
});




}
/// @nodoc
class _$AssignedCamRoleCopyWithImpl<$Res>
    implements $AssignedCamRoleCopyWith<$Res> {
  _$AssignedCamRoleCopyWithImpl(this._self, this._then);

  final AssignedCamRole _self;
  final $Res Function(AssignedCamRole) _then;

/// Create a copy of AssignedRole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? role = null,}) {
  return _then(AssignedCamRole(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as CamRole,
  ));
}


}

/// @nodoc
@JsonSerializable()

class AssignedWingerRole implements AssignedRole {
  const AssignedWingerRole({this.role = WingerRole.standard, final  String? $type}): $type = $type ?? 'winger';
  factory AssignedWingerRole.fromJson(Map<String, dynamic> json) => _$AssignedWingerRoleFromJson(json);

@override@JsonKey() final  WingerRole role;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of AssignedRole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignedWingerRoleCopyWith<AssignedWingerRole> get copyWith => _$AssignedWingerRoleCopyWithImpl<AssignedWingerRole>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignedWingerRoleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignedWingerRole&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role);

@override
String toString() {
  return 'AssignedRole.winger(role: $role)';
}


}

/// @nodoc
abstract mixin class $AssignedWingerRoleCopyWith<$Res> implements $AssignedRoleCopyWith<$Res> {
  factory $AssignedWingerRoleCopyWith(AssignedWingerRole value, $Res Function(AssignedWingerRole) _then) = _$AssignedWingerRoleCopyWithImpl;
@useResult
$Res call({
 WingerRole role
});




}
/// @nodoc
class _$AssignedWingerRoleCopyWithImpl<$Res>
    implements $AssignedWingerRoleCopyWith<$Res> {
  _$AssignedWingerRoleCopyWithImpl(this._self, this._then);

  final AssignedWingerRole _self;
  final $Res Function(AssignedWingerRole) _then;

/// Create a copy of AssignedRole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? role = null,}) {
  return _then(AssignedWingerRole(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as WingerRole,
  ));
}


}

/// @nodoc
@JsonSerializable()

class AssignedStrikerRole implements AssignedRole {
  const AssignedStrikerRole({this.role = StrikerRole.standard, final  String? $type}): $type = $type ?? 'striker';
  factory AssignedStrikerRole.fromJson(Map<String, dynamic> json) => _$AssignedStrikerRoleFromJson(json);

@override@JsonKey() final  StrikerRole role;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of AssignedRole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignedStrikerRoleCopyWith<AssignedStrikerRole> get copyWith => _$AssignedStrikerRoleCopyWithImpl<AssignedStrikerRole>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignedStrikerRoleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignedStrikerRole&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role);

@override
String toString() {
  return 'AssignedRole.striker(role: $role)';
}


}

/// @nodoc
abstract mixin class $AssignedStrikerRoleCopyWith<$Res> implements $AssignedRoleCopyWith<$Res> {
  factory $AssignedStrikerRoleCopyWith(AssignedStrikerRole value, $Res Function(AssignedStrikerRole) _then) = _$AssignedStrikerRoleCopyWithImpl;
@useResult
$Res call({
 StrikerRole role
});




}
/// @nodoc
class _$AssignedStrikerRoleCopyWithImpl<$Res>
    implements $AssignedStrikerRoleCopyWith<$Res> {
  _$AssignedStrikerRoleCopyWithImpl(this._self, this._then);

  final AssignedStrikerRole _self;
  final $Res Function(AssignedStrikerRole) _then;

/// Create a copy of AssignedRole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? role = null,}) {
  return _then(AssignedStrikerRole(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as StrikerRole,
  ));
}


}

// dart format on
