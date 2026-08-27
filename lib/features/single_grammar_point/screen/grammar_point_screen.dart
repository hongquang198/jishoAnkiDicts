import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';

import '../../../injection.dart';
import '../../../core/domain/entities/dictionary.dart';
import '../../../models/example_sentence.dart';
import '../../../models/grammar_point.dart';
import '../../../models/kanji.dart';
import '../../../services/kanji_helper.dart';
import '../../../services/llm_service.dart';
import '../../../utils/constants.dart';
import '../../../common/widgets/ai/ai_tutor_card.dart';
import '../../../common/widgets/ai/ai_memory_tip_card.dart';
import '../../../common/widgets/ai/ai_grammar_breakdown_card.dart';
import '../../../config/app_routes.dart';
import '../../ai_chat/screens/ai_chat_screen.dart';
import '../../word_definition/screens/widgets/component_widget.dart';
import '../../word_definition/screens/widgets/example_sentence_widget.dart';

class GrammarPointScreen extends StatefulWidget {
  final GrammarPoint grammarPoint;
  const GrammarPointScreen({
    required this.grammarPoint,
    super.key,
  });

  @override
  State<GrammarPointScreen> createState() => _GrammarPointScreenState();
}

class _GrammarPointScreenState extends State<GrammarPointScreen> {
  late Future<List<Kanji>> kanjiList;
  String? _aiTutorComment;
  String? _aiMemoryTip;
  String? _aiGrammarAnalysis;
  bool _isAiLoading = true;

  Divider get divider =>
      Divider(thickness: 0.4, color: Theme.of(context).dividerColor);

  Widget getPartsOfSpeech(List<dynamic> partsOfSpeech) {
    if (partsOfSpeech.isNotEmpty) {
      return Text(
        partsOfSpeech.first.toString().toUpperCase(),
      );
    }
    return SizedBox();
  }

  Future<List<ExampleSentence>> getGrammarExamples() async {
    List<ExampleSentence> query = await getIt<Dictionary>()
        .offlineDatabase
        .searchForGrammarExample(
            grammarPoint: widget.grammarPoint.grammarPoint!);
    return query;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    kanjiList =
        KanjiHelper.getKanjiComponent(word: widget.grammarPoint.grammarPoint!);
    _fetchGrammarAiInfo();
  }

  Future<void> _fetchGrammarAiInfo() async {
    try {
      final llmService = getIt<LlmService>();
      final info = await llmService
          .fetchWordInfo(widget.grammarPoint.grammarPoint ?? '');
      if (!mounted) return;
      setState(() {
        _isAiLoading = false;
        if (info != null && info['found'] == true) {
          _aiTutorComment = info['tutorComment']?.toString();
          _aiMemoryTip = info['memoryTip']?.toString();
          _aiGrammarAnalysis = info['grammarAnalysis']?.toString().isNotEmpty ==
                  true
              ? info['grammarAnalysis']?.toString()
              : widget.grammarPoint.grammarMeaning;
        } else {
          _aiGrammarAnalysis = widget.grammarPoint.grammarMeaning;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isAiLoading = false;
        _aiGrammarAnalysis = widget.grammarPoint.grammarMeaning;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.only(left: 12, right: 12),
        child: ListView(children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.grammarPoint.grammarPoint!,
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Card(
                color: Color(0xFF8ABC82),
                child: Text(
                  widget.grammarPoint.jlptLevel!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.only(bottom: 10, left: 10),
            child: Text(
              widget.grammarPoint.grammarMeaning!,
              style: TextStyle(fontSize: Constants.definitionTextSize),
            ),
          ),
          divider,
          Text(
            'Examples',
            style: TextStyle(
              color: Color(0xffDB8C8A),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          ExampleSentenceWidget(
            exampleSentence: getGrammarExamples(),
          ),
          divider,
          Text(
            'Components',
            style: TextStyle(
              color: Color(0xffDB8C8A),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          ComponentWidget(
            kanjiComponent: kanjiList,
          ),
          divider,
          const Text(
            'AI Grammar Insights & Tutor',
            style: TextStyle(
              color: Color(0xffDB8C8A),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          AiTutorCard(
            tutorComment: _aiTutorComment,
            isLoading: _isAiLoading,
            onAskAiTutor: () {
              context.push(
                AppRoutesPath.aiChat,
                extra: AiChatScreenArgs(
                  word: widget.grammarPoint.grammarPoint ?? '',
                  grammarPoint: widget.grammarPoint.grammarMeaning,
                  existingTutorComment: _aiTutorComment,
                  existingMemoryTip: _aiMemoryTip,
                ),
              );
            },
          ),
          AiMemoryTipCard(
            memoryTip: _aiMemoryTip,
            isLoading: _isAiLoading,
          ),
          AiGrammarBreakdownCard(
            grammarAnalysis: _aiGrammarAnalysis,
            isLoading: _isAiLoading,
          ),
        ]),
      ),
    );
  }
}
