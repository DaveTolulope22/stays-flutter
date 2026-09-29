import 'package:json_annotation/json_annotation.dart';

import 'local_date.dart';

/// Reads and writes a [LocalDate] as the API's `YYYY-MM-DD` string. A value
/// that is not a real date throws [FormatException], which `apiCall` turns
/// into an `UnknownFailure`.
class LocalDateConverter implements JsonConverter<LocalDate, String> {
  const LocalDateConverter();

  @override
  LocalDate fromJson(String json) => LocalDate.parse(json);

  @override
  String toJson(LocalDate object) => object.toIso();
}

/// For optional date fields: null stays null.
class NullableLocalDateConverter implements JsonConverter<LocalDate?, String?> {
  const NullableLocalDateConverter();

  @override
  LocalDate? fromJson(String? json) =>
      json == null ? null : LocalDate.parse(json);

  @override
  String? toJson(LocalDate? object) => object?.toIso();
}
