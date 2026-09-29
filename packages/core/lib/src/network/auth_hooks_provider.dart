import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'auth_interceptor.dart';

part 'auth_hooks_provider.g.dart';

/// keepAlive: read once when the Dio is built. The default has no token, so
/// requests go out unauthenticated. Step 4.2 binds it to the session with a
/// closure that reads the session only when a request is made, which is why
/// building the Dio never touches the session and there is no cycle.
@Riverpod(keepAlive: true)
AuthTokenGetter authTokenGetter(Ref ref) =>
    () => null;

/// keepAlive, same reason. The default does nothing; step 4.2 binds it to a
/// local sign-out.
@Riverpod(keepAlive: true)
UnauthorizedCallback unauthorizedCallback(Ref ref) => () {};
