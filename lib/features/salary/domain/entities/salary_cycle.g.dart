// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salary_cycle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SalaryCycle _$SalaryCycleFromJson(Map<String, dynamic> json) => _SalaryCycle(
  id: json['id'] as String,
  userId: json['userId'] as String,
  incomeMinorUnits: (json['incomeMinorUnits'] as num).toInt(),
  currencyCode: json['currencyCode'] as String,
  startedAt: DateTime.parse(json['startedAt'] as String),
  endedAt: json['endedAt'] == null
      ? null
      : DateTime.parse(json['endedAt'] as String),
  savedMinorUnits: (json['savedMinorUnits'] as num?)?.toInt() ?? 0,
  disposition: $enumDecodeNullable(
    _$CycleDispositionEnumMap,
    json['disposition'],
  ),
);

Map<String, dynamic> _$SalaryCycleToJson(_SalaryCycle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'incomeMinorUnits': instance.incomeMinorUnits,
      'currencyCode': instance.currencyCode,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'savedMinorUnits': instance.savedMinorUnits,
      'disposition': _$CycleDispositionEnumMap[instance.disposition],
    };

const _$CycleDispositionEnumMap = {
  CycleDisposition.savings: 'savings',
  CycleDisposition.spent: 'spent',
};
