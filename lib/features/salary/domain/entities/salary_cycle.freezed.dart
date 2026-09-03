// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'salary_cycle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SalaryCycle {

 String get id; String get userId; int get incomeMinorUnits; String get currencyCode; DateTime get startedAt;/// Null while the cycle is active; set when closed.
 DateTime? get endedAt;/// Amount moved to savings when closed (0 if used up).
 int get savedMinorUnits;/// How the leftover was handled (null while active).
 CycleDisposition? get disposition;
/// Create a copy of SalaryCycle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalaryCycleCopyWith<SalaryCycle> get copyWith => _$SalaryCycleCopyWithImpl<SalaryCycle>(this as SalaryCycle, _$identity);

  /// Serializes this SalaryCycle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SalaryCycle;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalaryCycle&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.incomeMinorUnits, _this.incomeMinorUnits) || other.incomeMinorUnits == _this.incomeMinorUnits)&&(identical(other.currencyCode, _this.currencyCode) || other.currencyCode == _this.currencyCode)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt)&&(identical(other.savedMinorUnits, _this.savedMinorUnits) || other.savedMinorUnits == _this.savedMinorUnits)&&(identical(other.disposition, _this.disposition) || other.disposition == _this.disposition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SalaryCycle;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.incomeMinorUnits,_this.currencyCode,_this.startedAt,_this.endedAt,_this.savedMinorUnits,_this.disposition);
}

@override
String toString() {
  final _this = this as SalaryCycle;
  return 'SalaryCycle(id: ${_this.id}, userId: ${_this.userId}, incomeMinorUnits: ${_this.incomeMinorUnits}, currencyCode: ${_this.currencyCode}, startedAt: ${_this.startedAt}, endedAt: ${_this.endedAt}, savedMinorUnits: ${_this.savedMinorUnits}, disposition: ${_this.disposition})';
}


}

/// @nodoc
abstract mixin class $SalaryCycleCopyWith<$Res>  {
  factory $SalaryCycleCopyWith(SalaryCycle value, $Res Function(SalaryCycle) _then) = _$SalaryCycleCopyWithImpl;
@useResult
$Res call({
 String id, String userId, int incomeMinorUnits, String currencyCode, DateTime startedAt, DateTime? endedAt, int savedMinorUnits, CycleDisposition? disposition
});




}
/// @nodoc
class _$SalaryCycleCopyWithImpl<$Res>
    implements $SalaryCycleCopyWith<$Res> {
  _$SalaryCycleCopyWithImpl(this._self, this._then);

  final SalaryCycle _self;
  final $Res Function(SalaryCycle) _then;

/// Create a copy of SalaryCycle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? incomeMinorUnits = null,Object? currencyCode = null,Object? startedAt = null,Object? endedAt = freezed,Object? savedMinorUnits = null,Object? disposition = freezed,}) {
  return _then(SalaryCycle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,incomeMinorUnits: null == incomeMinorUnits ? _self.incomeMinorUnits : incomeMinorUnits // ignore: cast_nullable_to_non_nullable
as int,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,savedMinorUnits: null == savedMinorUnits ? _self.savedMinorUnits : savedMinorUnits // ignore: cast_nullable_to_non_nullable
as int,disposition: freezed == disposition ? _self.disposition : disposition // ignore: cast_nullable_to_non_nullable
as CycleDisposition?,
  ));
}

}


