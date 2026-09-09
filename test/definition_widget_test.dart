import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/core/data/datasources/shared_pref.dart';
import 'package:jisho_anki/features/word_definition/screens/widgets/definition_widget.dart';
import 'package:jisho_anki/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DefinitionWidget gloss gating', () {
    late SharedPref sharedPref;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPref = SharedPref(prefs: await SharedPreferences.getInstance());
      await sharedPref.init();
      getIt.registerSingleton<SharedPref>(sharedPref);
    });

    tearDown(() async {
      if (getIt.isRegistered<SharedPref>()) {
        getIt.unregister<SharedPref>();
      }
    });

    Future<void> pumpGloss(WidgetTester tester, {String? gloss}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DefinitionWidget(localizedGloss: gloss)),
        ),
      );
      await tester.pump();
    }

    testWidgets('shows saved gloss for non-Vietnamese sources', (tester) async {
      sharedPref.sourceLanguage = 'French';
      await pumpGloss(tester, gloss: 'livre');
      expect(find.text('livre', findRichText: true), findsOneWidget);
    });

    testWidgets('shows saved gloss for Vietnamese source', (tester) async {
      sharedPref.sourceLanguage = 'Tiếng Việt';
      await pumpGloss(tester, gloss: 'sách');
      expect(find.text('sách', findRichText: true), findsOneWidget);
    });

    testWidgets('renders nothing without gloss or senses', (tester) async {
      sharedPref.sourceLanguage = 'English';
      await pumpGloss(tester);
      expect(find.byType(DefinitionWidget), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });
  });
}
