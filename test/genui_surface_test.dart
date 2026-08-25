import 'package:a2ui_core/a2ui_core.dart' as core;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:jisho_anki/services/llm/genui_catalog.dart';

void main() {
  group('SurfaceController + Surface Integration Tests', () {
    late SurfaceController controller;

    setUp(() {
      controller = SurfaceController(catalogs: [genUiCatalog]);
    });

    tearDown(() {
      controller.dispose();
    });

    test('SurfaceController initializes with the genUiCatalog', () {
      expect(controller.catalogs, contains(genUiCatalog));
      expect(controller.activeSurfaceIds, isEmpty);
    });

    testWidgets(
        'Surface renders defaultBuilder when no surface has been created',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Surface(
              surfaceContext: controller.contextFor('test_surface'),
              defaultBuilder: (_) => const Text('No content yet'),
            ),
          ),
        ),
      );

      expect(find.text('No content yet'), findsOneWidget);
    });

    testWidgets(
        'Surface renders SizedBox when no surface and no defaultBuilder',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Surface(
              surfaceContext: controller.contextFor('test_surface'),
            ),
          ),
        ),
      );

      // Should not throw - renders empty SizedBox
      expect(find.byType(Surface), findsOneWidget);
    });

    testWidgets(
        'Surface reflects a created surface after receiving an A2UI createSurface message',
        (tester) async {
      const surfaceId = 'def_surface';
      // ignore: invalid_use_of_internal_member
      final catalogId = genUiCatalog.effectiveCatalogId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Surface(
              surfaceContext: controller.contextFor(surfaceId),
              defaultBuilder: (_) => const Text('loading...'),
            ),
          ),
        ),
      );

      // Initially shows the defaultBuilder
      expect(find.text('loading...'), findsOneWidget);

      // Feed a createSurface message to the controller
      final createMessage = core.CreateSurfaceMessage(
        surfaceId: surfaceId,
        catalogId: catalogId,
      );
      controller.handleMessage(createMessage);

      await tester.pump();

      // Surface no longer shows defaultBuilder
      expect(find.text('loading...'), findsNothing);
    });

    test('A2uiTransportAdapter parses a full JSON message into A2uiMessage',
        () async {
      final adapter = A2uiTransportAdapter();
      final messages = <core.A2uiMessage>[];
      final sub = adapter.incomingMessages.listen(messages.add);

      const catalogId = 'test_catalog';
      const surfaceId = 'test_surface';

      // Feed valid createSurface JSON as chunks
      const json =
          '{"version":"v0.9","createSurface":{"surfaceId":"$surfaceId","catalogId":"$catalogId"}}';

      adapter.addChunk(json);
      // Wait for async processing
      await Future.delayed(const Duration(milliseconds: 50));

      expect(messages, isNotEmpty);
      expect(messages.first, isA<core.CreateSurfaceMessage>());
      expect(
        (messages.first as core.CreateSurfaceMessage).surfaceId,
        equals(surfaceId),
      );

      await sub.cancel();
      adapter.dispose();
    });

    test('A2uiTransportAdapter can receive chunks across split boundaries',
        () async {
      final adapter = A2uiTransportAdapter();
      final messages = <core.A2uiMessage>[];
      final sub = adapter.incomingMessages.listen(messages.add);

      const surfaceId = 'split_surface';
      const catalogId = 'test_catalog';
      const json =
          '{"version":"v0.9","createSurface":{"surfaceId":"$surfaceId","catalogId":"$catalogId"}}';

      // Split into chunks to simulate streaming
      final mid = json.length ~/ 2;
      adapter.addChunk(json.substring(0, mid));
      adapter.addChunk(json.substring(mid));

      await Future.delayed(const Duration(milliseconds: 50));

      expect(messages, isNotEmpty);
      expect(messages.first, isA<core.CreateSurfaceMessage>());

      await sub.cancel();
      adapter.dispose();
    });
  });
}
