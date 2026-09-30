# API observations

The brief says: "If you think an endpoint is missing or wrong, work around it
and tell us at the interview." This file records each one, what the app does
about it, and what I would propose. Items marked (verify) are confirmed against
the running API during the build.

| # | Observation | Workaround in the app | What I would propose |
|---|---|---|---|
| 1 | `GET /listings` is public, but the brief describes browsing as what a signed-in client sees. | The app requires sign-in before browsing. | Decide product-wise whether browsing is public; the API already allows it. |
| 2 | Feature flags are not enforced server side (`/favourites` answers on riviera). | The app never registers a disabled feature, and a test proves no request is made. | Enforce flags on the server too, so a buggy or modified client cannot use a disabled feature. |
| 3 | Blocking a range of days needs one request per day, no batch endpoint. | Requests are idempotent, so the app retries safely and reports partial failure. | `POST /blocked-days` accepting a list or a range. |
| 4 | Availability reports a day that is both booked and blocked as `booked`, so it cannot show which days the host blocked under a booking. | The host calendar merges availability with `GET /blocked-days`. | Return both reasons, or a `blocked` flag per day. |
| 5 | Whether a booked day can be blocked. (verify) | The UI does not offer blocking on booked days. | Reject it server side with a specific messageCode. |
| 6 | `GET /favourites` is not paginated. | Loaded in one call. | Paginate it like the other lists once lists grow. |
| 7 | `PATCH /host/listings/{id}` silently ignores fields outside the editable set. | The form only sends editable fields, built as a diff. | Reject unknown fields, so client bugs surface instead of vanishing. |
| 8 | `GET /host/listings/{id}/bookings` has no date-range filter. | Paged list with status filter only. | `from`/`to` filters for calendar-style views. |
| 9 | The runtime config is required to start and there is no offline support, so the app cannot open without the API. | Boot screen with retry. | Cache the last good config (out of scope for this task). |
| 10 | The access token is a plain encoding of user id, tenant and a counter. The contract says it is not a secret. | The app never decodes it. Role and tenant come only from the `user` object the API returns. | Use an opaque, signed token. |
| 11 | On riviera (`reviews: false`) listing rows still carry `rating` and `reviewsCount`. (verified) | The model decodes both, and the UI hides them through `canSeeReviews`. | Omit fields a tenant's flags turn off, so a client cannot show them by mistake. |
| 12 | A token sent with another tenant's header answers 401, the same as no token. (verified) | A restored session whose tenant differs from the build's is discarded on the device, before any request. | A distinct code for a wrong-tenant token, to tell it apart from a revoked one. |
| 13 | The docs say registration "trims its inputs" but not whether the password is one of them, or whether the 8-character minimum counts before or after trimming. | The forms trim every field, including the password, before validating and before sending, so the length checked is the length the server sees. | State in the contract which fields are trimmed and where the minimum applies. |
