// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_gcp_firestore/otel_gcp_firestore.dart';
import 'package:test/test.dart';

void main() {
  group('otel_gcp_firestore', () {
    test('suppression toggles in zone', () async {
      expect(gcpFirestoreInstrumentationSuppressed(), isFalse);
      await runWithoutGcpFirestoreInstrumentationAsync(() async {
        expect(gcpFirestoreInstrumentationSuppressed(), isTrue);
      });
      expect(gcpFirestoreInstrumentationSuppressed(), isFalse);
    });

    test('GcpFirestoreResult fields default null', () {
      const r = GcpFirestoreResult();
      expect(r.statusCode, isNull);
    });
  });
}
