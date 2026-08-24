import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:unofficial_jisho_api/api.dart';
import 'package:jisho_anki/features/word_definition/screens/widgets/definition_widget.dart';
import 'package:jisho_anki/features/word_definition/screens/widgets/example_sentence_widget.dart';
import 'package:jisho_anki/features/word_definition/screens/widgets/component_widget.dart';
import 'package:jisho_anki/models/example_sentence.dart';
import 'package:jisho_anki/models/kanji.dart';

/// GenUI Catalog Item mapping to [DefinitionWidget].
final definitionCardItem = CatalogItem(
  name: 'DefinitionCard',
  dataSchema: S.object(
    properties: {
      'vietnameseDefinition': S.string(
          description: 'Optional Vietnamese definition HTML or raw text'),
      'senses': S.list(
        items: S.object(
          properties: {
            'english_definitions': S.list(items: S.string()),
            'parts_of_speech': S.list(items: S.string()),
            'tags': S.list(items: S.string()),
            'info': S.list(items: S.string()),
          },
          required: ['english_definitions', 'parts_of_speech'],
        ),
      ),
    },
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    final vnDef = data['vietnameseDefinition'] as String?;
    final sensesData = data['senses'] as List<dynamic>?;
    final List<JishoWordSense>? senses = sensesData?.map((e) {
      final map = e as Map<String, dynamic>;
      return JishoWordSense(
        englishDefinitions: List<String>.from(map['english_definitions'] ?? []),
        partsOfSpeech: List<String>.from(map['parts_of_speech'] ?? []),
        tags: List<String>.from(map['tags'] ?? []),
        info: List<String>.from(map['info'] ?? []),
      );
    }).toList();
    return DefinitionWidget(
      vietnameseDefinition: vnDef,
      senses: senses,
    );
  },
);

/// GenUI Catalog Item mapping to [ExampleSentenceWidget].
final exampleSentencesItem = CatalogItem(
  name: 'ExampleSentences',
  dataSchema: S.object(
    properties: {
      'sentences': S.list(
        items: S.object(
          properties: {
            'jpSentence': S.string(description: 'Japanese sentence'),
            'targetSentence': S.string(
                description:
                    'Target language translation sentence (e.g. English/Vietnamese)'),
            'jpSentenceId': S.string(),
            'targetSentenceId': S.string(),
          },
          required: ['jpSentence'],
        ),
      ),
    },
    required: ['sentences'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    final sentencesData = data['sentences'] as List<dynamic>;
    final sentences = sentencesData.map((e) {
      final map = e as Map<String, dynamic>;
      return ExampleSentence(
        jpSentence: map['jpSentence'] as String?,
        targetSentence: map['targetSentence'] as String?,
        jpSentenceId: map['jpSentenceId'] as String?,
        targetSentenceId: map['targetSentenceId'] as String?,
      );
    }).toList();
    return ExampleSentenceWidget(
      exampleSentence: Future.value(sentences),
    );
  },
);

/// GenUI Catalog Item mapping to [ComponentWidget].
final kanjiComponentsItem = CatalogItem(
  name: 'KanjiComponents',
  dataSchema: S.object(
    properties: {
      'components': S.list(
        items: S.object(
          properties: {
            'kanji': S.string(description: 'The kanji character'),
            'hanViet':
                S.string(description: 'Sino-Vietnamese reading (optional)'),
            'onYomi': S.string(description: 'On\'yomi reading'),
            'kunYomi': S.string(description: 'Kun\'yomi reading'),
            'keyword':
                S.string(description: 'Heisig keyword or English keyword'),
            'strokeCount': S.string(description: 'Stroke count (optional)'),
          },
          required: ['kanji'],
        ),
      ),
    },
    required: ['components'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    final componentsData = data['components'] as List<dynamic>;
    final components = componentsData.map((e) {
      final map = e as Map<String, dynamic>;
      return Kanji(
        kanji: map['kanji'] as String?,
        hanViet: map['hanViet'] as String?,
        onYomi: map['onYomi'] as String?,
        kunYomi: map['kunYomi'] as String?,
        keyword: map['keyword'] as String?,
        strokeCount: map['strokeCount'] as String?,
      );
    }).toList();
    return ComponentWidget(
      kanjiComponent: Future.value(components),
    );
  },
);

/// The standard GenUI catalog containing all mapping widgets.
final genUiCatalog = Catalog([
  definitionCardItem,
  exampleSentencesItem,
  kanjiComponentsItem,
]);
