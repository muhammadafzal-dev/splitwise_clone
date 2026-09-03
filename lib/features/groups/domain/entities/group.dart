import 'package:freezed_annotation/freezed_annotation.dart';

part 'group.freezed.dart';
part 'group.g.dart';

/// A shared expense group (e.g. "Apartment", "Trip to Kyoto").
@freezed
abstract class Group with _$Group {
  const factory Group({
    required String id,
    required String name,

    /// Emoji shown as the group icon.
    required String emoji,
    required List<String> memberIds,

    /// ISO 4217 currency code the group settles in.
    required String currencyCode,
    required DateTime createdAt,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}
