import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:jisho_anki/services/preloaded_image.dart';
import 'package:jisho_anki/services/wikimedia_image_service.dart';

class _RecordingClient extends http.BaseClient {
  _RecordingClient(this.responseBody);

  final String responseBody;
  final List<Uri> requestedUrls = [];
  final List<Map<String, String>> requestHeaders = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requestedUrls.add(request.url);
    requestHeaders.add(Map<String, String>.from(request.headers));
    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(responseBody)),
      200,
    );
  }
}

void main() {
  const cannedJson =
      '{"query":{"pages":{"1":{"title":"File:Sakura.jpg","imageinfo":'
      '[{"thumburl":"https://upload.wikimedia.org/w/thumb_Sakura.jpg"}]}}}}';

  group('WikimediaImageService.fetchThumbnailUrl', () {
    test('requests the default thumbnail width of 600', () async {
      final client = _RecordingClient(cannedJson);
      final url = await WikimediaImageService()
          .fetchThumbnailUrl('sakura', client: client);
      expect(url, 'https://upload.wikimedia.org/w/thumb_Sakura.jpg');
      expect(client.requestedUrls.single.queryParameters['iiurlwidth'], '600');
    });

    test('honors an explicit reduced thumbnail width', () async {
      final client = _RecordingClient(cannedJson);
      await WikimediaImageService()
          .fetchThumbnailUrl('sakura', width: 320, client: client);
      expect(client.requestedUrls.single.queryParameters['iiurlwidth'], '320');
    });

    test('sends the mandatory descriptive User-Agent', () async {
      final client = _RecordingClient(cannedJson);
      await WikimediaImageService().fetchThumbnailUrl('sakura', client: client);
      expect(
        client.requestHeaders.single['User-Agent'],
        contains('JishoAnkiDicts'),
      );
    });

    test('blank terms return null without any HTTP request', () async {
      final client = _RecordingClient(cannedJson);
      final url = await WikimediaImageService()
          .fetchThumbnailUrl('   ', client: client);
      expect(url, isNull);
      expect(client.requestedUrls, isEmpty);
    });
  });

  group('preloadImage', () {
    const pngBytes64 =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhf'
        'DwAChwGA60e6kgAAAABJRU5ErkJggg==';

    testWidgets('warms the image cache and returns a render-ready handle',
        (tester) async {
      final image = MemoryImage(base64Decode(pngBytes64));
      PreloadedImage? result;
      await tester.runAsync(() async {
        result = await preloadImage(
          url: 'https://example.com/sakura.png',
          buildProvider: (_, __) => image,
        );
      });
      expect(result, isNotNull);
      expect(result!.url, 'https://example.com/sakura.png');
      expect(result!.provider, same(image));
    });

    testWidgets('returns null when download or decode fails', (tester) async {
      PreloadedImage? result;
      await tester.runAsync(() async {
        result = await preloadImage(
          url: 'https://example.com/broken.png',
          buildProvider: (_, __) => ResizeImage(
            MemoryImage(Uint8List.fromList(<int>[0, 1, 2, 3])),
            width: 8,
          ),
        );
      });
      expect(result, isNull);
    });

    test('blank urls return null without building a provider', () async {
      var built = false;
      final result = await preloadImage(
        url: '  ',
        buildProvider: (_, __) {
          built = true;
          return MemoryImage(Uint8List(0));
        },
      );
      expect(result, isNull);
      expect(built, isFalse);
    });

    test('buildPreloadProvider bounds decode width via ResizeImage', () {
      final provider = buildPreloadProvider(
        'https://example.com/sakura.png',
        decodeWidth: 240,
      );
      expect(provider, isA<ResizeImage>());
      expect((provider as ResizeImage).width, 240);
    });
  });
}
