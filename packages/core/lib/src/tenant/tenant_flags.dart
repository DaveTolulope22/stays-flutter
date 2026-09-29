import 'package:freezed_annotation/freezed_annotation.dart';

part 'tenant_flags.freezed.dart';
part 'tenant_flags.g.dart';

/// The runtime config's `permissions` map. Each flag decides whether a
/// feature EXISTS in this tenant's build. A flag the API omits is off: a
/// feature must never appear because of a missing key.
///
/// The API does not enforce these; turning something off is the app's job.
@freezed
abstract class TenantFlags with _$TenantFlags {
  const factory TenantFlags({
    @Default(false) bool hostPanel,
    @Default(false) bool favourites,
    @Default(false) bool reviews,
    @Default(false) bool blockedDays,
  }) = _TenantFlags;

  factory TenantFlags.fromJson(Map<String, dynamic> json) =>
      _$TenantFlagsFromJson(json);
}
