import 'dart:async';
import 'dart:io';

import 'package:custom_ping/custom_ping.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _url = 'https://ping.example.test/ping';
const _tick = Duration(seconds: 3);

/// A fake server: records every request and answers with [handler].
class _Server {
  final List<http.Request> requests = [];
  Future<http.Response> Function(http.Request request) handler =
      (_) async => http.Response('', 200);

  late final MockClient client = MockClient((request) {
    requests.add(request);
    return handler(request);
  });
}

/// PingService builds its http.Client in a field initializer, so it must be
/// constructed inside runWithClient for the fake server to be used.
PingService _service(_Server server) =>
    http.runWithClient(() => PingService(urlTarget: _url), () => server.client);

void main() {
  late _Server server;

  setUp(() => server = _Server());

  group('pingTick', () {
    test('sends a HEAD to urlTarget and is true on 200', () {
      fakeAsync((async) {
        bool? result;
        _service(server).pingTick().then((value) => result = value);
        async.flushMicrotasks();

        expect(result, isTrue);
        expect(server.requests, hasLength(1));
        expect(server.requests.single.method, 'HEAD');
        expect(server.requests.single.url, Uri.parse(_url));
      });
    });

    for (final status in [204, 404, 500]) {
      test('is false on $status', () {
        fakeAsync((async) {
          server.handler = (_) async => http.Response('', status);
          bool? result;
          _service(server).pingTick().then((value) => result = value);
          async.flushMicrotasks();

          expect(result, isFalse);
        });
      });
    }

    test('is false when the request throws', () {
      fakeAsync((async) {
        server.handler = (_) => Future.error(const SocketException('offline'));
        bool? result;
        _service(server).pingTick().then((value) => result = value);
        async.flushMicrotasks();

        expect(result, isFalse);
      });
    });

    test('is false when nothing answers within the timeout', () {
      fakeAsync((async) {
        server.handler = (_) => Completer<http.Response>().future;
        bool? result;
        _service(server).pingTick().then((value) => result = value);

        async.elapse(_tick - const Duration(milliseconds: 1));
        expect(result, isNull);

        async.elapse(const Duration(milliseconds: 1));
        expect(result, isFalse);
      });
    });
  });

  group('getSubscription', () {
    test('emits a result every timeout, the first one after one timeout', () {
      fakeAsync((async) {
        final events = <bool>[];
        final subscription = _service(server).getSubscription(callBack: events.add);

        async.elapse(_tick - const Duration(milliseconds: 1));
        expect(server.requests, isEmpty);
        expect(events, isEmpty);

        async.elapse(const Duration(milliseconds: 1));
        expect(server.requests, hasLength(1));
        expect(events, [true]);

        async.elapse(_tick * 2);
        expect(server.requests, hasLength(3));
        expect(events, [true, true, true]);

        subscription.cancel();
      });
    });

    test('reports false while the server fails', () {
      fakeAsync((async) {
        server.handler = (_) async => http.Response('', 503);
        final events = <bool>[];
        final subscription = _service(server).getSubscription(callBack: events.add);

        async.elapse(_tick * 2);
        expect(events, [false, false]);

        subscription.cancel();
      });
    });

    test('two listeners share one loop: one request per tick, both get every result', () {
      fakeAsync((async) {
        final service = _service(server);
        final first = <bool>[];
        final second = <bool>[];
        final a = service.getSubscription(callBack: first.add);
        final b = service.getSubscription(callBack: second.add);

        async.elapse(_tick * 2);
        expect(server.requests, hasLength(2));
        expect(first, [true, true]);
        expect(second, [true, true]);

        a.cancel();
        b.cancel();
      });
    });

    test('cancelling one of two listeners keeps the loop running for the other', () {
      fakeAsync((async) {
        final service = _service(server);
        final kept = <bool>[];
        final cancelled = <bool>[];
        final keep = service.getSubscription(callBack: kept.add);
        final drop = service.getSubscription(callBack: cancelled.add);

        async.elapse(_tick);
        drop.cancel();
        async.elapse(_tick * 2);

        expect(server.requests, hasLength(3));
        expect(kept, [true, true, true]);
        expect(cancelled, [true]);

        keep.cancel();
      });
    });
  });

  group('after the last listener cancels, the loop stops', () {
    test('no more requests', () {
      fakeAsync((async) {
        final subscription = _service(server).getSubscription(callBack: (_) {});
        async.elapse(_tick);
        expect(server.requests, hasLength(1));

        subscription.cancel();
        async.elapse(_tick * 3);

        expect(server.requests, hasLength(1));
      });
    });

    test('cancelling before the first result sends nothing at all', () {
      fakeAsync((async) {
        final subscription = _service(server).getSubscription(callBack: (_) {});
        async.elapse(const Duration(seconds: 1));

        subscription.cancel();
        async.elapse(_tick * 3);

        expect(server.requests, isEmpty);
      });
    });

    test('a request in flight at the cancel is the last one sent, and its result is not delivered', () {
      fakeAsync((async) {
        final answer = Completer<http.Response>();
        server.handler = (_) => answer.future;
        final events = <bool>[];
        final subscription = _service(server).getSubscription(callBack: events.add);
        async.elapse(_tick);
        expect(server.requests, hasLength(1));

        subscription.cancel();
        answer.complete(http.Response('', 200));
        async.elapse(_tick * 3);

        expect(server.requests, hasLength(1));
        expect(events, isEmpty);
      });
    });

    test('subscribing again runs a single loop', () {
      fakeAsync((async) {
        final service = _service(server);
        final first = service.getSubscription(callBack: (_) {});
        async.elapse(_tick);
        first.cancel();

        final events = <bool>[];
        final second = service.getSubscription(callBack: events.add);
        final before = server.requests.length;
        async.elapse(_tick * 2);

        expect(server.requests.length - before, 2);
        expect(events, [true, true]);

        second.cancel();
      });
    });

    test('subscribing again while the old request is in flight: the old result never reaches the new listener', () {
      fakeAsync((async) {
        final answer = Completer<http.Response>();
        server.handler = (_) => answer.future;
        final service = _service(server);
        final first = service.getSubscription(callBack: (_) {});
        async.elapse(_tick);
        expect(server.requests, hasLength(1));
        first.cancel();

        server.handler = (_) async => http.Response('', 503);
        final events = <bool>[];
        final second = service.getSubscription(callBack: events.add);
        answer.complete(http.Response('', 200));
        async.flushMicrotasks();
        expect(events, isEmpty);

        async.elapse(_tick * 2);
        expect(server.requests, hasLength(3));
        expect(events, [false, false]);

        second.cancel();
      });
    });

    test('opening and closing a screen many times leaves no loop behind', () {
      fakeAsync((async) {
        final service = _service(server);
        for (var i = 0; i < 5; i++) {
          final subscription = service.getSubscription(callBack: (_) {});
          async.elapse(_tick);
          subscription.cancel();
        }
        expect(server.requests, hasLength(5));

        async.elapse(_tick * 10);
        expect(server.requests, hasLength(5));

        final subscription = service.getSubscription(callBack: (_) {});
        async.elapse(_tick * 2);
        expect(server.requests, hasLength(7));

        subscription.cancel();
      });
    });
  });
}
