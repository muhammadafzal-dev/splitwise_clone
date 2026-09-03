// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settlement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Settlement {

 String get id; String get groupId; String get fromUserId; String get toUserId; int get amountMinorUnits; String get currencyCode; DateTime get createdAt;
/// Create a copy of Settlement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettlementCopyWith<Settlement> get copyWith => _$SettlementCopyWithImpl<Settlement>(this as Settlement, _$identity);

  /// Serializes this Settlement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Settlement;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Settlement&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.groupId, _this.groupId) || other.groupId == _this.groupId)&&(identical(other.fromUserId, _this.fromUserId) || other.fromUserId == _this.fromUserId)&&(identical(other.toUserId, _this.toUserId) || other.toUserId == _this.toUserId)&&(identical(other.amountMinorUnits, _this.amountMinorUnits) || other.amountMinorUnits == _this.amountMinorUnits)&&(identical(other.currencyCode, _this.currencyCode) || other.currencyCode == _this.currencyCode)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Settlement;
  return Object.hash(runtimeType,_this.id,_this.groupId,_this.fromUserId,_this.toUserId,_this.amountMinorUnits,_this.currencyCode,_this.createdAt);
}

@override
String toString() {
  final _this = this as Settlement;
  return 'Settlement(id: ${_this.id}, groupId: ${_this.groupId}, fromUserId: ${_this.fromUserId}, toUserId: ${_this.toUserId}, amountMinorUnits: ${_this.amountMinorUnits}, currencyCode: ${_this.currencyCode}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $SettlementCopyWith<$Res>  {
  factory $SettlementCopyWith(Settlement value, $Res Function(Settlement) _then) = _$SettlementCopyWithImpl;
@useResult
$Res call({
 String id, String groupId, String fromUserId, String toUserId, int amountMinorUnits, String currencyCode, DateTime createdAt
});




}
/// @nodoc
class _$SettlementCopyWithImpl<$Res>
    implements $SettlementCopyWith<$Res> {
  _$SettlementCopyWithImpl(this._self, this._then);

  final Settlement _self;
  final $Res Function(Settlement) _then;

/// Create a copy of Settlement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupId = null,Object? fromUserId = null,Object? toUserId = null,Object? amountMinorUnits = null,Object? currencyCode = null,Object? createdAt = null,}) {
  return _then(Settlement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,fromUserId: null == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String,toUserId: null == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String,amountMinorUnits: null == amountMinorUnits ? _self.amountMinorUnits : amountMinorUnits // ignore: cast_nullable_to_non_nullable
as int,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Settlement].
extension SettlementPatterns on Settlement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Settlement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Settlement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Settlement value)  $default,){
final _that = this;
switch (_that) {
case _Settlement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Settlement value)?  $default,){
final _that = this;
switch (_that) {
case _Settlement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String groupId,  String fromUserId,  String toUserId,  int amountMinorUnits,  String currencyCode,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Settlement() when $default != null:
return $default(_that.id,_that.groupId,_that.fromUserId,_that.toUserId,_that.amountMinorUnits,_that.currencyCode,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String groupId,  String fromUserId,  String toUserId,  int amountMinorUnits,  String currencyCode,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Settlement():
return $default(_that.id,_that.groupId,_that.fromUserId,_that.toUserId,_that.amountMinorUnits,_that.currencyCode,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String groupId,  String fromUserId,  String toUserId,  int amountMinorUnits,  String currencyCode,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Settlement() when $default != null:
return $default(_that.id,_that.groupId,_that.fromUserId,_that.toUserId,_that.amountMinorUnits,_that.currencyCode,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Settlement extends Settlement {
  const _Settlement({required this.id, required this.groupId, required this.fromUserId, required this.toUserId, required this.amountMinorUnits, required this.currencyCode, required this.createdAt}): super._();
  factory _Settlement.fromJson(Map<String, dynamic> json) => _$SettlementFromJson(json);

@override final  String id;
@override final  String groupId;
@override final  String fromUserId;
@override final  String toUserId;
@override final  int amountMinorUnits;
@override final  String currencyCode;
@override final  DateTime createdAt;

/// Create a copy of Settlement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettlementCopyWith<_Settlement> get copyWith => __$SettlementCopyWithImpl<_Settlement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SettlementToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Settlement&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.toUserId, toUserId) || other.toUserId == toUserId)&&(identical(other.amountMinorUnits, amountMinorUnits) || other.amountMinorUnits == amountMinorUnits)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,groupId,fromUserId,toUserId,amountMinorUnits,currencyCode,createdAt);
}

@override
String toString() {
    return 'Settlement(id: $id, groupId: $groupId, fromUserId: $fromUserId, toUserId: $toUserId, amountMinorUnits: $amountMinorUnits, currencyCode: $currencyCode, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SettlementCopyWith<$Res> implements $SettlementCopyWith<$Res> {
  factory _$SettlementCopyWith(_Settlement value, $Res Function(_Settlement) _then) = __$SettlementCopyWithImpl;
@override @useResult
$Res call({
 String id, String groupId, String fromUserId, String toUserId, int amountMinorUnits, String currencyCode, DateTime createdAt
});




}
/// @nodoc
class __$SettlementCopyWithImpl<$Res>
    implements _$SettlementCopyWith<$Res> {
  __$SettlementCopyWithImpl(this._self, this._then);

  final _Settlement _self;
  final $Res Function(_Settlement) _then;

/// Create a copy of Settlement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupId = null,Object? fromUserId = null,Object? toUserId = null,Object? amountMinorUnits = null,Object? currencyCode = null,Object? createdAt = null,}) {
  return _then(_Settlement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,fromUserId: null == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String,toUserId: null == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String,amountMinorUnits: null == amountMinorUnits ? _self.amountMinorUnits : amountMinorUnits // ignore: cast_nullable_to_non_nullable
as int,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
