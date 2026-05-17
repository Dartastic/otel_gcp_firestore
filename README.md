# otel_gcp_firestore

Dartastic OpenTelemetry bridge for GCP Firestore (managed NoSQL document DB).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_gcp_firestore/otel_gcp_firestore.dart';

await tracedGcpFirestore<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return GcpFirestoreCallResult(value: r, result: GcpFirestoreResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutGcpFirestoreInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
