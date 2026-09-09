part of 'gen_ui_definition_screen.dart';

/// Render sections for [GenUiDefinitionScreen].
///
/// Pure UI builders over the state owned by this screen: pitch accent,
/// examples, and the AI explanation body. No business logic lives here.
extension _GenUiDefinitionSectionsExt on _GenUiDefinitionScreenState {
  Widget _buildPitchAccentSection() {
    final pitchWidgets = _effectivePitchWidgets;
    if (pitchWidgets.isNotEmpty) {
      return Row(children: pitchWidgets);
    }
    if (!_pitchLaneDone && _llmInfo == null) return const SizedBox.shrink();
    final reading = _effectiveReading;
    if (reading.isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        reading,
        style: const TextStyle(
          fontSize: 15.0,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildExamplesSection() {
    final future = _examplesFuture;
    if (future == null) return const SizedBox.shrink();
    return ExampleSentenceWidget(
      exampleSentence: future,
    );
  }

  Widget _buildAiBodyContent() {
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
        ],
      );
    }

    if (_receivedA2uiContent) {
      return Surface(
        surfaceContext: _surfaceController!
            .contextFor(_GenUiDefinitionScreenState._surfaceId),
      );
    }

    if (_isStreaming) return _buildLoadingIndicator();
    return Text(
      l.noOutputReceived,
      style: const TextStyle(color: Colors.grey),
    );
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
}
