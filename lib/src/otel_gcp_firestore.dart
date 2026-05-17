// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_gcp_firestore_suppression.dart';

class GcpFirestoreResult {
  const GcpFirestoreResult({
    this.project,
    this.database,
    this.collection,
    this.documentId,
    this.documentCount,
    this.scannedCount,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? project;
  final String? database;
  final String? collection;
  final String? documentId;
  final int? documentCount;
  final int? scannedCount;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class GcpFirestoreCallResult<T> {
  const GcpFirestoreCallResult({required this.value, this.result});
  final T value;
  final GcpFirestoreResult? result;
}

Future<T> tracedGcpFirestore<T>({
  required String operation,
  required Future<GcpFirestoreCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (gcpFirestoreInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_gcp_firestore');
  final span = t.startSpan('firestore $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('db.system.name', 'firestore');
    span.setStringAttribute('gcp.service', 'firestore');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.project != null) {
        span.setStringAttribute('gcp.project.id', res.project!);
      }
      if (res.database != null) {
        span.setStringAttribute('db.namespace', res.database!);
      }
      if (res.collection != null) {
        span.setStringAttribute('db.collection.name', res.collection!);
      }
      if (res.documentId != null) {
        span.setStringAttribute('gcp.firestore.document.id', res.documentId!);
      }
      if (res.documentCount != null) {
        span.setIntAttribute(
          'gcp.firestore.document.count',
          res.documentCount!,
        );
      }
      if (res.scannedCount != null) {
        span.setIntAttribute('gcp.firestore.scanned_count', res.scannedCount!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('firestore.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'firestore.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
