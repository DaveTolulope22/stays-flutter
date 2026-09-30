import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:feature_host/feature_host.dart';
import 'package:fpdart/fpdart.dart';
import 'package:listings/listings.dart';

import 'fake_listings_repository.dart';

/// The one listing the shell tests see on the host's screen. Its title differs
/// from [shellListing], so a test can tell the host side from the guest side by
/// text alone.
final shellHostListing = shellListing.copyWith(title: 'Host chalet');

/// Answers the host's listings with [shellHostListing]. No network in tests.
class FakeHostRepository extends HostRepository {
  FakeHostRepository() : super(dio: Dio(), tenant: 'acme');

  @override
  TaskEither<AppFailure, CursorPage<Listing>> listings({
    String? cursor,
    int limit = HostRepository.defaultPageSize,
  }) => TaskEither.right(CursorPage(items: [shellHostListing], total: 1));
}
