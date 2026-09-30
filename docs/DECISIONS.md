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

## 011. Android flavors and launcher icons

**Context:** The brief wants each tenant as its own flavor with its own name,
icon and bundle id, built from the same code.

**Decision:**

- Two Gradle product flavors, `alpine` and `riviera`, in one `tenant`
  dimension. Each has an `applicationIdSuffix` (a separate install with a
  separate sandbox) and a `resValue` launcher label.
- Icons are generated once with `flutter_launcher_icons` (one config file per
  flavor, output in `src/<flavor>/res`) and the PNGs are committed. The
  generated files are legacy launcher icons: the sources are opaque squares,
  so there is no separate foreground layer for an adaptive icon.
- The Flutter default icon is removed from `src/main`, so a build cannot ship
  without a flavor icon.
- Cleartext HTTP is allowed by a `src/debug` network security config, limited
  to `127.0.0.1`, `localhost` and `10.0.2.2`. Release builds have no config
  and the platform default blocks cleartext. As a result, profile builds
  cannot reach the local HTTP API either, which is intended.

**Rejected:**

- `flutter_launcher_icons` as a dev dependency: every current release needs
  `cli_util ^0.4`, Melos 8 needs `>=0.5`, so only a 2021 release resolves and
  it has no flavor support. It runs as a globally activated tool instead
  (`dart pub global activate flutter_launcher_icons`), which is enough for a
  one-off generation step.
- `usesCleartextTraffic="true"` in the debug manifest: it opens every host,
  not just the local ones.

## 012. Failure and networking foundation built before the first API call

**Context:** The first API call (the tenant runtime config) has to follow the
repository convention `TaskEither<AppFailure, T>`, and it needs the `tenant`
header even though it is public.

**Decision:** `AppFailure`, `ApiErrorMapper`, the `apiCall` helper, the single
Dio provider and `TenantInterceptor` were built first and tested on their own.
The config repository then sits on top of them without special cases.

**Rejected:** a temporary stub failure type and an explicit header on the one
call, to be replaced later. It would have meant rewriting the first
repository, and the first call would not have followed the conventions the
rest of the app uses.

## 013. Session restore fails closed; the network hooks use a bridge

**Context:** On launch the stored session is verified with `GET /auth/me`. The
API can also reject a stored token (it is revoked on logout), and the Dio's
interceptor needs the current token while the session controller itself needs
the Dio.

**Decision:**

- A stored session is trusted only after `/auth/me` confirms it. A 401, or a
  user of another tenant, discards it and the app starts signed out.
- If the check cannot be made (network drop, timeout, 5xx), the session state
  becomes an error and the stored session is left untouched. The app shows the
  same translated error and Retry as the config load; Retry re-runs the
  restore. The app never shows a signed-in screen on an unverified token.
- The interceptor's token getter and "session rejected" callback read a small
  `SessionBridge` object that the controller writes. They do not read the
  controller.

**Rejected:**

- Trusting the stored session when the check fails. It avoids one error state,
  but a revoked token would be discovered only on the first real call, after a
  signed-in home has already been shown, and the role would come from disk
  unchecked. Booting already needs the network for the runtime config, so the
  extra wait is rare and short.
- Letting the hooks `ref.read` the controller. Riverpod's debug assertion
  rejects a provider reading one of its own transitive dependents (the
  controller depends on the repository, the Dio and the hooks), even lazily
  inside a closure. The bridge keeps the provider graph acyclic.

## 014. A feature module declares its own guard

**Context:** The router must keep a client out of host routes on the device,
before any screen builds. Something has to say which routes belong to which
side of the app.

**Decision:** Each `FeatureModule` states its `area` (guest, host, or none for
sign-in and registration), its `basePath`, its routes, an optional tab, and an
optional extra requirement. `isAllowedFor(capabilities)` is the guard and
`owns(location)` says which module a path belongs to, so the router's redirect
is generic and no path such as `/host` appears in the shell. The constructor
asserts that every top-level route lives under the base path, and
`validateModules` rejects duplicate ids and overlapping base paths at startup.

