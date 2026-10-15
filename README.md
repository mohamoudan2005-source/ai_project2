# ai_project

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Examination history search and pagination

The examination history loads the current doctor's complete
`users/{uid}/cases` history in bounded batches. The graph datasets and the
visible list both use this complete decrypted client-side history; list
pagination is local and does not restrict which records can match a search or
outcome filter. Search is case-insensitive and matches name components by
prefix, including components entered in a different order. Emptying the search
restores all records selected by the active outcome filter.

Clinical fields remain in the encrypted `payload`. Searchable name prefixes
are stored as HMAC tokens scoped by the authenticated user's UID, not
plaintext. The `isPneumonia` boolean is stored separately to support
server-side outcome filtering; this exposes the classification value to
Firestore and should be included in the application's data-protection review.
The current `CryptoService` contains a shared test key; replace that key with
the production key-management flow before relying on HMAC index tokens for
confidentiality.

The history screen does not require Firestore search indexes or a metadata
backfill. `FirestoreService.loadCasesPage` remains available for server-side
paginated callers; if another feature uses its combined name/outcome queries,
deploy the composite indexes in `firestore.indexes.json` with:

```sh
firebase deploy --only firestore:indexes
```

For those server-side callers, legacy records need the query metadata backfill
in batches of 100. This decrypts records on the client and writes only query
metadata; it does not rewrite or expose the encrypted clinical payload.
Historical graphs and outcome totals are calculated from the complete
decrypted record set, not from the visible list page.
Records with missing or malformed outcome data are retained and shown as
unclassified rather than counted as Normal. The existing Firestore rules
continue to restrict access to each doctor's own records.
