import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:jisho_anki/config/app_routes.dart';
import 'package:jisho_anki/core/data/datasources/shared_pref.dart';
import 'package:jisho_anki/injection.dart';
import 'package:jisho_anki/models/example_sentence.dart';
import 'package:jisho_anki/services/kanji_helper.dart';
import 'package:jisho_anki/services/llm/gen_ui_data_prefetch.dart';
import 'package:jisho_anki/services/llm/gen_ui_prefetch.dart';
import 'package:jisho_anki/services/llm_service.dart';
import 'package:jisho_anki/services/wikimedia_image_service.dart';
import '../../bloc/main_search_bloc.dart';
import '../gen_ui_definition_screen.dart';

class LlmSearchResultTile extends StatefulWidget {
  final String query;

  const LlmSearchResultTile({
    super.key,
    required this.query,
  });

  @override
  State<LlmSearchResultTile> createState() => _LlmSearchResultTileState();
}

class _LlmSearchResultTileState extends State<LlmSearchResultTile> {
  bool _isExpanded = false;
  bool _hasStartedStream = false;
  String _accumulatedText = '';
  bool _isStreaming = false;
  String? _errorMessage;
  StreamSubscription<String>? _subscription;

  @override
  void didUpdateWidget(covariant LlmSearchResultTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _resetStreamState();
      _startStreaming();
    }
  }

  void _resetStreamState() {
    _subscription?.cancel();
    _subscription = null;
    _hasStartedStream = false;
    _accumulatedText = '';
    _isStreaming = false;
    _errorMessage = null;
  }

  void _toggleExpanded() {
    context.read<MainSearchBloc>().add(ExpandLlmTileEvent(!_isExpanded));
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded && !_hasStartedStream) {
        _startStreaming();
      }
    });
  }

  /// Opens the dedicated full-screen GenUI explanation page. Only reachable
  /// from the sparkle icon button, not from tapping the rest of the tile.
  void _openGenUiScreen() {
    context.pushNamed(
      AppRoutesPath.genUiDefinition,
      extra: GenUiDefinitionScreenArgs(
        query: widget.query,
        mainSearchBloc: context.read<MainSearchBloc>(),
      ),
    );
  }

  void _startStreaming() {
    final sharedPref = getIt<SharedPref>();
    final llmService = getIt<LlmService>();

    if (!sharedPref.llmEnable) return;

    if (sharedPref.llmApiKey.trim().isEmpty) {
      setState(() {
        _hasStartedStream = true;
        _errorMessage = 'missing_key';
      });
      return;
    }

    if (widget.query.trim().isEmpty) return;

    _resetStreamState();

    setState(() {
      _hasStartedStream = true;
      _isStreaming = true;
    });

    _startRawTextStream(llmService);

    // Pre-warm the GenUI (A2UI protocol) response so that tapping the sparkle
    // icon button renders near-instantly instead of waiting for a fresh call.
    if (sharedPref.llmGenUiEnable) {
      getIt<GenUiPrefetchCache>().warm(
        widget.query,
        startStream: () =>
            llmService.generateExplanationStream(widget.query, useGenUi: true),
      );
    }

    // Pre-warm every other GenUI-screen lane as well: structured gap-fill
    // (badges fallback, sentences, tutor comment), the descriptive picture
    // with bytes already decoded, and the local DB sections. Runs regardless
    // of llmGenUiEnable — only the LLM lane respects enable/key flags.
    final resolved = resolveMainSearchData(
      context.read<MainSearchBloc>(),
      widget.query,
    );
    getIt<GenUiDataPrefetchCache>().warm(
      widget.query,
      start: () => GenUiDataPrefetch.start(
        query: widget.query,
        jishoDefinition: resolved.jishoDefinition,
        llmEnabled:
            sharedPref.llmEnable && sharedPref.llmApiKey.trim().isNotEmpty,
        fetchWordInfo: llmService.fetchWordInfo,
        searchThumbnailUrl: (term) => getIt<WikimediaImageService>()
            .fetchThumbnailUrl(term, width: kPrewarmThumbnailWidth),
        loadPitchWidgets: () => KanjiHelper.getPitchAccent(
          word: widget.query,
          slug: resolved.jishoDefinition.slug,
          reading: resolved.jishoDefinition.reading,
          context: context,
        ),
        loadExamples: () => _loadPrewarmExamples(sharedPref),
        loadKanjiComponents: () =>
            KanjiHelper.getKanjiComponent(word: widget.query),
      ),
    );
  }

  /// Mirrors the screen's localized example-sentence selection: English table
  /// for English, Vietnamese table first (with English fallback) for
  /// Tiếng Việt, nothing otherwise.
  Future<List<ExampleSentence>> _loadPrewarmExamples(SharedPref sharedPref) {
    final lang = sharedPref.prefs.getString('language');
    if (lang?.contains('English') == true) {
      return KanjiHelper.getExampleSentence(
        word: widget.query,
        context: context,
        tableName: 'englishExampleDictionary',
      );
    }
    if (lang != 'Tiếng Việt') return Future.value(const []);
    return KanjiHelper.getExampleSentence(
      word: widget.query,
      context: context,
      tableName: 'exampleDictionary',
    ).then((vnExamples) {
      if (vnExamples.isNotEmpty) return vnExamples;
      return KanjiHelper.getExampleSentence(
        word: widget.query,
        context: context,
        tableName: 'englishExampleDictionary',
      );
    });
  }

  void _startRawTextStream(LlmService llmService) {
    final stream = llmService.generateExplanationStream(widget.query);
    _subscription = stream.listen(
      (chunk) {
        if (mounted) {
          setState(() {
            _accumulatedText += chunk;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isStreaming = false;
            _errorMessage = error.toString();
          });
        }
      },
      onDone: () {
        if (mounted) {
          setState(() {
            _isStreaming = false;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startStreaming());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sharedPref = getIt<SharedPref>();
    if (!sharedPref.llmEnable) {
      return const SizedBox.shrink();
    }

    final isVn = sharedPref.isAppInVietnamese;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFDB8C8A).withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isVn
                          ? '✨   AI Giải thích: "${widget.query}"'
                          : '✨   AI Explanation: "${widget.query}"',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_isStreaming)
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFDB8C8A),
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: _openGenUiScreen,
                    tooltip: isVn ? 'Mở trang AI đầy đủ' : 'Open full AI page',
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFDB8C8A).withValues(alpha: 0.15),
                      shape: const CircleBorder(),
                    ),
                    icon: const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFDB8C8A),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: _buildBodyContent(context, isVn),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, bool isVn) {
    if (_errorMessage == 'missing_key') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isVn
                      ? 'Chưa cấu hình Gemini API Key.'
                      : 'Gemini API Key is not set.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isVn
                ? 'Vui lòng truy cập Cài đặt để thêm Gemini API Key cá nhân của bạn.'
                : 'Please go to Settings to configure your personal Gemini API Key.',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDB8C8A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              GoRouter.of(context).push(AppRoutesPath.settings);
            },
            icon: const Icon(Icons.settings, size: 16),
            label: Text(isVn ? 'Mở Cài đặt' : 'Open Settings'),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isVn
                ? 'Đã xảy ra lỗi khi kết nối AI:'
                : 'An error occurred while connecting to AI:',
            style:
                const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 12, color: Colors.redAccent),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _startStreaming,
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(isVn ? 'Thử lại' : 'Retry'),
          ),
        ],
      );
    }

    if (_isStreaming && _accumulatedText.isEmpty) {
      return _buildLoadingIndicator(isVn);
    }

    // Raw text mode
    if (_accumulatedText.isEmpty && !_isStreaming) {
      return Text(
        isVn ? 'Không có câu trả lời.' : 'No output received.',
        style: const TextStyle(color: Colors.grey),
      );
    }

    return _buildRawTextContent(context, isVn);
  }

  Widget _buildLoadingIndicator(bool isVn) {
    return Row(
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFDB8C8A),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          isVn ? 'Đang phân tích từ vựng...' : 'Analyzing query...',
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildRawTextContent(BuildContext context, bool isVn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HtmlWidget(
          _markdownToSimpleHtml(_accumulatedText),
          textStyle: const TextStyle(fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: isVn ? 'Sao chép' : 'Copy',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _accumulatedText));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isVn
                          ? 'Đã sao chép vào bộ nhớ tạm!'
                          : 'Copied to clipboard!',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: isVn ? 'Tạo lại' : 'Regenerate',
              onPressed: _startStreaming,
            ),
          ],
        ),
      ],
    );
  }

  /// Simple converter to format markdown headers/bold text into HTML for HtmlWidget
  String _markdownToSimpleHtml(String markdown) {
    String text = markdown
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');

    text = text.replaceAllMapped(
        RegExp(r'\*\*(.*?)\*\*'), (match) => '<b>${match[1]}</b>');
    text = text.replaceAllMapped(
        RegExp(r'\*(.*?)\*'), (match) => '<i>${match[1]}</i>');
    text = text.replaceAllMapped(
        RegExp(r'`(.*?)`'), (match) => '<code>${match[1]}</code>');
    text = text.replaceAll('\n', '<br/>');
    return text;
  }
}