**Rejected:** Keeping a path-prefix table in the shell. The type is smaller,
but the rule lives in a different package from the routes it protects, so a
new host route added outside the prefix would silently be reachable by a
client, and the two places would have to be kept in sync by hand.

## 015. The router: modules from flags, one shell per area

**Context:** The app has guest and host sides, tabs, and features that a tenant
can switch off. Access must be decided on the device before a screen builds.

**Decision:**

- The module list is built from the tenant's flags only (`modulesFor`). One
  `GoRouter` is created once, when the config is loaded and the session is
  resolved. Its `redirect` calls the pure `resolveRedirect(modules,
  capabilities, location)`, and `refreshListenable` fires when the
  capabilities change, so signing in or out moves the user without any screen
  navigating.
- The router is held back until the stored session has been verified. While it
  is being checked the boot spinner shows, and if it cannot be verified the
  boot error with Retry shows (ADR 013). A signed-in user therefore never sees
  the sign-in screen flash.
- Tab modules are grouped by area, and each area gets its own
  `StatefulShellRoute` with a branch per tab. The bottom bar appears only when
  the area has two or more tabs, so a guest on a tenant with favourites off has
  one tab and no bar.
- A host on a tenant with the host panel off is sent to a shell-owned "host
  area not available" module that is registered instead of the host area. It
  belongs to the host side, so it never falls through to browsing.
- Until the real screens exist, `/browse` and `/host` are placeholders that
  show who is signed in, and they keep the final paths.

**Rejected:**

- One shell holding every tab and hiding the ones a user may not use: the bar
  would need index bookkeeping, and a hidden branch still exists.
- Building the router before the session is known and redirecting once it is:
  it shows the sign-in screen to a signed-in user for a moment.

## 016. Kotlin incremental compilation is off

**Context:** On this Windows machine the Android build failed in
`:url_launcher_android:compileDebugKotlin` with "Could not close incremental
caches" once that plugin was added. The pub cache with the plugin's sources is
on a different drive from the project.

**Decision:** `kotlin.incremental=false` in `android/gradle.properties`. The app
has almost no Kotlin of its own, so a full compile of the plugins costs
nothing, and the build is reliable. Switching the Kotlin compiler to run in
the Gradle process did not help.

## 017. Listing images: `Image.network`, no image-cache package

**Context:** Every card has a cover and the detail screen has a pager, served
from the internet. The brief excludes offline support.

**Decision:** Plain `Image.network` in a fixed-aspect-ratio box, with a surface
while loading and an icon if it fails (or if a listing has no image). Flutter's
in-memory image cache is enough for scrolling a list.

**Rejected:** `cached_network_image`. It adds a disk cache and one more
dependency for a benefit the brief does not ask for.

## 018. Guest sign-out is an app-bar action

**Context:** The temporary home screen held the only sign-out button. Once it is
replaced, a guest still needs a way out.

**Decision:** A sign-out icon button (with a tooltip) in the browse app bar. A
guest on a tenant with favourites off has one tab, so there is no bottom bar to
host an "Account" tab either way.

**Rejected:** An account tab. It adds a module and a tab (and a bottom bar on
tenants that otherwise have none) for one button.

## 019. Browse list state: a family keyed by the filter, applied from a draft

**Context:** The list must reload when the filter changes, must not mix pages of
two filters, and must survive opening a listing.

**Decision:**
- `BrowseListings` is an auto-dispose notifier family keyed by `ListingFilter`
  (a freezed value, so equal filters are the same key). A new filter is a new
  list, and a slow answer for the old one can never be appended to it.
- `ListingFilterController` holds the applied filter. The filter sheet edits a
  local draft and writes it once on "Show results", so a slider does not reload
  the list on every tick.
- A listing opens on top of the browse screen, so the screen stays mounted and
  keeps listening: the filter, the pages and the scroll position survive. A test
  proves it, including that no request is repeated.
- A load-more that started before a refresh is dropped (a generation counter),
  and the screen asks for the next page after every rebuild too, so a first page
  too short to scroll still fills the screen.

