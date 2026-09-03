// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Expense {

 String get id; String get groupId; String get description; String get payerId; int get amountMinorUnits; String get currencyCode; SplitType get splitType;/// Everyone who shares this expense (may include the payer).
 List<String> get participantIds; DateTime get createdAt;/// EXACT split: userId -> owed minor units. Null for other split types.
 Map<String, int>? get exactShares;/// PERCENT split: userId -> basis points (10000 == 100%). Null otherwise.
 Map<String, int>? get percentShares;
/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseCopyWith<Expense> get copyWith => _$ExpenseCopyWithImpl<Expense>(this as Expense, _$identity);

  /// Serializes this Expense to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Expense;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Expense&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.groupId, _this.groupId) || other.groupId == _this.groupId)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.payerId, _this.payerId) || other.payerId == _this.payerId)&&(identical(other.amountMinorUnits, _this.amountMinorUnits) || other.amountMinorUnits == _this.amountMinorUnits)&&(identical(other.currencyCode, _this.currencyCode) || other.currencyCode == _this.currencyCode)&&(identical(other.splitType, _this.splitType) || other.splitType == _this.splitType)&&const DeepCollectionEquality().equals(other.participantIds, _this.participantIds)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&const DeepCollectionEquality().equals(other.exactShares, _this.exactShares)&&const DeepCollectionEquality().equals(other.percentShares, _this.percentShares));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Expense;
  return Object.hash(runtimeType,_this.id,_this.groupId,_this.description,_this.payerId,_this.amountMinorUnits,_this.currencyCode,_this.splitType,const DeepCollectionEquality().hash(_this.participantIds),_this.createdAt,const DeepCollectionEquality().hash(_this.exactShares),const DeepCollectionEquality().hash(_this.percentShares));
}

@override
String toString() {
  final _this = this as Expense;
  return 'Expense(id: ${_this.id}, groupId: ${_this.groupId}, description: ${_this.description}, payerId: ${_this.payerId}, amountMinorUnits: ${_this.amountMinorUnits}, currencyCode: ${_this.currencyCode}, splitType: ${_this.splitType}, participantIds: ${_this.participantIds}, createdAt: ${_this.createdAt}, exactShares: ${_this.exactShares}, percentShares: ${_this.percentShares})';
}


}

