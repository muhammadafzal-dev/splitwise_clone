// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Budget {

 String get id; String get userId; ExpenseCategory get category; int get monthlyLimitMinorUnits; String get currencyCode;
/// Create a copy of Budget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetCopyWith<Budget> get copyWith => _$BudgetCopyWithImpl<Budget>(this as Budget, _$identity);

  /// Serializes this Budget to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Budget;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Budget&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.monthlyLimitMinorUnits, _this.monthlyLimitMinorUnits) || other.monthlyLimitMinorUnits == _this.monthlyLimitMinorUnits)&&(identical(other.currencyCode, _this.currencyCode) || other.currencyCode == _this.currencyCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Budget;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.category,_this.monthlyLimitMinorUnits,_this.currencyCode);
}

@override
String toString() {
  final _this = this as Budget;
  return 'Budget(id: ${_this.id}, userId: ${_this.userId}, category: ${_this.category}, monthlyLimitMinorUnits: ${_this.monthlyLimitMinorUnits}, currencyCode: ${_this.currencyCode})';
}


}

/// @nodoc
abstract mixin class $BudgetCopyWith<$Res>  {
  factory $BudgetCopyWith(Budget value, $Res Function(Budget) _then) = _$BudgetCopyWithImpl;
@useResult
$Res call({
 String id, String userId, ExpenseCategory category, int monthlyLimitMinorUnits, String currencyCode
});




}
/// @nodoc
class _$BudgetCopyWithImpl<$Res>
    implements $BudgetCopyWith<$Res> {
  _$BudgetCopyWithImpl(this._self, this._then);

  final Budget _self;
  final $Res Function(Budget) _then;

/// Create a copy of Budget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? category = null,Object? monthlyLimitMinorUnits = null,Object? currencyCode = null,}) {
  return _then(Budget(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExpenseCategory,monthlyLimitMinorUnits: null == monthlyLimitMinorUnits ? _self.monthlyLimitMinorUnits : monthlyLimitMinorUnits // ignore: cast_nullable_to_non_nullable
as int,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Budget].
extension BudgetPatterns on Budget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Budget value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Budget() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Budget value)  $default,){
final _that = this;
switch (_that) {
case _Budget():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Budget value)?  $default,){
final _that = this;
switch (_that) {
case _Budget() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  ExpenseCategory category,  int monthlyLimitMinorUnits,  String currencyCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Budget() when $default != null:
return $default(_that.id,_that.userId,_that.category,_that.monthlyLimitMinorUnits,_that.currencyCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  ExpenseCategory category,  int monthlyLimitMinorUnits,  String currencyCode)  $default,) {final _that = this;
switch (_that) {
case _Budget():
return $default(_that.id,_that.userId,_that.category,_that.monthlyLimitMinorUnits,_that.currencyCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  ExpenseCategory category,  int monthlyLimitMinorUnits,  String currencyCode)?  $default,) {final _that = this;
switch (_that) {
case _Budget() when $default != null:
return $default(_that.id,_that.userId,_that.category,_that.monthlyLimitMinorUnits,_that.currencyCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Budget extends Budget {
  const _Budget({required this.id, required this.userId, required this.category, required this.monthlyLimitMinorUnits, required this.currencyCode}): super._();
  factory _Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);

@override final  String id;
@override final  String userId;
@override final  ExpenseCategory category;
@override final  int monthlyLimitMinorUnits;
@override final  String currencyCode;

/// Create a copy of Budget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetCopyWith<_Budget> get copyWith => __$BudgetCopyWithImpl<_Budget>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Budget&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.category, category) || other.category == category)&&(identical(other.monthlyLimitMinorUnits, monthlyLimitMinorUnits) || other.monthlyLimitMinorUnits == monthlyLimitMinorUnits)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,category,monthlyLimitMinorUnits,currencyCode);
}

@override
String toString() {
    return 'Budget(id: $id, userId: $userId, category: $category, monthlyLimitMinorUnits: $monthlyLimitMinorUnits, currencyCode: $currencyCode)';
}


}

/// @nodoc
abstract mixin class _$BudgetCopyWith<$Res> implements $BudgetCopyWith<$Res> {
  factory _$BudgetCopyWith(_Budget value, $Res Function(_Budget) _then) = __$BudgetCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, ExpenseCategory category, int monthlyLimitMinorUnits, String currencyCode
});




}
/// @nodoc
class __$BudgetCopyWithImpl<$Res>
    implements _$BudgetCopyWith<$Res> {
  __$BudgetCopyWithImpl(this._self, this._then);

  final _Budget _self;
  final $Res Function(_Budget) _then;

/// Create a copy of Budget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? category = null,Object? monthlyLimitMinorUnits = null,Object? currencyCode = null,}) {
  return _then(_Budget(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExpenseCategory,monthlyLimitMinorUnits: null == monthlyLimitMinorUnits ? _self.monthlyLimitMinorUnits : monthlyLimitMinorUnits // ignore: cast_nullable_to_non_nullable
as int,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
