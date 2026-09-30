import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'local_date.dart';

part 'clock.g.dart';

/// Answers "what is today's date?". Called, not stored, so an app left open past
/// midnight never keeps yesterday.
typedef DateClock = LocalDate Function();

/// The one place the app reads the device's date. Everything that needs "today"
/// (the date picker's first day, the availability calendar) asks this provider
/// instead of calling `DateTime.now()`, so a test overrides it with a fixed date
/// and never depends on the day it runs.
///
/// keepAlive: it holds no state, only the function.
@Riverpod(keepAlive: true)
DateClock clock(Ref ref) => LocalDate.today;