**Rejected:** Writing every change to the filter controller (reloads while the
user is still choosing), and a `keepAlive` list (it would keep the last list
across sign-out and tenant-level changes for no reason).

## 020. One `noAutomaticRetry` for providers that load from the API

**Context:** Riverpod 3 retries a failed provider with a growing delay, which
keeps a screen on its spinner instead of showing the error. Core had two private
copies of the same function.

**Decision:** One public `noAutomaticRetry` in `core`, used by the tenant
config, the session, and every notifier that loads from the API. Failing once
and showing our own message with a Retry button is the behaviour the brief's
error handling asks for.

## 021. Filter sheet: city chips, a stepped price scale, draft applied once

**Context:** The sheet is built from `/listings/facets`. Both tenants have 8
cities with short names, and prices that run 51 to 694 CHF and 50 to 765 EUR.

**Decision:**
- Cities are choice chips ("Any city" plus one per city). Eight short names wrap
  onto about three lines, every option is visible without a tap, and the sheet
  scrolls. With dozens of cities a dropdown or a searchable list would replace
  them; the facets would not change.
- The price slider works on positions, not on prices. `PriceScale` makes the
  two exact facet bounds the end positions and every whole multiple of a step
  (10 for wide ranges, finer for narrow ones) the positions between them, so a
  price like 137.42 can never appear and the cheapest and dearest listing are
  still reachable. An end resting on its bound sends nothing, so moving one end
  sends one bound.
- The sheet edits a draft and applies it once ("Show results"); closing it any
  other way discards the draft.
- One guest is no filter (every listing sleeps at least one). Dates are sent as
  `checkIn` and the picked check-out day, and a zero-night pick is refused.

**Rejected:** A plain `RangeSlider` over the bounds with a division count
(fractional values, or the bounds not reachable), and a segmented button for
sort (four options do not fit in German).

## 022. Listing screen: fetched by id, nested under the list, country by name

**Context:** A listing opens from a card, and can also be opened from a link. The
API sends the country as an ISO code.

**Decision:**
- The screen always fetches the listing by id, although the list already had the
  data. A deep link or a restarted app has no card to take it from, and one code
  path keeps the data fresh. The cost is one request and a brief spinner.
- The route is nested under the list (`/browse/listing/:id`, inside the browse
  branch). It opens on top of the list, so the list keeps its filter, pages and
  scroll position, and the bottom bar stays where a tenant has one. Back goes to
  the previous screen, or to the list when there is none (a deep link).
- Country codes get names the same way amenities get labels: ARB entries for the
  codes the catalogue has today (AT, CH, FR, IT, MC, read from the seed data),
  and any other code is shown as it arrived. The set is open.

**Rejected:** Passing the listing from the card (a second code path, and nothing
to pass for a link), and a full-screen route above the tab bar (a root
navigator route just to hide a bar).

## 023. Availability calendar: a generic widget, one month per request, an injected clock

**Context:** A guest needs to see which days of a listing are taken, and whether
a stay they searched for is free. Nothing in the app may depend on the day the
tests happen to run.

**Decision:**
- `MonthCalendar` lives in `design_system` and knows nothing about bookings. The
  caller says how each day looks (plain, muted, or marked, plus an optional
  outline) and what a screen reader says about it. It holds no copy: names come
  from the platform, words are passed in.
- Colour is never the only cue. A taken day is filled AND its number is struck
  through, and the legend draws its samples with the same widget, so it shows the
  same strike-through. The searched stay is an outline, which sits on top of any
  style.
- One month per request, a family keyed by listing and month (far below the API's
  366 nights). The current month asks from today, not from the 1st, so the request
  does not depend on how the API treats a past date; past days are muted and never
  shown as taken. Ranges are half-open, as everywhere.
- The calendar opens on the month of the searched check-in, clamped to the months
  it can show (this month to twelve months ahead). Booked and blocked days look the
  same to a guest.
