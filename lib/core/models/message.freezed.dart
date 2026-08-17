// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageAction {

 String get id; String get labelKey;
/// Create a copy of MessageAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageActionCopyWith<MessageAction> get copyWith => _$MessageActionCopyWithImpl<MessageAction>(this as MessageAction, _$identity);

  /// Serializes this MessageAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageAction&&(identical(other.id, id) || other.id == id)&&(identical(other.labelKey, labelKey) || other.labelKey == labelKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,labelKey);

@override
String toString() {
  return 'MessageAction(id: $id, labelKey: $labelKey)';
}


}

/// @nodoc
abstract mixin class $MessageActionCopyWith<$Res>  {
  factory $MessageActionCopyWith(MessageAction value, $Res Function(MessageAction) _then) = _$MessageActionCopyWithImpl;
@useResult
$Res call({
 String id, String labelKey
});




}
/// @nodoc
class _$MessageActionCopyWithImpl<$Res>
    implements $MessageActionCopyWith<$Res> {
  _$MessageActionCopyWithImpl(this._self, this._then);

  final MessageAction _self;
  final $Res Function(MessageAction) _then;

/// Create a copy of MessageAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? labelKey = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,labelKey: null == labelKey ? _self.labelKey : labelKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageAction].
extension MessageActionPatterns on MessageAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageAction() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageAction value)  $default,){
final _that = this;
switch (_that) {
case _MessageAction():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageAction value)?  $default,){
final _that = this;
switch (_that) {
case _MessageAction() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String labelKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageAction() when $default != null:
return $default(_that.id,_that.labelKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String labelKey)  $default,) {final _that = this;
switch (_that) {
case _MessageAction():
return $default(_that.id,_that.labelKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String labelKey)?  $default,) {final _that = this;
switch (_that) {
case _MessageAction() when $default != null:
return $default(_that.id,_that.labelKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageAction implements MessageAction {
  const _MessageAction({required this.id, required this.labelKey});
  factory _MessageAction.fromJson(Map<String, dynamic> json) => _$MessageActionFromJson(json);

@override final  String id;
@override final  String labelKey;

/// Create a copy of MessageAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageActionCopyWith<_MessageAction> get copyWith => __$MessageActionCopyWithImpl<_MessageAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageActionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageAction&&(identical(other.id, id) || other.id == id)&&(identical(other.labelKey, labelKey) || other.labelKey == labelKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,labelKey);

@override
String toString() {
  return 'MessageAction(id: $id, labelKey: $labelKey)';
}


}

/// @nodoc
abstract mixin class _$MessageActionCopyWith<$Res> implements $MessageActionCopyWith<$Res> {
  factory _$MessageActionCopyWith(_MessageAction value, $Res Function(_MessageAction) _then) = __$MessageActionCopyWithImpl;
@override @useResult
$Res call({
 String id, String labelKey
});




}
/// @nodoc
class __$MessageActionCopyWithImpl<$Res>
    implements _$MessageActionCopyWith<$Res> {
  __$MessageActionCopyWithImpl(this._self, this._then);

  final _MessageAction _self;
  final $Res Function(_MessageAction) _then;

/// Create a copy of MessageAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? labelKey = null,}) {
  return _then(_MessageAction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,labelKey: null == labelKey ? _self.labelKey : labelKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DecisionSpec {

 List<MessageAction> get options; String get defaultOnExpiry;
/// Create a copy of DecisionSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DecisionSpecCopyWith<DecisionSpec> get copyWith => _$DecisionSpecCopyWithImpl<DecisionSpec>(this as DecisionSpec, _$identity);

  /// Serializes this DecisionSpec to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DecisionSpec&&const DeepCollectionEquality().equals(other.options, options)&&(identical(other.defaultOnExpiry, defaultOnExpiry) || other.defaultOnExpiry == defaultOnExpiry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(options),defaultOnExpiry);

@override
String toString() {
  return 'DecisionSpec(options: $options, defaultOnExpiry: $defaultOnExpiry)';
}


}

/// @nodoc
abstract mixin class $DecisionSpecCopyWith<$Res>  {
  factory $DecisionSpecCopyWith(DecisionSpec value, $Res Function(DecisionSpec) _then) = _$DecisionSpecCopyWithImpl;
@useResult
$Res call({
 List<MessageAction> options, String defaultOnExpiry
});




}
/// @nodoc
class _$DecisionSpecCopyWithImpl<$Res>
    implements $DecisionSpecCopyWith<$Res> {
  _$DecisionSpecCopyWithImpl(this._self, this._then);

  final DecisionSpec _self;
  final $Res Function(DecisionSpec) _then;

/// Create a copy of DecisionSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? options = null,Object? defaultOnExpiry = null,}) {
  return _then(_self.copyWith(
options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<MessageAction>,defaultOnExpiry: null == defaultOnExpiry ? _self.defaultOnExpiry : defaultOnExpiry // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DecisionSpec].
extension DecisionSpecPatterns on DecisionSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DecisionSpec value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DecisionSpec() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DecisionSpec value)  $default,){
final _that = this;
switch (_that) {
case _DecisionSpec():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DecisionSpec value)?  $default,){
final _that = this;
switch (_that) {
case _DecisionSpec() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MessageAction> options,  String defaultOnExpiry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DecisionSpec() when $default != null:
return $default(_that.options,_that.defaultOnExpiry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MessageAction> options,  String defaultOnExpiry)  $default,) {final _that = this;
switch (_that) {
case _DecisionSpec():
return $default(_that.options,_that.defaultOnExpiry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MessageAction> options,  String defaultOnExpiry)?  $default,) {final _that = this;
switch (_that) {
case _DecisionSpec() when $default != null:
return $default(_that.options,_that.defaultOnExpiry);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DecisionSpec implements DecisionSpec {
  const _DecisionSpec({required final  List<MessageAction> options, required this.defaultOnExpiry}): _options = options;
  factory _DecisionSpec.fromJson(Map<String, dynamic> json) => _$DecisionSpecFromJson(json);

 final  List<MessageAction> _options;
@override List<MessageAction> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

@override final  String defaultOnExpiry;

/// Create a copy of DecisionSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecisionSpecCopyWith<_DecisionSpec> get copyWith => __$DecisionSpecCopyWithImpl<_DecisionSpec>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DecisionSpecToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DecisionSpec&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.defaultOnExpiry, defaultOnExpiry) || other.defaultOnExpiry == defaultOnExpiry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_options),defaultOnExpiry);

@override
String toString() {
  return 'DecisionSpec(options: $options, defaultOnExpiry: $defaultOnExpiry)';
}


}

/// @nodoc
abstract mixin class _$DecisionSpecCopyWith<$Res> implements $DecisionSpecCopyWith<$Res> {
  factory _$DecisionSpecCopyWith(_DecisionSpec value, $Res Function(_DecisionSpec) _then) = __$DecisionSpecCopyWithImpl;
@override @useResult
$Res call({
 List<MessageAction> options, String defaultOnExpiry
});




}
/// @nodoc
class __$DecisionSpecCopyWithImpl<$Res>
    implements _$DecisionSpecCopyWith<$Res> {
  __$DecisionSpecCopyWithImpl(this._self, this._then);

  final _DecisionSpec _self;
  final $Res Function(_DecisionSpec) _then;

/// Create a copy of DecisionSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? options = null,Object? defaultOnExpiry = null,}) {
  return _then(_DecisionSpec(
options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<MessageAction>,defaultOnExpiry: null == defaultOnExpiry ? _self.defaultOnExpiry : defaultOnExpiry // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$GameMessage {

 String get id; MessageType get type; String? get kind; MessageDomain get domain; MessagePriority get priority; int get seasonYear; int get week; int get day; int? get hour; String get titleKey; String get bodyKey; Map<String, dynamic> get args; Map<String, dynamic> get payload; List<MessageAction> get actions; DecisionSpec? get decision; String? get expiresAt; String? get groupKey; String? get dedupKey; bool get read; bool get acknowledged;
/// Create a copy of GameMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameMessageCopyWith<GameMessage> get copyWith => _$GameMessageCopyWithImpl<GameMessage>(this as GameMessage, _$identity);

  /// Serializes this GameMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.week, week) || other.week == week)&&(identical(other.day, day) || other.day == day)&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.bodyKey, bodyKey) || other.bodyKey == bodyKey)&&const DeepCollectionEquality().equals(other.args, args)&&const DeepCollectionEquality().equals(other.payload, payload)&&const DeepCollectionEquality().equals(other.actions, actions)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.groupKey, groupKey) || other.groupKey == groupKey)&&(identical(other.dedupKey, dedupKey) || other.dedupKey == dedupKey)&&(identical(other.read, read) || other.read == read)&&(identical(other.acknowledged, acknowledged) || other.acknowledged == acknowledged));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,type,kind,domain,priority,seasonYear,week,day,hour,titleKey,bodyKey,const DeepCollectionEquality().hash(args),const DeepCollectionEquality().hash(payload),const DeepCollectionEquality().hash(actions),decision,expiresAt,groupKey,dedupKey,read,acknowledged]);

@override
String toString() {
  return 'GameMessage(id: $id, type: $type, kind: $kind, domain: $domain, priority: $priority, seasonYear: $seasonYear, week: $week, day: $day, hour: $hour, titleKey: $titleKey, bodyKey: $bodyKey, args: $args, payload: $payload, actions: $actions, decision: $decision, expiresAt: $expiresAt, groupKey: $groupKey, dedupKey: $dedupKey, read: $read, acknowledged: $acknowledged)';
}


}

/// @nodoc
abstract mixin class $GameMessageCopyWith<$Res>  {
  factory $GameMessageCopyWith(GameMessage value, $Res Function(GameMessage) _then) = _$GameMessageCopyWithImpl;
@useResult
$Res call({
 String id, MessageType type, String? kind, MessageDomain domain, MessagePriority priority, int seasonYear, int week, int day, int? hour, String titleKey, String bodyKey, Map<String, dynamic> args, Map<String, dynamic> payload, List<MessageAction> actions, DecisionSpec? decision, String? expiresAt, String? groupKey, String? dedupKey, bool read, bool acknowledged
});


$DecisionSpecCopyWith<$Res>? get decision;

}
/// @nodoc
class _$GameMessageCopyWithImpl<$Res>
    implements $GameMessageCopyWith<$Res> {
  _$GameMessageCopyWithImpl(this._self, this._then);

  final GameMessage _self;
  final $Res Function(GameMessage) _then;

/// Create a copy of GameMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? kind = freezed,Object? domain = null,Object? priority = null,Object? seasonYear = null,Object? week = null,Object? day = null,Object? hour = freezed,Object? titleKey = null,Object? bodyKey = null,Object? args = null,Object? payload = null,Object? actions = null,Object? decision = freezed,Object? expiresAt = freezed,Object? groupKey = freezed,Object? dedupKey = freezed,Object? read = null,Object? acknowledged = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,kind: freezed == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String?,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as MessageDomain,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as MessagePriority,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as int,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,hour: freezed == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int?,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,bodyKey: null == bodyKey ? _self.bodyKey : bodyKey // ignore: cast_nullable_to_non_nullable
as String,args: null == args ? _self.args : args // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,actions: null == actions ? _self.actions : actions // ignore: cast_nullable_to_non_nullable
as List<MessageAction>,decision: freezed == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as DecisionSpec?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String?,groupKey: freezed == groupKey ? _self.groupKey : groupKey // ignore: cast_nullable_to_non_nullable
as String?,dedupKey: freezed == dedupKey ? _self.dedupKey : dedupKey // ignore: cast_nullable_to_non_nullable
as String?,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,acknowledged: null == acknowledged ? _self.acknowledged : acknowledged // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of GameMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DecisionSpecCopyWith<$Res>? get decision {
    if (_self.decision == null) {
    return null;
  }

  return $DecisionSpecCopyWith<$Res>(_self.decision!, (value) {
    return _then(_self.copyWith(decision: value));
  });
}
}


/// Adds pattern-matching-related methods to [GameMessage].
extension GameMessagePatterns on GameMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameMessage() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameMessage value)  $default,){
final _that = this;
switch (_that) {
case _GameMessage():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameMessage value)?  $default,){
final _that = this;
switch (_that) {
case _GameMessage() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  MessageType type,  String? kind,  MessageDomain domain,  MessagePriority priority,  int seasonYear,  int week,  int day,  int? hour,  String titleKey,  String bodyKey,  Map<String, dynamic> args,  Map<String, dynamic> payload,  List<MessageAction> actions,  DecisionSpec? decision,  String? expiresAt,  String? groupKey,  String? dedupKey,  bool read,  bool acknowledged)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameMessage() when $default != null:
return $default(_that.id,_that.type,_that.kind,_that.domain,_that.priority,_that.seasonYear,_that.week,_that.day,_that.hour,_that.titleKey,_that.bodyKey,_that.args,_that.payload,_that.actions,_that.decision,_that.expiresAt,_that.groupKey,_that.dedupKey,_that.read,_that.acknowledged);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  MessageType type,  String? kind,  MessageDomain domain,  MessagePriority priority,  int seasonYear,  int week,  int day,  int? hour,  String titleKey,  String bodyKey,  Map<String, dynamic> args,  Map<String, dynamic> payload,  List<MessageAction> actions,  DecisionSpec? decision,  String? expiresAt,  String? groupKey,  String? dedupKey,  bool read,  bool acknowledged)  $default,) {final _that = this;
switch (_that) {
case _GameMessage():
return $default(_that.id,_that.type,_that.kind,_that.domain,_that.priority,_that.seasonYear,_that.week,_that.day,_that.hour,_that.titleKey,_that.bodyKey,_that.args,_that.payload,_that.actions,_that.decision,_that.expiresAt,_that.groupKey,_that.dedupKey,_that.read,_that.acknowledged);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  MessageType type,  String? kind,  MessageDomain domain,  MessagePriority priority,  int seasonYear,  int week,  int day,  int? hour,  String titleKey,  String bodyKey,  Map<String, dynamic> args,  Map<String, dynamic> payload,  List<MessageAction> actions,  DecisionSpec? decision,  String? expiresAt,  String? groupKey,  String? dedupKey,  bool read,  bool acknowledged)?  $default,) {final _that = this;
switch (_that) {
case _GameMessage() when $default != null:
return $default(_that.id,_that.type,_that.kind,_that.domain,_that.priority,_that.seasonYear,_that.week,_that.day,_that.hour,_that.titleKey,_that.bodyKey,_that.args,_that.payload,_that.actions,_that.decision,_that.expiresAt,_that.groupKey,_that.dedupKey,_that.read,_that.acknowledged);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameMessage implements GameMessage {
  const _GameMessage({required this.id, required this.type, this.kind, this.domain = MessageDomain.system, this.priority = MessagePriority.normal, required this.seasonYear, required this.week, this.day = 1, this.hour, required this.titleKey, required this.bodyKey, final  Map<String, dynamic> args = const {}, final  Map<String, dynamic> payload = const {}, final  List<MessageAction> actions = const [], this.decision, this.expiresAt, this.groupKey, this.dedupKey, this.read = false, this.acknowledged = false}): _args = args,_payload = payload,_actions = actions;
  factory _GameMessage.fromJson(Map<String, dynamic> json) => _$GameMessageFromJson(json);

@override final  String id;
@override final  MessageType type;
@override final  String? kind;
@override@JsonKey() final  MessageDomain domain;
@override@JsonKey() final  MessagePriority priority;
@override final  int seasonYear;
@override final  int week;
@override@JsonKey() final  int day;
@override final  int? hour;
@override final  String titleKey;
@override final  String bodyKey;
 final  Map<String, dynamic> _args;
@override@JsonKey() Map<String, dynamic> get args {
  if (_args is EqualUnmodifiableMapView) return _args;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_args);
}

 final  Map<String, dynamic> _payload;
@override@JsonKey() Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}

 final  List<MessageAction> _actions;
@override@JsonKey() List<MessageAction> get actions {
  if (_actions is EqualUnmodifiableListView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actions);
}

@override final  DecisionSpec? decision;
@override final  String? expiresAt;
@override final  String? groupKey;
@override final  String? dedupKey;
@override@JsonKey() final  bool read;
@override@JsonKey() final  bool acknowledged;

/// Create a copy of GameMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameMessageCopyWith<_GameMessage> get copyWith => __$GameMessageCopyWithImpl<_GameMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.week, week) || other.week == week)&&(identical(other.day, day) || other.day == day)&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.bodyKey, bodyKey) || other.bodyKey == bodyKey)&&const DeepCollectionEquality().equals(other._args, _args)&&const DeepCollectionEquality().equals(other._payload, _payload)&&const DeepCollectionEquality().equals(other._actions, _actions)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.groupKey, groupKey) || other.groupKey == groupKey)&&(identical(other.dedupKey, dedupKey) || other.dedupKey == dedupKey)&&(identical(other.read, read) || other.read == read)&&(identical(other.acknowledged, acknowledged) || other.acknowledged == acknowledged));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,type,kind,domain,priority,seasonYear,week,day,hour,titleKey,bodyKey,const DeepCollectionEquality().hash(_args),const DeepCollectionEquality().hash(_payload),const DeepCollectionEquality().hash(_actions),decision,expiresAt,groupKey,dedupKey,read,acknowledged]);

@override
String toString() {
  return 'GameMessage(id: $id, type: $type, kind: $kind, domain: $domain, priority: $priority, seasonYear: $seasonYear, week: $week, day: $day, hour: $hour, titleKey: $titleKey, bodyKey: $bodyKey, args: $args, payload: $payload, actions: $actions, decision: $decision, expiresAt: $expiresAt, groupKey: $groupKey, dedupKey: $dedupKey, read: $read, acknowledged: $acknowledged)';
}


}

/// @nodoc
abstract mixin class _$GameMessageCopyWith<$Res> implements $GameMessageCopyWith<$Res> {
  factory _$GameMessageCopyWith(_GameMessage value, $Res Function(_GameMessage) _then) = __$GameMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, MessageType type, String? kind, MessageDomain domain, MessagePriority priority, int seasonYear, int week, int day, int? hour, String titleKey, String bodyKey, Map<String, dynamic> args, Map<String, dynamic> payload, List<MessageAction> actions, DecisionSpec? decision, String? expiresAt, String? groupKey, String? dedupKey, bool read, bool acknowledged
});


@override $DecisionSpecCopyWith<$Res>? get decision;

}
/// @nodoc
class __$GameMessageCopyWithImpl<$Res>
    implements _$GameMessageCopyWith<$Res> {
  __$GameMessageCopyWithImpl(this._self, this._then);

  final _GameMessage _self;
  final $Res Function(_GameMessage) _then;

/// Create a copy of GameMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? kind = freezed,Object? domain = null,Object? priority = null,Object? seasonYear = null,Object? week = null,Object? day = null,Object? hour = freezed,Object? titleKey = null,Object? bodyKey = null,Object? args = null,Object? payload = null,Object? actions = null,Object? decision = freezed,Object? expiresAt = freezed,Object? groupKey = freezed,Object? dedupKey = freezed,Object? read = null,Object? acknowledged = null,}) {
  return _then(_GameMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,kind: freezed == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String?,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as MessageDomain,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as MessagePriority,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as int,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,hour: freezed == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int?,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,bodyKey: null == bodyKey ? _self.bodyKey : bodyKey // ignore: cast_nullable_to_non_nullable
as String,args: null == args ? _self._args : args // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as List<MessageAction>,decision: freezed == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as DecisionSpec?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String?,groupKey: freezed == groupKey ? _self.groupKey : groupKey // ignore: cast_nullable_to_non_nullable
as String?,dedupKey: freezed == dedupKey ? _self.dedupKey : dedupKey // ignore: cast_nullable_to_non_nullable
as String?,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,acknowledged: null == acknowledged ? _self.acknowledged : acknowledged // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of GameMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DecisionSpecCopyWith<$Res>? get decision {
    if (_self.decision == null) {
    return null;
  }

  return $DecisionSpecCopyWith<$Res>(_self.decision!, (value) {
    return _then(_self.copyWith(decision: value));
  });
}
}


/// @nodoc
mixin _$MessageSettings {

/// Type-level settings take precedence over domain-level settings.
 Map<MessageType, NotificationLevel> get overrides; Map<MessageDomain, NotificationLevel> get domainOverrides;
/// Create a copy of MessageSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageSettingsCopyWith<MessageSettings> get copyWith => _$MessageSettingsCopyWithImpl<MessageSettings>(this as MessageSettings, _$identity);

  /// Serializes this MessageSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageSettings&&const DeepCollectionEquality().equals(other.overrides, overrides)&&const DeepCollectionEquality().equals(other.domainOverrides, domainOverrides));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(overrides),const DeepCollectionEquality().hash(domainOverrides));

@override
String toString() {
  return 'MessageSettings(overrides: $overrides, domainOverrides: $domainOverrides)';
}


}

/// @nodoc
abstract mixin class $MessageSettingsCopyWith<$Res>  {
  factory $MessageSettingsCopyWith(MessageSettings value, $Res Function(MessageSettings) _then) = _$MessageSettingsCopyWithImpl;
@useResult
$Res call({
 Map<MessageType, NotificationLevel> overrides, Map<MessageDomain, NotificationLevel> domainOverrides
});




}
/// @nodoc
class _$MessageSettingsCopyWithImpl<$Res>
    implements $MessageSettingsCopyWith<$Res> {
  _$MessageSettingsCopyWithImpl(this._self, this._then);

  final MessageSettings _self;
  final $Res Function(MessageSettings) _then;

/// Create a copy of MessageSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? overrides = null,Object? domainOverrides = null,}) {
  return _then(_self.copyWith(
overrides: null == overrides ? _self.overrides : overrides // ignore: cast_nullable_to_non_nullable
as Map<MessageType, NotificationLevel>,domainOverrides: null == domainOverrides ? _self.domainOverrides : domainOverrides // ignore: cast_nullable_to_non_nullable
as Map<MessageDomain, NotificationLevel>,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageSettings].
extension MessageSettingsPatterns on MessageSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageSettings() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageSettings value)  $default,){
final _that = this;
switch (_that) {
case _MessageSettings():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageSettings value)?  $default,){
final _that = this;
switch (_that) {
case _MessageSettings() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<MessageType, NotificationLevel> overrides,  Map<MessageDomain, NotificationLevel> domainOverrides)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageSettings() when $default != null:
return $default(_that.overrides,_that.domainOverrides);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<MessageType, NotificationLevel> overrides,  Map<MessageDomain, NotificationLevel> domainOverrides)  $default,) {final _that = this;
switch (_that) {
case _MessageSettings():
return $default(_that.overrides,_that.domainOverrides);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<MessageType, NotificationLevel> overrides,  Map<MessageDomain, NotificationLevel> domainOverrides)?  $default,) {final _that = this;
switch (_that) {
case _MessageSettings() when $default != null:
return $default(_that.overrides,_that.domainOverrides);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageSettings implements MessageSettings {
  const _MessageSettings({final  Map<MessageType, NotificationLevel> overrides = const {}, final  Map<MessageDomain, NotificationLevel> domainOverrides = const {}}): _overrides = overrides,_domainOverrides = domainOverrides;
  factory _MessageSettings.fromJson(Map<String, dynamic> json) => _$MessageSettingsFromJson(json);

/// Type-level settings take precedence over domain-level settings.
 final  Map<MessageType, NotificationLevel> _overrides;
/// Type-level settings take precedence over domain-level settings.
@override@JsonKey() Map<MessageType, NotificationLevel> get overrides {
  if (_overrides is EqualUnmodifiableMapView) return _overrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_overrides);
}

 final  Map<MessageDomain, NotificationLevel> _domainOverrides;
@override@JsonKey() Map<MessageDomain, NotificationLevel> get domainOverrides {
  if (_domainOverrides is EqualUnmodifiableMapView) return _domainOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_domainOverrides);
}


/// Create a copy of MessageSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageSettingsCopyWith<_MessageSettings> get copyWith => __$MessageSettingsCopyWithImpl<_MessageSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageSettings&&const DeepCollectionEquality().equals(other._overrides, _overrides)&&const DeepCollectionEquality().equals(other._domainOverrides, _domainOverrides));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_overrides),const DeepCollectionEquality().hash(_domainOverrides));

@override
String toString() {
  return 'MessageSettings(overrides: $overrides, domainOverrides: $domainOverrides)';
}


}

/// @nodoc
abstract mixin class _$MessageSettingsCopyWith<$Res> implements $MessageSettingsCopyWith<$Res> {
  factory _$MessageSettingsCopyWith(_MessageSettings value, $Res Function(_MessageSettings) _then) = __$MessageSettingsCopyWithImpl;
@override @useResult
$Res call({
 Map<MessageType, NotificationLevel> overrides, Map<MessageDomain, NotificationLevel> domainOverrides
});




}
/// @nodoc
class __$MessageSettingsCopyWithImpl<$Res>
    implements _$MessageSettingsCopyWith<$Res> {
  __$MessageSettingsCopyWithImpl(this._self, this._then);

  final _MessageSettings _self;
  final $Res Function(_MessageSettings) _then;

/// Create a copy of MessageSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? overrides = null,Object? domainOverrides = null,}) {
  return _then(_MessageSettings(
overrides: null == overrides ? _self._overrides : overrides // ignore: cast_nullable_to_non_nullable
as Map<MessageType, NotificationLevel>,domainOverrides: null == domainOverrides ? _self._domainOverrides : domainOverrides // ignore: cast_nullable_to_non_nullable
as Map<MessageDomain, NotificationLevel>,
  ));
}


}


/// @nodoc
mixin _$Inbox {

 List<GameMessage> get messages; List<GameMessage> get scheduled; List<GameMessage> get archive;
/// Create a copy of Inbox
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InboxCopyWith<Inbox> get copyWith => _$InboxCopyWithImpl<Inbox>(this as Inbox, _$identity);

  /// Serializes this Inbox to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Inbox&&const DeepCollectionEquality().equals(other.messages, messages)&&const DeepCollectionEquality().equals(other.scheduled, scheduled)&&const DeepCollectionEquality().equals(other.archive, archive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(messages),const DeepCollectionEquality().hash(scheduled),const DeepCollectionEquality().hash(archive));

@override
String toString() {
  return 'Inbox(messages: $messages, scheduled: $scheduled, archive: $archive)';
}


}

/// @nodoc
abstract mixin class $InboxCopyWith<$Res>  {
  factory $InboxCopyWith(Inbox value, $Res Function(Inbox) _then) = _$InboxCopyWithImpl;
@useResult
$Res call({
 List<GameMessage> messages, List<GameMessage> scheduled, List<GameMessage> archive
});




}
/// @nodoc
class _$InboxCopyWithImpl<$Res>
    implements $InboxCopyWith<$Res> {
  _$InboxCopyWithImpl(this._self, this._then);

  final Inbox _self;
  final $Res Function(Inbox) _then;

/// Create a copy of Inbox
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messages = null,Object? scheduled = null,Object? archive = null,}) {
  return _then(_self.copyWith(
messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<GameMessage>,scheduled: null == scheduled ? _self.scheduled : scheduled // ignore: cast_nullable_to_non_nullable
as List<GameMessage>,archive: null == archive ? _self.archive : archive // ignore: cast_nullable_to_non_nullable
as List<GameMessage>,
  ));
}

}


/// Adds pattern-matching-related methods to [Inbox].
extension InboxPatterns on Inbox {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Inbox value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Inbox() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Inbox value)  $default,){
final _that = this;
switch (_that) {
case _Inbox():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Inbox value)?  $default,){
final _that = this;
switch (_that) {
case _Inbox() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GameMessage> messages,  List<GameMessage> scheduled,  List<GameMessage> archive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Inbox() when $default != null:
return $default(_that.messages,_that.scheduled,_that.archive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GameMessage> messages,  List<GameMessage> scheduled,  List<GameMessage> archive)  $default,) {final _that = this;
switch (_that) {
case _Inbox():
return $default(_that.messages,_that.scheduled,_that.archive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GameMessage> messages,  List<GameMessage> scheduled,  List<GameMessage> archive)?  $default,) {final _that = this;
switch (_that) {
case _Inbox() when $default != null:
return $default(_that.messages,_that.scheduled,_that.archive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Inbox implements Inbox {
  const _Inbox({final  List<GameMessage> messages = const [], final  List<GameMessage> scheduled = const [], final  List<GameMessage> archive = const []}): _messages = messages,_scheduled = scheduled,_archive = archive;
  factory _Inbox.fromJson(Map<String, dynamic> json) => _$InboxFromJson(json);

 final  List<GameMessage> _messages;
@override@JsonKey() List<GameMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

 final  List<GameMessage> _scheduled;
@override@JsonKey() List<GameMessage> get scheduled {
  if (_scheduled is EqualUnmodifiableListView) return _scheduled;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scheduled);
}

 final  List<GameMessage> _archive;
@override@JsonKey() List<GameMessage> get archive {
  if (_archive is EqualUnmodifiableListView) return _archive;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_archive);
}


/// Create a copy of Inbox
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InboxCopyWith<_Inbox> get copyWith => __$InboxCopyWithImpl<_Inbox>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InboxToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Inbox&&const DeepCollectionEquality().equals(other._messages, _messages)&&const DeepCollectionEquality().equals(other._scheduled, _scheduled)&&const DeepCollectionEquality().equals(other._archive, _archive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages),const DeepCollectionEquality().hash(_scheduled),const DeepCollectionEquality().hash(_archive));

@override
String toString() {
  return 'Inbox(messages: $messages, scheduled: $scheduled, archive: $archive)';
}


}

/// @nodoc
abstract mixin class _$InboxCopyWith<$Res> implements $InboxCopyWith<$Res> {
  factory _$InboxCopyWith(_Inbox value, $Res Function(_Inbox) _then) = __$InboxCopyWithImpl;
@override @useResult
$Res call({
 List<GameMessage> messages, List<GameMessage> scheduled, List<GameMessage> archive
});




}
/// @nodoc
class __$InboxCopyWithImpl<$Res>
    implements _$InboxCopyWith<$Res> {
  __$InboxCopyWithImpl(this._self, this._then);

  final _Inbox _self;
  final $Res Function(_Inbox) _then;

/// Create a copy of Inbox
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messages = null,Object? scheduled = null,Object? archive = null,}) {
  return _then(_Inbox(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<GameMessage>,scheduled: null == scheduled ? _self._scheduled : scheduled // ignore: cast_nullable_to_non_nullable
as List<GameMessage>,archive: null == archive ? _self._archive : archive // ignore: cast_nullable_to_non_nullable
as List<GameMessage>,
  ));
}


}

// dart format on
