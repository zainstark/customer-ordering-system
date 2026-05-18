import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/widgets/app_network_image.dart';

// class _TestHttpOverrides extends HttpOverrides {
//   _TestHttpOverrides(this.onOpenUrl);

//   final Future<HttpClientRequest> Function(Uri url) onOpenUrl;

//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return _FakeHttpClient(onOpenUrl);
//   }
// }

class _FakeHttpClient implements HttpClient {
  _FakeHttpClient(this.onOpenUrl);

  final Future<HttpClientRequest> Function(Uri url) onOpenUrl;

  @override
  Future<HttpClientRequest> getUrl(Uri url) => onOpenUrl(url);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) => onOpenUrl(url);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  _FakeHttpClientRequest(this.onClose);

  final Future<HttpClientResponse> Function() onClose;

  @override
  Future<HttpClientResponse> close() => onClose();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Future<void> pumpImage(WidgetTester tester, {IconData icon = Icons.image}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppNetworkImage(
            imageUrl: 'https://example.com/test-image.png',
            placeholderIcon: icon,
          ),
        ),
      ),
    );
  }

  testWidgets('shows placeholder icon while image is loading', (tester) async {
    final pendingResponse = Completer<HttpClientResponse>();

    await HttpOverrides.runZoned(
      () async {
        await pumpImage(tester, icon: Icons.hourglass_empty);
        await tester.pump();

        expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
      },
      createHttpClient: (_) => _FakeHttpClient(
        (url) async => _FakeHttpClientRequest(() => pendingResponse.future),
      ),
    );
  });

  testWidgets('shows fallback icon when image request fails', (tester) async {
    await HttpOverrides.runZoned(
      () async {
        await pumpImage(tester, icon: Icons.error_outline);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      },
      createHttpClient: (_) => _FakeHttpClient(
        (url) async => _FakeHttpClientRequest(
          () => Future<HttpClientResponse>.error(
            const SocketException('network unavailable'),
          ),
        ),
      ),
    );
  });
}