- "Today" comes from `clockProvider`, which gives a FUNCTION, not a date. A
  `keepAlive` provider holding a `LocalDate` would keep yesterday after midnight;
  a function reads the device date at each call, and tests override it with a
  fixed date. Nothing else in `lib/` reads the real date.

**Rejected:** A second "blocked" style in this phase (the host calendar adds it
in Phase 7, when it is needed), caching months across navigation (one small
request is cheaper than the bookkeeping), and a provider holding a fixed
`LocalDate`.

## 024. Saved listings: one keepAlive list per signed-in user, updated before the request

**Context:** The save buttons on every card, the save button on the listing page
and the Saved screen all show the same fact: is this listing saved? They must
agree, and a tap must feel instant even on a slow connection.

**Decision:**
- One notifier, `Favourites`, holds the list and everything reads it. It is
  `keepAlive` (session lifetime, not app lifetime): it watches the signed-in
  user's id, so signing out, or in as someone else, rebuilds it from scratch and
  one account never sees another's list. Signed out, it is empty and asks the API
  nothing.
- A toggle changes the list first and sends the request after. On failure only
  that listing is put back (the same position for an unsave), never a copy of the
  whole old list, so a slow failure cannot undo a toggle of another listing made
  meanwhile. The failure is returned to the button, which shows our own message.
- A second tap on a listing whose request is still out is ignored, so two
  requests for one listing can never cross. Nothing happens until the list has
  loaded.
- The API treats "add twice" and "remove what is not there" as success, so a
  repeat after a rollback is safe.
- Nothing creates the notifier unless something reads it. On a tenant with
  favourites off, and for a host, nothing does (Phase 6.2 and 6.4 prove it).

**Rejected:** An auto-dispose list (it would be dropped and fetched again
whenever no card is on screen, and a toggle still in flight could lose its
rollback), a per-card provider family (each heart would be its own request and
could disagree with the Saved screen), and restoring a snapshot of the whole list
on failure (undoes unrelated changes).

## 025. The Saved screen is told where a listing opens

**Context:** Tapping a saved listing must open the same listing screen browse
uses. That screen lives in `feature_browse`, and a feature never depends on
another feature.

**Decision:** `favouritesModule` is a function that takes `listingLocation`, a
`String Function(String id)`. The shell, the only place that knows both features,
passes `BrowsePaths.listing`. The Saved screen calls `context.go` with it, which
moves to the Browse tab with the listing open on top of the list, so Back returns
to the list. There is still one listing screen.
The module also declares `requires: canSaveListings`, so the router turns away
anyone without that capability before the screen builds (defence in depth on top
of the shell not registering the module at all when the flag is off).

**Rejected:** A second listing screen inside favourites (two screens to keep in
step), favourites importing `BrowsePaths` (breaks the dependency rule the
architecture test will enforce), and a second global slot provider for the
location (one more hidden dependency for something a single module needs, where a
constructor argument is visible at the one place it is wired).

## 026. The favourites flag is applied in the shell, twice, and each layer is tested

**Context:** The brief: "hiding saved listings means a route, a tab and the
provider behind them all have to go. Show us a flag that actually turns something
off." The API does not enforce the flag, so calling `/favourites` on a tenant that
has it off is an app bug.

**Decision:**
- **Existence is decided in the shell, from the flag only.** `modulesFor` adds
  `favouritesModule(...)` only `if (flags.favourites)`, so with it off there is no
  route, no tab and no Saved screen. `shellSlotOverrides` fills the card's save
  slot with the button only when the flag is on; otherwise the slot stays empty.
  It is an ordinary root-scope provider override installed in `bootstrap`, next
  to the tenant environment, with no nested scope.
- **Use is decided by the button, from the role.** `SaveButton` returns nothing
  unless `canSaveListings` (client AND flag), and checks it BEFORE reading the
  favourites provider. A host shares an alpine build where the slot is filled, and
  never sees the button or triggers a request.
- **Two independent layers, on purpose.** Filling the slot only when the flag is
  on, and the button checking the capability, each keep the save control and the
  requests away from a flag-off tenant. Each has its own test that FAILS if only
  that layer is removed (checked by temporarily breaking each one): the slot is
  asserted empty on riviera, the route and module are asserted absent, and the
  button is asserted to draw nothing for a host, a signed-out user and a flag-off
  client.
