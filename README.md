# Stays

A white-label Flutter app for short-term rentals. One codebase builds two
tenant flavors, `alpine` (Alpine Stays, CHF) and `riviera` (Riviera Rentals,
EUR). Each tenant has its own name, colours, currency, feature flags, launcher
icon and application id, all taken from the API's runtime config rather than
from the code. A **client** browses, filters, views availability and saves
listings. A **host** manages their own listings, blocks days and reads
bookings.

Only Android was built and tested, as the brief allows.

## Toolchain

| | |
|---|---|
| Flutter | 3.47.5 (stable, revision 6a19cca564) |
| Dart | 3.13.4 |
| Node (mock API without Docker) | 18 or newer |

Dependency versions are pinned by the committed `pubspec.lock` (listed in
[ADR 009](docs/DECISIONS.md)). Generated code (`*.g.dart`, `*.freezed.dart`,
l10n output) is committed, so the app runs after `flutter pub get` with no
codegen step.

## Quick start

All commands are PowerShell.

### 1. Start the mock API

From the challenge folder (the one holding `docker-compose.yml`):

```powershell
docker compose up
```

Without Docker:

```powershell
cd mock-api
node server.js
```

It listens on `http://localhost:8080`. Check it with
`curl http://localhost:8080/health`.

Seeded accounts (password `Password1!`):

| Tenant | Role | Email |
|---|---|---|
| alpine | client | `client@alpine-stays.example` |
| alpine | host | `nina@alpine-stays.example` |
| riviera | client | `client@riviera-rentals.example` |
| riviera | host | `olivier@riviera-rentals.example` |

Clients can also register in the app. The API has no endpoint that creates a
host.

### 2. Install dependencies

From the repository root:

```powershell
flutter pub get
```

This resolves the whole workspace (nine packages) from `pubspec.lock`.

### 3. Run a flavor

The app knows two things at compile time: the tenant slug
(`--dart-define=TENANT=...`, which must equal the `--flavor`) and the API base
URL (`API_BASE_URL`, default `http://127.0.0.1:8080`).

**Physical Android phone over USB.** Enable USB debugging, then forward the
port. `adb reverse` resets whenever the phone reconnects, so run it again after
replugging.

```powershell
adb reverse tcp:8080 tcp:8080
cd apps\stays_app
flutter run --flavor alpine --dart-define=TENANT=alpine
flutter run --flavor riviera --dart-define=TENANT=riviera
```

No `API_BASE_URL` is needed: the default `http://127.0.0.1:8080` reaches the
host machine through the reverse port.

**Android emulator.** The emulator reaches the host at `10.0.2.2`:

```powershell
cd apps\stays_app
flutter run --flavor alpine --dart-define=TENANT=alpine --dart-define=API_BASE_URL=http://10.0.2.2:8080
flutter run --flavor riviera --dart-define=TENANT=riviera --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Run one flavor at a time (each `flutter run` is a separate command). The two
flavors have different application ids, so both can be installed side by side
with separate storage.

Debug builds allow cleartext HTTP only to `127.0.0.1`, `localhost` and
`10.0.2.2`. Release builds allow none ([ADR 011](docs/DECISIONS.md)). Listing
photos are remote (`picsum.photos`), so they need internet access.

## Checks

Melos is a dev dependency of the root `pubspec.yaml`, so no global install is
needed. From the repository root, after `flutter pub get`:

```powershell
dart run melos run format:check
dart run melos run gen --no-select
dart run melos run gen:l10n --no-select
dart run melos run analyze --no-select
dart run melos run test --no-select
```

- `analyze` is `dart analyze --fatal-infos`, not `flutter analyze`, so the
  Riverpod lint plugin runs ([ADR 008](docs/DECISIONS.md)).
- `gen` and `gen:l10n` should leave `git status` clean, because generated code
  is committed.
- CI ([.github/workflows/ci.yml](.github/workflows/ci.yml)) runs the same
  steps on every push and pull request, and also fails if generated code is
  stale ([ADR 034](docs/DECISIONS.md)).

## Workspace layout

A pub workspace of nine packages, managed with Melos.

```
stays_app -> feature_* -> listings -> core
                |             |         ^
                +-> design_system, l10n -+
