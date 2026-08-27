import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/datasources/shared_pref.dart';
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
    final isVn = _selectedSource == 'Tiếng Việt';

    return Scaffold(
      appBar: AppBar(
        title: Text(isVn ? 'Chọn Ngôn Ngữ' : 'Select Languages'),
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
                isVn ? 'Chào mừng bạn đến với Jisho Anki!' : 'Welcome to Jisho Anki!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isVn
                    ? 'Vui lòng chọn ngôn ngữ mẹ đẻ và ngôn ngữ bạn muốn học.'
                    : 'Please select your native language and the language you want to learn.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              // Source / Native Language Picker
              Text(
                isVn ? 'Ngôn ngữ mẹ đẻ (Source Language):' : 'Native Language (Source):',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedSource,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Tiếng Việt', child: Text('Tiếng Việt (Vietnamese)')),
                  DropdownMenuItem(value: 'English', child: Text('English')),
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
                isVn ? 'Ngôn ngữ muốn học (Target Language):' : 'Language to Learn (Target):',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedTarget,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Japanese', child: Text('Japanese (Tiếng Nhật)')),
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
                  context.go('/');
                },
                child: Text(
                  isVn ? 'Bắt đầu ngay' : 'Get Started',
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