- **The proof runs the real shell.** `favourites_flag_test.dart` runs `StaysApp`
  with the real `modulesFor`, the real slot override and the real favourites
  repository, over a Dio adapter that records every request. A positive control
  on the flag-on side proves the recorder would have seen a `/favourites` call.

**Rejected:** Hiding the heart and the tab with `if (flag)` inside each widget
(the route and the provider would still exist), relying on the API to refuse
(it does not enforce flags), and mocking the favourites repository in the shell
test (a mock cannot prove the real code made no request).

## 027. The host area is one tab; listing actions are nested routes

**Context:** Every host endpoint for bookings and blocked days is keyed by a
listing (`/host/listings/{id}/...`). There is no "all my bookings" endpoint. The
brief asks for my listings, editing, blocking days and viewing bookings.

**Decision:** One tab, "My listings". Each listing card offers Edit, Calendar and
Bookings, which push `/host/listings/:id/edit`, `/calendar` and `/bookings`. With
a single tab the bottom bar hides itself, and Sign out is an app-bar action, as
for guests (ADR 018).

**Rejected:** Three tabs (Listings, Calendar, Bookings). Calendar and Bookings
would each need a listing picker and a "selected listing" provider shared
across tabs, and an empty state for a host with no listings. That is extra state
to keep in sync, and it works against the shape of the API.

## 028. One paged list widget in design_system; notifiers stay explicit

**Context:** Browse, host listings and host bookings are all cursor-paged lists
with infinite scroll, a spinner footer and an error footer with Retry. The scroll
trigger and the footer were about 50 lines inside the browse screen.

**Decision:** `PagedListView<T>` in `design_system` owns the scroll trigger and
the footer. It takes the `PagedState`, an item builder, an `onLoadMore` callback
and all strings as parameters, so it holds no copy and knows nothing about
listings. The caller still owns the `RefreshIndicator`, because only it knows
what a refresh reloads. Each notifier keeps its own short `loadMore` (a
generation guard, then one repository call that differs per feature). Browse was
moved onto the widget with no behaviour change; its existing tests are the proof.

**Rejected:** Copying the scroll and footer code into each host screen (three
copies of the same logic, and a bug fix in three places). A shared mixin for the
notifiers: Riverpod's generated notifiers extend a generated `_$X` class, so a
mixin needs awkward generics to reach `state` and `ref`, for about 20 lines of
code that differ in the repository call anyway.

## 029. Editing a listing: a diff, not the whole listing

**Context:** `PATCH /host/listings/{id}` is partial and all or nothing. It takes
types literally (`"250"` is refused, not coerced), trims strings itself, ignores
fields outside the editable set, and answers 404 for a listing the host does not
own. A price edit does not restate the total on bookings already made.

**Decision:**
- **The request is a diff.** `buildListingPatch(original, draft)` returns a
  `ListingPatch` holding only the fields that differ. A field that did not
  change is null and absent from the JSON (`includeIfNull: false`). An empty
  patch means no request at all, and Save stays off until something changed.
- **Text is trimmed before it is compared and before it is sent.** A change of
  spaces only is therefore not a change.
- **Numbers stay numbers.** The form turns text into a `ListingDraft` of real
  values first (`parseAmount`, `parseCount`), so the patch holds `num` and `int`
  and encodes JSON numbers. The parsers accept a point or a comma, and refuse
  signs, exponents and letters. Numbers compare as numbers, so 249 and 249.0 are
  one price.
- **Amenities compare as a set**, in any order. The draft starts from the
  listing's own list, so a slug the app has no label for is shown as a chip and
  survives an edit. An empty list is a value (it clears them), which is why
  "unchanged" is null and never an empty collection.
- **One banner for a failed save.** The API is all or nothing, so there is no
  per-field server error to show. The banner uses our own copy for the
  `messageCode`, the typed values are kept, and saving again is allowed.