```

| Package | Responsibility |
|---|---|
| `apps/stays_app` | Thin shell. Bootstraps the tenant, builds the router from the feature modules, fills the card's save slot. The only place that knows every feature. |
| `core` | Mechanisms: Dio and interceptors, `AppFailure`, `apiCall`, paging, `LocalDate`, session and secure storage, `Capabilities`, `FeatureModule`, tenant config. Depends on no internal package. |
| `design_system` | Design tokens, the tenant `ThemeExtension`, and generic widgets (`MonthCalendar`, `PagedListView`, loading/error/empty views). Holds no copy and knows no business. |
| `l10n` | ARB files (en, de), generated localisations, `messageCode` to copy mapping. |
| `listings` | The listing domain shared by browse, favourites and host: models, repository, filter value, card. |
| `feature_auth` | Sign-in and register. |
| `feature_browse` | Browse, filters, listing detail, availability. |
| `feature_favourites` | Saved listings, save button. |
| `feature_host` | My listings, edit, blocked-days calendar, bookings. |

### What I refuse to put in the shared packages

- **No screens or business decisions in `core`.** Shared packages hold
  mechanisms (how to call the API, page, represent a failure). Features hold
  decisions (what a screen shows, who may edit).
- **No `shared` or `utils` package.** A package without a rule for what belongs
  in it becomes a dumping ground.
- **No tenant name, currency or feature assumption in Dart.** The only
  compile-time knowledge is the tenant slug. There is no list of known tenants.
- **No feature importing another feature.** The shell composes them. When one
  feature needs to open another's screen, the shell passes in a function
  ([ADR 025](docs/DECISIONS.md)).
- **No copy in `design_system` widgets.** Strings are parameters, supplied from
  ARB.
- **No colour, hex or raw size literal in a widget.** Colours come from the
  runtime config through `AppColors`; sizes come from token classes.

The dependency rule and the literal rules are enforced by tests (see below).

## How the main rules are enforced

### Identity and permission are separate

`Session` says who the user is (`user`, `role`, `tenantId`, token). 
`Capabilities` says what they may do, and is a pure function:
`resolveCapabilities(session, tenantFlags)`. Widgets and routes ask
`Capabilities` (`canSaveListings`, `canSeeReviews`, and so on) and never read
`role`. Flags decide what exists; role decides where you may go
([ADR 002](docs/DECISIONS.md), [003](docs/DECISIONS.md)).

Each `FeatureModule` declares its area (guest, host or none), base path and
routes. The router's `redirect` uses that and the current capabilities, so a
client who opens a host link is redirected on the device, before any screen
builds. A 403 is never part of the flow ([ADR 014](docs/DECISIONS.md),
[015](docs/DECISIONS.md)).

### Tenant isolation

Five layers, so no single mistake leaks data ([ADR 005](docs/DECISIONS.md)):

1. A separate `applicationId` per flavor, so each build has its own sandbox.
2. The tenant is a compile-time constant, and one Dio interceptor stamps the
   `tenant` header on every request.
3. Secure-storage keys are namespaced by tenant.
4. A restored session of another tenant is discarded before any request.
5. A decoded row with a foreign `tenantId` becomes a `TenantMismatch` failure
   and is never rendered.

### Feature flags remove things

Tenant flags are fixed for the life of the process, so modules are registered
from flags only (`modulesFor`). With `favourites` off there is no route, no
tab, no Saved screen, no save control and no provider, and no request to
`/favourites` is ever made ([ADR 026](docs/DECISIONS.md)). `reviews` off also
removes the rating badge and "sort by rating". `blockedDays` off makes the host
calendar read-only. `hostPanel` off replaces the host area with a localised
"not available" screen that still offers sign-out.

### Failures and copy

Repositories return `TaskEither<AppFailure, T>`; nothing throws across a layer
boundary. `AppFailure` is sealed, so the UI switches on it exhaustively. The
server's `message` is never shown: the `messageCode` is mapped to our own ARB
copy (en, de) with a generic fallback for unknown codes. The token lives in
`flutter_secure_storage`.

## Tests

Tests use `mocktail` and Riverpod `ProviderContainer` overrides. No test touches
the network.

- **Core and data edges:** failure mapping, the auth interceptor (401
  handling), paging and cursor headers, `LocalDate` and `DateRange`, session
  restore, capabilities as a table-driven matrix. These are the rules most
  likely to be wrong in a subtle way, and they are pure and cheap to test.
- **Repositories and notifiers:** every response shape, including the traps in
  the API (numbers that arrive as `int` or `double`, unknown enum values, a
  foreign tenant row). Optimistic updates (save, block day) are tested for
  rollback of only the affected item.
- **Widget tests:** loading, empty and error states, filter sheet, listing
  detail, edit form, host calendar and bookings.
- **Flag proofs on the real shell** (`favourites_flag_test.dart`,
  `host_flags_test.dart`): the real router and providers run over a Dio adapter
  that records requests. They assert that a disabled feature has no route, no
  tab, no control and sends no request, and a positive control proves the
  recorder would have seen one on the flag-on side.
- **Guard tests** (`apps/stays_app/test/architecture/`,
  [ADR 032](docs/DECISIONS.md)):
  - dependency rules: reads every package pubspec and every import against the
    graph above;
  - literal guard: fails with `path:line` on colour, size or user-facing string
    literals in widgets;
  - tenant rule: no flavor name or currency in any `lib/`.

  Each rule is a pure function with fixtures that must fail and fixtures that
  must pass, and each test asserts it scanned something, so it cannot go green
  by scanning nothing.
- **Mutation checks.** For the layered rules (the flag layers and the guard
  scanners) I temporarily broke each layer and confirmed that its own test
  failed, then restored it. A test that stays green when the code it protects
  is removed proves nothing.

## Assumptions

- Browsing requires sign-in, although `GET /listings` is public (the brief
  describes browsing as a signed-in client's view).
- A host sees only the host area and a client never reaches it. A host does not
  browse or save listings.
- The set of tenants is open: a new tenant needs a flavor, not a Dart change.
- Country codes and amenity slugs are translated from ARB for the values in the
  seed data; any other value is shown as it arrived.
- With `hostPanel` off (both tenants have it on) a host sees a "not available"
  screen.
- A booking's total is shown in the booking's own currency, as it was when made.

## API observations

Full table with workarounds and proposals in
[docs/API_OBSERVATIONS.md](docs/API_OBSERVATIONS.md). In short:

- Flags are not enforced server side (`/favourites` answers on riviera), and
  rating fields are still present on a tenant with reviews off.
- Blocking has one request per day, and the API lets a host block an already
  booked day (verified). Availability reports such a day only as `booked`.
- `PATCH` silently ignores unknown fields. Favourites are not paginated.
  Host bookings have no date filter.
- The access token is a plain encoding, so the app never decodes it. A token
  with the wrong tenant header answers 401, like a missing one.
- Trimming of registration input is undocumented, and `maxGuests: 0` is
  accepted, which the edit form refuses.

## What is left out, and why

- **Offline support and caching.** Out of scope in the brief. The runtime config
  is required to start, so the app shows a boot error with Retry when the API
  is unreachable.
- **iOS.** The brief allows one platform.
- **Property type, free-text and amenity filters.** The API supports them. The
  brief asks for city, guests, price and dates (plus sort), so I built those
  well rather than all of them ([ADR 007](docs/DECISIONS.md)).
- **Terms and privacy links.** `termsOfUseUrl` and `privacyPolicyUrl` are parsed
  into `TenantConfig`, because the API sends them, but nothing shows or opens
  them. I removed the links and their dependency rather than ship a half-wired
  feature ([ADR 035](docs/DECISIONS.md)).
- **Creating or cancelling bookings, and image caching.** Not in the brief
  ([ADR 017](docs/DECISIONS.md) for images).

## Decisions

[docs/DECISIONS.md](docs/DECISIONS.md) records the choices that shaped the
code, each with its context, the decision, and what was rejected.

## How I used AI

The brief invites using the tools you normally use, so I worked the way I do day
to day. I used an AI assistant to help draft the architecture and the rules
(package boundaries, the identity and permission split, the tenant isolation
layers, the flag behaviour, the failure model) before any code was written, and I
made the decisions at every open point, recorded in docs/DECISIONS.md. I then used
Claude Code to implement the plan one small step at a time, each step checked by
codegen, analyze and tests. I tested each phase on a physical device, reviewed the
changes and made every commit myself. The instruction files and working notes are
kept out of the repository because they are working notes, not part of the
submission.
