import 'dart:async';

import 'package:choloto/flutter_flow/request_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FutureRequestManager', () {
    test('deduplicates identical in-flight and cached requests', () async {
      final manager = FutureRequestManager<int>();
      var requestCount = 0;
      final completer = Completer<int>();

      Future<int> request() {
        requestCount += 1;
        return completer.future;
      }

      final first = manager.performRequest(
        uniqueQueryKey: 'latest-results',
        requestFn: request,
      );
      final second = manager.performRequest(
        uniqueQueryKey: 'latest-results',
        requestFn: request,
      );

      expect(identical(first, second), isTrue);
      expect(requestCount, 1);

      completer.complete(42);
      expect(await first, 42);
      expect(await second, 42);
    });

    test('refreshes a cached request only when explicitly requested', () async {
      final manager = FutureRequestManager<int>();
      var requestCount = 0;

      Future<int> request() async => ++requestCount;

      expect(
        await manager.performRequest(
          uniqueQueryKey: 'latest-results',
          requestFn: request,
        ),
        1,
      );
      expect(
        await manager.performRequest(
          uniqueQueryKey: 'latest-results',
          requestFn: request,
        ),
        1,
      );
      expect(
        await manager.performRequest(
          uniqueQueryKey: 'latest-results',
          overrideCache: true,
          requestFn: request,
        ),
        2,
      );
      expect(requestCount, 2);
    });

    test('evicts the oldest entry when the cache limit is reached', () async {
      final manager = FutureRequestManager<int>(2);
      var requestCount = 0;

      Future<int> request() async => ++requestCount;

      await manager.performRequest(uniqueQueryKey: 'a', requestFn: request);
      await manager.performRequest(uniqueQueryKey: 'b', requestFn: request);
      await manager.performRequest(uniqueQueryKey: 'c', requestFn: request);
      await manager.performRequest(uniqueQueryKey: 'a', requestFn: request);

      expect(requestCount, 4);
    });
  });
}