- **Success updates the list in place** (`HostListings.replace`), so the list
  shows the change with no refetch.
- **The form reads the listing from the host's list**, which is still open under
  it. A listing that is not there is reported as not found rather than fetched.
- **The choices.** Property types are the API's closed set of seven, labelled in
  ARB. Amenity chips are the slugs `amenityLabel` can translate, plus the
  listing's own. Both are lists of what we can label, not of what can exist.
- **Save is pinned under the form**, always in reach on a long form.

**Rejected:** Sending the whole listing (it would overwrite fields the host did
not touch and risks the read-only ones), building the body from a `Map` in the
form (nothing to test, and a string price could slip through), offering only the
amenities found in `/listings/facets` (a host could not add one nobody has yet,
and the form would need a second request to open), and fetching the listing by id
on the edit screen (the API has no host-side single-listing endpoint, and the
public one is another tenant-checked call for data we already hold).

## 030. The host calendar: booked days are fixed, blocks are optimistic, rules live in the notifier

**Context:** A host closes single days on a listing's calendar. The API has one
call per day, and I verified with curl (API_OBSERVATIONS row 5) that it LETS a
host block a day that is already booked. It reports such a day as `booked`, so
availability alone cannot show the host's own blocks. The `blockedDays` flag can
turn blocking off while the rest of the host area stays.

**Decision:**
- **Two sources, two providers.** `bookedDays(listingId, month)` is one small
  availability request per month (every reason except `blocked`, including a
  reason we do not know). `HostBlockedDays(listingId)` holds the listing's whole
  set of blocked days, loaded once, because that endpoint is not paginated and
  lists everything. Moving between months only reads from it.
- **Booked wins.** A day that is booked is drawn as booked and is not tappable,
  even if the host also blocked it, as the API reports it. The app never offers
  to block a booked day, and the toggle refuses it before any request, so the
  rule does not depend on the API.
- **The rules live in the notifier, not the screen.** `toggle(date)` does
  nothing, and sends nothing, when blocking is off, the day is before today, the
  day is booked or its month has not loaded (we do not know), the days are not
  loaded, or a request for that day is still out. Today itself can be blocked.
  The screen also makes those days untappable, so the rule is enforced twice and
  each layer is tested alone.
- **Optimistic, undone per day.** A tap changes the day at once and sends the
  request. If it fails, only that day goes back and the failure is returned for
  a message in our own words. A snapshot of the whole set is never restored, so a
  day changed meanwhile stays changed. Both API calls are idempotent, so trying
  again after a rollback is safe.
- **Read only when the flag is off.** The calendar still loads and shows booked
  and blocked days, but has no tap callback and says why. The flag removes the
  ability to change, not the ability to see.
- **How it looks.** Booked: filled cell and struck number (as the guest's taken
  days). Blocked: struck number on a plain cell. Colour is never the only cue,
  the legend names all three, and every day has a screen reader label that also
  says what a tap will do.
- **`MonthCalendar` stays generic.** It gained an optional `onDayTap`, a
  `tappable` flag per day and one style named by its look (`struck`). It still
  does not know what a booking is. The month helpers moved from `feature_browse`
  to `core`, because two features now need them and features cannot depend on
  each other.
- **Range.** From the current month to a year ahead, like the guest's calendar.

**Consequence, stated honestly:** a day the host blocked and that was later
booked shows as booked and cannot be unblocked in the app until the booking is
cancelled, because the booked rule wins. It is harmless (the day is occupied
anyway) and it comes back as blocked if the booking is cancelled.

**Rejected:** A notifier per listing AND month (navigating away would lose or
refetch the blocks and duplicate the state), relying on the API to refuse a
booked day (verified: it does not), restoring a saved copy of the set on
failure, a confirmation dialog on every tap (blocking is cheap and reversible),
and telling blocked from booked by colour alone.

## 031. The bookings screen: a family per status, wrapped chips, the row's own currency

**Context:** A host reads the bookings on one listing: newest check-in first,
paged, optionally for one status. The API has a single status filter, no date
filter (API_OBSERVATIONS row 8), and keeps each booking's total as it was when
it was made.

