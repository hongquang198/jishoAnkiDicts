import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jisho_anki/common/widgets/ai/ai_grammar_breakdown_card.dart';
import 'package:jisho_anki/common/widgets/ai/ai_memory_tip_card.dart';
import 'package:jisho_anki/common/widgets/ai/ai_tutor_card.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AiGrammarBreakdownCard', () {
    testWidgets('renders title and placeholder when empty and not loading',
        (tester) async {
      await tester.pumpWidget(
        _host(const AiGrammarBreakdownCard(grammarAnalysis: null)),
      );
      expect(find.text('Grammar & Structure Breakdown'), findsOneWidget);
      expect(find.text('No grammar breakdown available yet.'), findsOneWidget);
    });

    testWidgets('renders progress indicator while loading', (tester) async {
      await tester.pumpWidget(
        _host(const AiGrammarBreakdownCard(isLoading: true)),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders content when available', (tester) async {
      await tester.pumpWidget(
        _host(const AiGrammarBreakdownCard(grammarAnalysis: 'Present tense.')),
      );
      expect(find.text('Present tense.'), findsOneWidget);
    });

    testWidgets('shows chat button only on the grammar breakdown card',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _host(AiGrammarBreakdownCard(
          grammarAnalysis: null,
          onAskAiTutor: () => tapped = true,
        )),
      );
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      await tester.tap(find.byIcon(Icons.chat_bubble_outline));
      expect(tapped, isTrue);
    });

    testWidgets('shows chat button when grammar content is present',
        (tester) async {
      await tester.pumpWidget(
        _host(AiGrammarBreakdownCard(
          grammarAnalysis: 'Present tense.',
          onAskAiTutor: () {},
        )),
      );
      expect(find.text('Present tense.'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });
  });

  group('AiTutorCard', () {
    testWidgets('renders title and placeholder when empty', (tester) async {
      await tester.pumpWidget(
        _host(const AiTutorCard(tutorComment: null)),
      );
      expect(find.text('AI Tutor Insights'), findsOneWidget);
      expect(find.text('No AI Tutor insights yet.'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsNothing);
    });

    testWidgets('renders error container when errorMessage set',
        (tester) async {
      await tester.pumpWidget(
        _host(const AiTutorCard(errorMessage: 'boom')),
      );
      expect(find.text('Failed to load AI Tutor comments'), findsOneWidget);
    });

    testWidgets('renders skeleton while loading', (tester) async {
      await tester.pumpWidget(
        _host(const AiTutorCard(isLoading: true)),
      );
      expect(find.text('AI Tutor is analyzing word notes...'), findsOneWidget);
    });

    testWidgets('renders content when available', (tester) async {
      await tester.pumpWidget(
        _host(const AiTutorCard(tutorComment: 'Useful note.')),
      );
      expect(find.text('Useful note.'), findsOneWidget);
    });
  });

  group('AiMemoryTipCard', () {
    testWidgets('renders title and placeholder when empty', (tester) async {
      await tester.pumpWidget(
        _host(const AiMemoryTipCard(memoryTip: null)),
      );
      expect(find.text('Memory Tip & Mnemonic'), findsOneWidget);
      expect(find.text('No memory tip available yet.'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsNothing);
    });

    testWidgets('renders content when available', (tester) async {
      await tester.pumpWidget(
        _host(const AiMemoryTipCard(memoryTip: 'Imagine a cherry.')),
      );
      expect(find.text('Imagine a cherry.'), findsOneWidget);
    });
  });
}
