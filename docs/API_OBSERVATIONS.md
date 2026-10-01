# API observations

The brief says: "If you think an endpoint is missing or wrong, work around it
and tell us at the interview." This file records each one, what the app does
about it, and what I would propose. Rows 5, 11 and 12 are marked (verified):
I confirmed them with curl against the running API. The others come from
reading `openapi.yaml` and `contracts.dart`. Row numbers are cited by
`docs/DECISIONS.md`, so they are stable.

| # | Observation | Workaround in the app | What I would propose |
|---|---|---|---|
| 1 | `GET /listings` is public, but the brief describes browsing as what a signed-in client sees. | The app requires sign-in before browsing. | Decide product-wise whether browsing is public; the API already allows it. |
| 2 | Feature flags are not enforced server side (`/favourites` answers on riviera). | The app never registers a disabled feature, and a test proves no request is made. | Enforce flags on the server too, so a buggy or modified client cannot use a disabled feature. |
| 3 | Blocking a range of days needs one request per day, no batch endpoint. | The calendar blocks or unblocks one day per tap. Both calls are idempotent, so a failed tap is rolled back for that day only and can be repeated safely (ADR 030). | `POST /blocked-days` accepting a list or a range. |
| 4 | Availability reports a day that is both booked and blocked as `booked`, so it cannot show which days the host blocked under a booking. | The host calendar merges availability with `GET /blocked-days`. | Return both reasons, or a `blocked` flag per day. |
| 5 | The API ALLOWS blocking a day that is already booked. (verified with curl on alpine, listing `lst_00003`, confirmed booking 2027-05-26 to 2027-06-01): `POST /blocked-days` for 2027-05-26 answered 201 and the day then appeared in `GET /blocked-days`. Availability still reported it as `booked` (booked wins over blocked, see row 4), and listed 26 to 31 May as booked with 1 June absent, which also confirms check-out is exclusive. `DELETE` answered 204. | The UI never offers it: the calendar treats a booked day as not tappable, and the toggle refuses a booked day before any request is made, so the rule does not depend on the API. | Reject it server side with 409 and a specific messageCode, so a buggy or modified client cannot create a block under a booking (which would silently turn into an unexpected closed day if the booking is later cancelled). |
| 6 | `GET /favourites` is not paginated. | Loaded in one call. | Paginate it like the other lists once lists grow. |
| 7 | `PATCH /host/listings/{id}` silently ignores fields outside the editable set. | The form only sends editable fields, built as a diff. | Reject unknown fields, so client bugs surface instead of vanishing. |
| 8 | `GET /host/listings/{id}/bookings` has no date-range filter. | Paged list with status filter only. | `from`/`to` filters for calendar-style views. |
| 9 | The runtime config is required to start and there is no offline support, so the app cannot open without the API. | Boot screen with retry. | Cache the last good config (out of scope for this task). |
| 10 | The access token is a plain encoding of user id, tenant and a counter. The contract says it is not a secret. | The app never decodes it. Role and tenant come only from the `user` object the API returns. | Use an opaque, signed token. |
| 11 | On riviera (`reviews: false`) listing rows still carry `rating` and `reviewsCount`. (verified) | The model decodes both, and the UI hides them through `canSeeReviews`. | Omit fields a tenant's flags turn off, so a client cannot show them by mistake. |
| 12 | A token sent with another tenant's header answers 401, the same as no token. (verified) | A restored session whose tenant differs from the build's is discarded on the device, before any request. | A distinct code for a wrong-tenant token, to tell it apart from a revoked one. |
| 13 | The docs say registration "trims its inputs" but not whether the password is one of them, or whether the 8-character minimum counts before or after trimming. | The forms trim every field, including the password, before validating and before sending, so the length checked is the length the server sees. | State in the contract which fields are trimmed and where the minimum applies. |
| 14 | The API accepts `maxGuests: 0` on `PATCH /host/listings/{id}` (its only rule on the counts is `minimum: 0`). This is a client-side rule STRICTER than the API, chosen on purpose: the edit form requires at least 1 guest, because a listing that sleeps nobody cannot be booked, and the guest filter already assumes every listing sleeps at least one. | The form refuses 0 guests with its own message. Bedrooms, beds and bathrooms may be 0 (a studio has no bedroom), as the API allows. | Set `minimum: 1` on `maxGuests` in the API, so the rule lives in one place instead of only in this client. |
