# Decisions

Short records of the choices that shaped this codebase. Each one: the context,
what was decided, and what was rejected. Later phases append to this file.

## 001. Package boundaries: mechanisms in shared, decisions in features

**Context:** The brief asks for a thin shell, a feature package and something
shared, and says where the lines are drawn is a large part of the review.

**Decision:** Nine workspace members.

```
stays_app -> feature_* -> listings -> core
                |             |         ^
                +-> design_system, l10n -+
```

- `core` depends on no internal package. `design_system` and `l10n` depend on
  `core` only. `listings` depends on those three. A `feature_*` package
  depends on those four and never on another feature.
- Only `stays_app` knows every feature, so it is the only place that composes
  them.
- Shared packages hold mechanisms (how to call the API, page, represent a
  failure, store a session). Features hold decisions (what a screen shows, who
  may edit).
- `listings` is a domain package because browse, favourites and host all show
  listings.

**Rejected:** `Listing` in `core`, because core would then know the business.
`Listing` in `feature_browse`, because favourites and host would depend on
another feature. A `shared` or `utils` package, because a package with no rule
for what belongs in it becomes a dumping ground. One `lib/` with folders,
because a folder boundary is only a convention.

## 002. `Capabilities` lives in `core`

**Context:** `Capabilities` (what may this person do) is a policy, and `core`
is meant to hold mechanisms. It is read by `listings` (rating badge), by
features (controls) and by the shell (router).

**Decision:** Keep it in `core`. It is a pure function,
`resolveCapabilities(session, tenantFlags)`, so the whole permission matrix is
one table-driven test. It stays abstract (`canSaveListings`, never a route or
a widget), so `core` still knows no screen. No widget reads `role` directly.

**Rejected:** A separate `access` package: one value type and one function
would cost another pubspec, barrel and dependency edge for no gain at this
size. It becomes worth it if the rules grow (per-listing permissions, more
roles).

## 003. Flags decide what exists, role decides where you may go

**Context:** Tenant flags are fixed for the life of the process. The signed-in
user changes during it. Mixing them would make the route table change on every
sign-in and sign-out.

**Decision:**

- Feature modules are registered from tenant flags only. With `favourites` off
  there is no route, no tab, no provider, and no request to `/favourites`.
- The save button on a card is a slot in `listings`, empty by default. The
  shell fills it only when the flag is on, and the button still checks
  `canSaveListings`.
- Role is enforced by a go_router `redirect` driven by the session and
  `Capabilities`, before any screen builds. A client typing a host deep link
  is redirected on the device. The API's 403 is never part of the flow.
- A host sees only the host area (the brief says "instead"): no browse, no
  favourites. A client never reaches host routes.
- `reviews` off also removes "sort by rating". `blockedDays` off makes the
  host calendar read-only. `hostPanel` off shows a localised "host area not
  available" screen with sign-out (an assumption, since both tenants have it
  on).

**Rejected:** Registering modules from the session (the route table would
follow sign-in state). Hiding widgets while leaving routes and providers
alive, which is exactly what the brief says is not enough.

## 004. 401 handling in the auth interceptor

**Context:** A revoked token answers 401 everywhere. But sign-in also answers
401 (`error.badCredentials`) on a wrong password, and sign-out answers 401 for
an already-revoked token. The interceptor needs the token, and the session
controller needs Dio, which would make a provider cycle.

**Decision:** `AuthInterceptor` reads the token through an injected getter and
reports a 401 to the session only when the request carried a Bearer token and
the path is not under `/auth/`. Sign-out always clears local state, even if
the call fails.

**Rejected:** A blanket "any 401 signs out", which would sign out a user who
mistyped a password. Watching the session provider from the Dio provider,
which is a cycle.

## 005. Tenant isolation

**Context:** One tenant's data must never appear in the other's build.

**Decision:** Layered, so no single mistake leaks data.

1. Separate `applicationId` per flavor, so each build has its own sandbox
   (secure storage, prefs, cache).
2. The tenant is a compile-time constant (`--dart-define=TENANT`). There is one
   Dio and one interceptor that stamps `tenant: <slug>` on every request.
3. Secure-storage keys are namespaced by tenant.
4. A restored session whose `user.tenantId` differs from the build tenant is
   discarded.
5. A decoded row with a foreign `tenantId` becomes a `TenantMismatch` failure
   and is never rendered.

