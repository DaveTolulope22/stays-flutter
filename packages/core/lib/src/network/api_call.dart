import 'package:fpdart/fpdart.dart';

import '../failures/api_error_mapper.dart';
import '../failures/app_failure.dart';

/// Runs a data-edge call and turns anything it throws into an [AppFailure].
/// Repositories use this so nothing throws across a layer boundary, and the
/// notifier folds the result into an `AsyncValue`. A decoding error inside
/// [call] is caught too and becomes an `UnknownFailure`.
TaskEither<AppFailure, T> apiCall<T>(Future<T> Function() call) =>
    TaskEither.tryCatch(call, (error, _) => ApiErrorMapper.map(error));
