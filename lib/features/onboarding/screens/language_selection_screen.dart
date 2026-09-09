import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/data/datasources/shared_pref.dart';
import '../../../l10n/app_localizations.dart';
import '../../../localization_manager.dart';
import '../../language/app_languages.dart';
import '../../../injection.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late String _selectedSource;
  late String _selectedTarget;

  @override
  void initState() {
    super.initState();
    final pref = getIt<SharedPref>();
    _selectedSource = pref.sourceLanguage.isNotEmpty ? pref.sourceLanguage : 'Tiếng Việt';
    _selectedTarget = pref.targetLanguage.isNotEmpty ? pref.targetLanguage : 'Japanese';
  }

  @override
  Widget build(BuildContext context) {
    // Preview strings in the selected source language so the user sees the
    // UI they are about to get, even before confirming.
    final l = lookupAppLocalizations(
      Locale(localeCodeForSource(_selectedSource)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l.selectLanguages),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Icon(
                Icons.language_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                l.welcomeJishoAnki,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l.selectNativeTargetDesc,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              // Source / Native Language Picker
              Text(
                l.onboardingNativeLanguage,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedSource,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final language in kSourceLanguages)
                    DropdownMenuItem(
                      value: language.label,
                      child: Text('${language.label} (${language.promptName})'),
                    ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedSource = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              // Target / Learning Language Picker
              Text(
                l.onboardingTargetLanguage,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedTarget,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final target in kTargetLanguages)
                    DropdownMenuItem(value: target, child: Text(target)),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedTarget = val;
                    });
                  }
                },
              ),
              const Spacer(),

              // Confirm Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final pref = getIt<SharedPref>();
                  pref.sourceLanguage = _selectedSource;
                  pref.targetLanguage = _selectedTarget;
                  pref.hasCompletedLanguageSetup = true;
                  // The source language owns the app locale (and through it
                  // the LLM prompt language), so apply it immediately.
                  Provider.of<LocalizationNotifier>(context, listen: false)
                      .setLanguage(language: _selectedSource);
                  context.go('/');
                },
                child: Text(
                  l.getStarted,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