`TENANT` is checked only for being non-empty and equal to Flutter's
`appFlavor`. There is deliberately no list of known slugs in Dart, because no
tenant name may appear in code. Tests use made-up slugs.

**Rejected:** Trusting the API's scoping alone. It should be enough, but the
client should not depend on it.

## 006. Theme from tokens

**Context:** Colours arrive at runtime as 8 role tokens for light and dark.
Widgets may not contain hex values or size literals.

**Decision:** An `AppColors` `ThemeExtension` is built from the config, and the
only place a hex string is parsed is the design-system theme source.
`buildTheme` also derives the Material `ColorScheme` from the same tokens, so
stock Material widgets never show default seed colours the tenant did not send.
A missing token falls back to a neutral colour and is logged, never a crash.
Static tokens (`AppSpacing`, `AppRadius`, `AppSizes`, `AppDurations`) cover
dimensions. A test scans widget code for literals, including the
`design_system` widgets and excluding only the token and theme source.

**Rejected:** A `ThemeExtension` only, which would leave stock widgets on the
wrong palette.

## 007. Filter scope

**Context:** The brief lists four filters: city, guests, price range and date
range. The API also supports property type, free-text search and amenities.

**Decision:** Build the four, plus sort, with every control's options and
bounds read from `/listings/facets` (the two tenants price in different
currencies). Property type, search and amenities are extras, taken on only if
time is left. The date range is sent as `checkIn` (inclusive) and `checkOut`
(exclusive), and the picker labels the end date as check-out.

**Rejected:** Building every filter the API offers, which trades depth for
breadth when the brief asks for what is built to be built well.

## 008. Tooling

**Context:** Versions were confirmed on the development machine, and the
current documentation was read for anything that differs from older guides.

**Decision:**

- Flutter 3.47.5 (stable), Dart 3.13.4.
- Melos 8.9.0 on Dart pub workspaces. The config lives under `melos:` in the
  root `pubspec.yaml`, and a per-package script puts its command in
  `exec.command`. Melos is also a root dev dependency, so it is pinned in the
  repo.
- The `analyze` script is `dart analyze --fatal-infos`, not `flutter analyze`.
  With a deliberately bad notifier (a public field), `dart analyze` reported
  the `riverpod_lint` rule and exited 1, while `flutter analyze` reported
  nothing. Using it would mean the Riverpod rules silently never run.
- `riverpod_lint` runs as an analyzer plugin (`plugins:` in
  `analysis_options.yaml`, one root dev dependency). The older `custom_lint`
  route does not resolve alongside Melos 8.
- `build_runner` is run as `dart run build_runner build`. It now ignores
  `--delete-conflicting-outputs`.
- Generated files (`*.g.dart`, `*.freezed.dart`, l10n output) are committed, so
  a reviewer can run the app with one command. CI regenerates and fails if the
  committed output is stale.
- The codegen chain (freezed, json_serializable, riverpod_generator) was
  proved in a throwaway workspace before the repo was shaped around it,
  including a decode test for `"rating": 5` (an int on the wire).

**Rejected:** Melos 7 (superseded by the installed 8.x, whose docs were
checked). `flutter analyze` (see above).

## 009. Dependency versions

Resolved with `pub add` against the toolchain above, and pinned by the
committed `pubspec.lock`.

| Package | Version |
|---|---|
| flutter_riverpod / riverpod | 3.4.3 |
| riverpod_annotation | 4.0.7 |
| riverpod_generator | 4.0.9 |
| riverpod_lint | 3.1.9 |
| freezed / freezed_annotation | 4.0.2 / 3.1.0 |
| json_serializable / json_annotation | 6.14.1 / 4.12.0 |
| build_runner | 2.16.1 |
| dio | 5.11.1 |
| fpdart | 1.2.0 |
| go_router | 18.0.2 |
| flutter_secure_storage | 11.2.0 |
| intl | 0.20.3 |
| mocktail | 1.0.5 |
| melos | 8.9.0 |

## 010. Repository conventions

**Decision:**

- `.gitattributes` forces LF (`* text=auto eol=lf`), whatever a contributor's
  `core.autocrlf` says, so generated-code checks do not fail on line endings.
- `pubspec.lock` is committed: this is an application, and reviewers should
  resolve the versions it was built with.
- Editor folders (`.vscode/`, `.idea/`) and local Android files are ignored.
- Commits are small and Conventional (`feat(auth): restore session on
  launch`), one step per commit.