/// @nodoc
abstract mixin class $ExpenseCopyWith<$Res>  {
  factory $ExpenseCopyWith(Expense value, $Res Function(Expense) _then) = _$ExpenseCopyWithImpl;
@useResult
$Res call({
 String id, String groupId, String description, String payerId, int amountMinorUnits, String currencyCode, SplitType splitType, List<String> participantIds, DateTime createdAt, Map<String, int>? exactShares, Map<String, int>? percentShares
});




}
/// @nodoc
class _$ExpenseCopyWithImpl<$Res>
    implements $ExpenseCopyWith<$Res> {
  _$ExpenseCopyWithImpl(this._self, this._then);

  final Expense _self;
  final $Res Function(Expense) _then;

/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupId = null,Object? description = null,Object? payerId = null,Object? amountMinorUnits = null,Object? currencyCode = null,Object? splitType = null,Object? participantIds = null,Object? createdAt = null,Object? exactShares = freezed,Object? percentShares = freezed,}) {
  return _then(Expense(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,payerId: null == payerId ? _self.payerId : payerId // ignore: cast_nullable_to_non_nullable
as String,amountMinorUnits: null == amountMinorUnits ? _self.amountMinorUnits : amountMinorUnits // ignore: cast_nullable_to_non_nullable
as int,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,splitType: null == splitType ? _self.splitType : splitType // ignore: cast_nullable_to_non_nullable
as SplitType,participantIds: null == participantIds ? _self.participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,exactShares: freezed == exactShares ? _self.exactShares : exactShares // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,percentShares: freezed == percentShares ? _self.percentShares : percentShares // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Expense].
extension ExpensePatterns on Expense {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Expense value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Expense() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Expense value)  $default,){
final _that = this;
switch (_that) {
case _Expense():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Expense value)?  $default,){
final _that = this;
switch (_that) {
case _Expense() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String groupId,  String description,  String payerId,  int amountMinorUnits,  String currencyCode,  SplitType splitType,  List<String> participantIds,  DateTime createdAt,  Map<String, int>? exactShares,  Map<String, int>? percentShares)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Expense() when $default != null:
return $default(_that.id,_that.groupId,_that.description,_that.payerId,_that.amountMinorUnits,_that.currencyCode,_that.splitType,_that.participantIds,_that.createdAt,_that.exactShares,_that.percentShares);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String groupId,  String description,  String payerId,  int amountMinorUnits,  String currencyCode,  SplitType splitType,  List<String> participantIds,  DateTime createdAt,  Map<String, int>? exactShares,  Map<String, int>? percentShares)  $default,) {final _that = this;
switch (_that) {
case _Expense():
return $default(_that.id,_that.groupId,_that.description,_that.payerId,_that.amountMinorUnits,_that.currencyCode,_that.splitType,_that.participantIds,_that.createdAt,_that.exactShares,_that.percentShares);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String groupId,  String description,  String payerId,  int amountMinorUnits,  String currencyCode,  SplitType splitType,  List<String> participantIds,  DateTime createdAt,  Map<String, int>? exactShares,  Map<String, int>? percentShares)?  $default,) {final _that = this;
switch (_that) {
case _Expense() when $default != null:
return $default(_that.id,_that.groupId,_that.description,_that.payerId,_that.amountMinorUnits,_that.currencyCode,_that.splitType,_that.participantIds,_that.createdAt,_that.exactShares,_that.percentShares);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Expense extends Expense {
  const _Expense({required this.id, required this.groupId, required this.description, required this.payerId, required this.amountMinorUnits, required this.currencyCode, required this.splitType, required  List<String> participantIds, required this.createdAt,  Map<String, int>? exactShares,  Map<String, int>? percentShares}): _participantIds = participantIds,_exactShares = exactShares,_percentShares = percentShares,super._();
  factory _Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);

@override final  String id;
@override final  String groupId;
@override final  String description;
@override final  String payerId;
@override final  int amountMinorUnits;
@override final  String currencyCode;
@override final  SplitType splitType;
/// Everyone who shares this expense (may include the payer).
 final  List<String> _participantIds;
/// Everyone who shares this expense (may include the payer).
@override List<String> get participantIds {
  if (_participantIds is EqualUnmodifiableListView) return _participantIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantIds);
}

@override final  DateTime createdAt;
/// EXACT split: userId -> owed minor units. Null for other split types.
 final  Map<String, int>? _exactShares;
/// EXACT split: userId -> owed minor units. Null for other split types.
@override Map<String, int>? get exactShares {
  final value = _exactShares;
  if (value == null) return null;
  if (_exactShares is EqualUnmodifiableMapView) return _exactShares;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// PERCENT split: userId -> basis points (10000 == 100%). Null otherwise.
 final  Map<String, int>? _percentShares;
/// PERCENT split: userId -> basis points (10000 == 100%). Null otherwise.
@override Map<String, int>? get percentShares {
  final value = _percentShares;
  if (value == null) return null;
  if (_percentShares is EqualUnmodifiableMapView) return _percentShares;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseCopyWith<_Expense> get copyWith => __$ExpenseCopyWithImpl<_Expense>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Expense&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.description, description) || other.description == description)&&(identical(other.payerId, payerId) || other.payerId == payerId)&&(identical(other.amountMinorUnits, amountMinorUnits) || other.amountMinorUnits == amountMinorUnits)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.splitType, splitType) || other.splitType == splitType)&&const DeepCollectionEquality().equals(other.participantIds, _participantIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.exactShares, _exactShares)&&const DeepCollectionEquality().equals(other.percentShares, _percentShares));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,groupId,description,payerId,amountMinorUnits,currencyCode,splitType,const DeepCollectionEquality().hash(_participantIds),createdAt,const DeepCollectionEquality().hash(_exactShares),const DeepCollectionEquality().hash(_percentShares));
}

@override
String toString() {
    return 'Expense(id: $id, groupId: $groupId, description: $description, payerId: $payerId, amountMinorUnits: $amountMinorUnits, currencyCode: $currencyCode, splitType: $splitType, participantIds: $participantIds, createdAt: $createdAt, exactShares: $exactShares, percentShares: $percentShares)';
}


}

/// @nodoc
abstract mixin class _$ExpenseCopyWith<$Res> implements $ExpenseCopyWith<$Res> {
  factory _$ExpenseCopyWith(_Expense value, $Res Function(_Expense) _then) = __$ExpenseCopyWithImpl;
@override @useResult
$Res call({
 String id, String groupId, String description, String payerId, int amountMinorUnits, String currencyCode, SplitType splitType, List<String> participantIds, DateTime createdAt, Map<String, int>? exactShares, Map<String, int>? percentShares
});




}
/// @nodoc
class __$ExpenseCopyWithImpl<$Res>
    implements _$ExpenseCopyWith<$Res> {
  __$ExpenseCopyWithImpl(this._self, this._then);

  final _Expense _self;
  final $Res Function(_Expense) _then;

/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupId = null,Object? description = null,Object? payerId = null,Object? amountMinorUnits = null,Object? currencyCode = null,Object? splitType = null,Object? participantIds = null,Object? createdAt = null,Object? exactShares = freezed,Object? percentShares = freezed,}) {
  return _then(_Expense(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,payerId: null == payerId ? _self.payerId : payerId // ignore: cast_nullable_to_non_nullable
as String,amountMinorUnits: null == amountMinorUnits ? _self.amountMinorUnits : amountMinorUnits // ignore: cast_nullable_to_non_nullable
as int,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,splitType: null == splitType ? _self.splitType : splitType // ignore: cast_nullable_to_non_nullable
as SplitType,participantIds: null == participantIds ? _self._participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,exactShares: freezed == exactShares ? _self._exactShares : exactShares // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,percentShares: freezed == percentShares ? _self._percentShares : percentShares // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,
  ));
}


}

// dart format on
