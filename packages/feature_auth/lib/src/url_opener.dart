import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'url_opener.g.dart';

/// Opens a web page outside the app. Returns false if nothing could open it.
typedef UrlOpener = Future<bool> Function(Uri uri);

/// A provider so tests can replace the platform call. It is scoped to the
/// screens that use it (auto-dispose): there is nothing to keep alive.
@riverpod
UrlOpener urlOpener(Ref ref) => (uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Object {
    return false;
  }
};