/// Adds pattern-matching-related methods to [SalaryCycle].
extension SalaryCyclePatterns on SalaryCycle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalaryCycle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalaryCycle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalaryCycle value)  $default,){
final _that = this;
switch (_that) {
case _SalaryCycle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalaryCycle value)?  $default,){
final _that = this;
switch (_that) {
case _SalaryCycle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  int incomeMinorUnits,  String currencyCode,  DateTime startedAt,  DateTime? endedAt,  int savedMinorUnits,  CycleDisposition? disposition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalaryCycle() when $default != null:
return $default(_that.id,_that.userId,_that.incomeMinorUnits,_that.currencyCode,_that.startedAt,_that.endedAt,_that.savedMinorUnits,_that.disposition);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  int incomeMinorUnits,  String currencyCode,  DateTime startedAt,  DateTime? endedAt,  int savedMinorUnits,  CycleDisposition? disposition)  $default,) {final _that = this;
switch (_that) {
case _SalaryCycle():
return $default(_that.id,_that.userId,_that.incomeMinorUnits,_that.currencyCode,_that.startedAt,_that.endedAt,_that.savedMinorUnits,_that.disposition);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  int incomeMinorUnits,  String currencyCode,  DateTime startedAt,  DateTime? endedAt,  int savedMinorUnits,  CycleDisposition? disposition)?  $default,) {final _that = this;
switch (_that) {
case _SalaryCycle() when $default != null:
return $default(_that.id,_that.userId,_that.incomeMinorUnits,_that.currencyCode,_that.startedAt,_that.endedAt,_that.savedMinorUnits,_that.disposition);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SalaryCycle extends SalaryCycle {
  const _SalaryCycle({required this.id, required this.userId, required this.incomeMinorUnits, required this.currencyCode, required this.startedAt, this.endedAt, this.savedMinorUnits = 0, this.disposition}): super._();
  factory _SalaryCycle.fromJson(Map<String, dynamic> json) => _$SalaryCycleFromJson(json);

@override final  String id;
@override final  String userId;
@override final  int incomeMinorUnits;
@override final  String currencyCode;
@override final  DateTime startedAt;
/// Null while the cycle is active; set when closed.
@override final  DateTime? endedAt;
/// Amount moved to savings when closed (0 if used up).
@override@JsonKey() final  int savedMinorUnits;
/// How the leftover was handled (null while active).
@override final  CycleDisposition? disposition;

/// Create a copy of SalaryCycle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalaryCycleCopyWith<_SalaryCycle> get copyWith => __$SalaryCycleCopyWithImpl<_SalaryCycle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalaryCycleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalaryCycle&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.incomeMinorUnits, incomeMinorUnits) || other.incomeMinorUnits == incomeMinorUnits)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.savedMinorUnits, savedMinorUnits) || other.savedMinorUnits == savedMinorUnits)&&(identical(other.disposition, disposition) || other.disposition == disposition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,incomeMinorUnits,currencyCode,startedAt,endedAt,savedMinorUnits,disposition);
}

@override
String toString() {
    return 'SalaryCycle(id: $id, userId: $userId, incomeMinorUnits: $incomeMinorUnits, currencyCode: $currencyCode, startedAt: $startedAt, endedAt: $endedAt, savedMinorUnits: $savedMinorUnits, disposition: $disposition)';
}


}

/// @nodoc
abstract mixin class _$SalaryCycleCopyWith<$Res> implements $SalaryCycleCopyWith<$Res> {
  factory _$SalaryCycleCopyWith(_SalaryCycle value, $Res Function(_SalaryCycle) _then) = __$SalaryCycleCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, int incomeMinorUnits, String currencyCode, DateTime startedAt, DateTime? endedAt, int savedMinorUnits, CycleDisposition? disposition
});




}
/// @nodoc
class __$SalaryCycleCopyWithImpl<$Res>
    implements _$SalaryCycleCopyWith<$Res> {
  __$SalaryCycleCopyWithImpl(this._self, this._then);

  final _SalaryCycle _self;
  final $Res Function(_SalaryCycle) _then;

/// Create a copy of SalaryCycle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? incomeMinorUnits = null,Object? currencyCode = null,Object? startedAt = null,Object? endedAt = freezed,Object? savedMinorUnits = null,Object? disposition = freezed,}) {
  return _then(_SalaryCycle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,incomeMinorUnits: null == incomeMinorUnits ? _self.incomeMinorUnits : incomeMinorUnits // ignore: cast_nullable_to_non_nullable
as int,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,savedMinorUnits: null == savedMinorUnits ? _self.savedMinorUnits : savedMinorUnits // ignore: cast_nullable_to_non_nullable
as int,disposition: freezed == disposition ? _self.disposition : disposition // ignore: cast_nullable_to_non_nullable
as CycleDisposition?,
  ));
}


}

// dart format on
