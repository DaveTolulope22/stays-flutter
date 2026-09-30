/// Riverpod 3 retries a failed provider with a growing delay by default, which
/// would keep a screen on its spinner instead of showing the error. Every
/// provider that loads from the API sets `retry: noAutomaticRetry`, so it fails
/// once, the screen shows our own error message, and the user chooses Retry.
Duration? noAutomaticRetry(int retryCount, Object error) => null;
