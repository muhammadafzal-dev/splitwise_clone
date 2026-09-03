// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Settlement _$SettlementFromJson(Map<String, dynamic> json) => _Settlement(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  fromUserId: json['fromUserId'] as String,
  toUserId: json['toUserId'] as String,
  amountMinorUnits: (json['amountMinorUnits'] as num).toInt(),
  currencyCode: json['currencyCode'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$SettlementToJson(_Settlement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'fromUserId': instance.fromUserId,
      'toUserId': instance.toUserId,
      'amountMinorUnits': instance.amountMinorUnits,
      'currencyCode': instance.currencyCode,
      'createdAt': instance.createdAt.toIso8601String(),
    };
