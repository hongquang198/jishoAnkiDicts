import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:jisho_anki/config/app_routes.dart';
import 'package:jisho_anki/core/data/datasources/shared_pref.dart';
import 'package:jisho_anki/injection.dart';
import 'package:jisho_anki/l10n/app_localizations.dart';
import 'package:jisho_anki/services/llm/gen_ui_data_prefetch.dart';
import 'package:jisho_anki/services/llm/gen_ui_prefetch.dart';
import 'package:jisho_anki/services/llm_service.dart';
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
      start: () => startDefaultDataPrefetch(
        query: widget.query,
        jishoDefinition: resolved.jishoDefinition,
      ),
    );
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

    final l = AppLocalizations.of(context)!;

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
                      l.aiExplanationTitle(widget.query),
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
                    tooltip: l.openFullAiPage,
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
              child: _buildBodyContent(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
                  l.geminiKeyNotSet,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.configureGeminiKeyDesc,
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
            label: Text(l.openSettings),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.aiConnectionError,
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
            label: Text(l.retry),
          ),
        ],
      );
    }

    if (_isStreaming && _accumulatedText.isEmpty) {
      return _buildLoadingIndicator();
    }

    // Raw text mode
    if (_accumulatedText.isEmpty && !_isStreaming) {
      return Text(
        l.noOutputReceived,
        style: const TextStyle(color: Colors.grey),
      );
    }

    return _buildRawTextContent(context);
  }

  Widget _buildLoadingIndicator() {
    final l = AppLocalizations.of(context)!;
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
          l.analyzingQuery,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildRawTextContent(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
              tooltip: l.copy,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _accumulatedText));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l.copiedToClipboard,
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: l.regenerate,
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
