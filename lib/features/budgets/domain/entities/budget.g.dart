// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Budget _$BudgetFromJson(Map<String, dynamic> json) => _Budget(
  id: json['id'] as String,
  userId: json['userId'] as String,
  category: $enumDecode(_$ExpenseCategoryEnumMap, json['category']),
  monthlyLimitMinorUnits: (json['monthlyLimitMinorUnits'] as num).toInt(),
  currencyCode: json['currencyCode'] as String,
);

Map<String, dynamic> _$BudgetToJson(_Budget instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'category': _$ExpenseCategoryEnumMap[instance.category]!,
  'monthlyLimitMinorUnits': instance.monthlyLimitMinorUnits,
  'currencyCode': instance.currencyCode,
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