**Decision:**
- **One notifier per listing AND status** (`ListingBookings`, a family keyed by
  both, null meaning all), the same shape as browse's per-filter family
  (ADR 019). Changing the chip starts a fresh list, and a slow answer for the old
  filter cannot land in the new one. It has the same generation guard and
  pre-`await` loading flag as the other paged notifiers.
- **The chosen status is the screen's own state.** Nothing else reads it and it
  starts at "all" each time the screen opens, so it is not a provider.
- **Wrapped chips, all visible.** "All" plus four statuses wrap onto another line
  on a narrow screen or in German instead of hiding off the edge, for the same
  reason as the city chips (ADR 021). A filter that matches nothing keeps the
  chips and offers "Show all bookings", so the host is never stuck.
- **Status is an icon AND a word.** Each of the five statuses (including
  `unknown`) has its own icon and label, so colour is never the only cue. A
  status the API adds later decodes to `unknown` and shows a generic label, never
  a crash. `unknown` is a decoding fallback only: it is not a filter chip and the
  repository refuses to send it.
- **The total is formatted with the booking's own currency**, never the tenant's,
  and is shown as it was at booking time. A later price edit does not restate it.
- **The whole booking is one item to a screen reader** (merged semantics), and the
  stay is written as dates, nights and guests with plural-aware copy in both
  languages.
- **Read only.** Nothing creates, changes or cancels a booking in this app, so the
  screen has no actions.

**Rejected:** One shared provider with the status as mutable state (a slow
response for the old status could overwrite the new list), a horizontally
scrolling chip row (options off-screen on a phone and in German), filtering the
statuses on the device (it would page through everything to find a few rows, and
the API already filters), and formatting totals in the tenant's currency (the row
says what it was booked in).

## 032. The brief's rules are tests, not promises

**Context:** The brief sets structural rules: a feature never depends on another
feature, no colour or size literal and no user-facing string in a widget, and no
tenant name or currency in code. A rule that lives only in a document stops being
true the first time someone is in a hurry.

**Decision:** Two tests in `apps/stays_app/test/architecture/`, run with the rest
of the suite and in CI.
- **Dependency rules.** Every workspace pubspec is read (runtime and dev
  dependencies) and checked against the graph of ADR 001. Imports are scanned
  too, because pub workspaces share one package config and the compiler accepts
  an import of a sibling that was never declared. Importing another package's
  `lib/src/` fails as well. A package with no rule fails, so new packages must be
  classified.
- **Literal guard.** It scans `stays_app`, `listings`, every `feature_*` and the
  `design_system` widgets (decision D), skipping only `design_system`'s
  `src/tokens/` and `src/theme/`, where the values are allowed to live. It fails
  with `path:line  rule  snippet` on `Colors.`, `Color(...)`, `0x` and `'#hex'`
  colours, a number inside `EdgeInsets`, `SizedBox`, `BorderRadius` or `Radius`
  or given as a size argument, and a string literal in `Text(` or a label
  argument.
- **Tenant rule.** In the `lib/` of every package, no flavor name and no
  hard-coded currency code or symbol. The flavor names are read from the Gradle
  `productFlavors` block, so the test names no tenant itself.
- **The rules are pure functions over text, each with fixtures that must fail
  and fixtures that must pass.** A small scanner first blanks comments (and
  string contents for the code rules), keeping every offset, so `Colors.` in a
  comment or a URL in a string cannot cause a false result. Each test also
  asserts it found what it expected to scan, so it cannot go green by scanning
  nothing.

**Known limits:** It is a text scan, not the Dart analyzer. It does not see a
number hidden behind a local variable, or a string built outside a `Text`. The
rest is covered by review and by the l10n setup (the message strings come from
the generated class).

**Rejected:** A custom analyzer or lint plugin. It gives editor squiggles, but it
is another package and another API, and plugin setup is already delicate on this
toolchain (ADR 008). A plain test is readable in an interview and runs anywhere.
