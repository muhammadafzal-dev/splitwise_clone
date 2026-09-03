// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Expense _$ExpenseFromJson(Map<String, dynamic> json) => _Expense(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  description: json['description'] as String,
  payerId: json['payerId'] as String,
  amountMinorUnits: (json['amountMinorUnits'] as num).toInt(),
  currencyCode: json['currencyCode'] as String,
  splitType: $enumDecode(_$SplitTypeEnumMap, json['splitType']),
  participantIds: (json['participantIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  exactShares: (json['exactShares'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
  percentShares: (json['percentShares'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
  category:
      $enumDecodeNullable(_$ExpenseCategoryEnumMap, json['category']) ??
      ExpenseCategory.other,
);

Map<String, dynamic> _$ExpenseToJson(_Expense instance) => <String, dynamic>{
  'id': instance.id,
  'groupId': instance.groupId,
  'description': instance.description,
  'payerId': instance.payerId,
  'amountMinorUnits': instance.amountMinorUnits,
  'currencyCode': instance.currencyCode,
  'splitType': _$SplitTypeEnumMap[instance.splitType]!,
  'participantIds': instance.participantIds,
  'createdAt': instance.createdAt.toIso8601String(),
  'exactShares': instance.exactShares,
  'percentShares': instance.percentShares,
  'category': _$ExpenseCategoryEnumMap[instance.category]!,
};

const _$SplitTypeEnumMap = {
  SplitType.equal: 'equal',
  SplitType.exact: 'exact',
  SplitType.percent: 'percent',
};

const _$ExpenseCategoryEnumMap = {
  ExpenseCategory.food: 'food',
  ExpenseCategory.groceries: 'groceries',
  ExpenseCategory.rent: 'rent',
  ExpenseCategory.utilities: 'utilities',
  ExpenseCategory.transport: 'transport',
  ExpenseCategory.entertainment: 'entertainment',
  ExpenseCategory.travel: 'travel',
  ExpenseCategory.shopping: 'shopping',
  ExpenseCategory.health: 'health',
  ExpenseCategory.other: 'other',
};
