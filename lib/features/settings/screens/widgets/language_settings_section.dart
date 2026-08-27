import 'package:flutter/material.dart';
import '../../../../core/data/datasources/shared_pref.dart';
import '../../../../injection.dart';

class LanguageSettingsSection extends StatefulWidget {
  const LanguageSettingsSection({super.key});

  @override
  State<LanguageSettingsSection> createState() => _LanguageSettingsSectionState();
}

class _LanguageSettingsSectionState extends State<LanguageSettingsSection> {
  @override
  Widget build(BuildContext context) {
    final pref = getIt<SharedPref>();
    final isVn = pref.isAppInVietnamese;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(thickness: 1.5, height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(
            isVn ? 'Cấu hình Ngôn ngữ (Source & Target)' : 'Language Configuration',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),

        // Source Language Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isVn ? 'Ngôn ngữ mẹ đẻ (Source):' : 'Native Language (Source):'),
              DropdownButton<String>(
                value: pref.sourceLanguage,
                items: const [
                  DropdownMenuItem(value: 'Tiếng Việt', child: Text('Tiếng Việt')),
                  DropdownMenuItem(value: 'English', child: Text('English')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      pref.sourceLanguage = val;
                    });
                  }
                },
              ),
            ],
          ),
        ),

        // Target Language Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isVn ? 'Ngôn ngữ học (Target):' : 'Learning Language (Target):'),
              DropdownButton<String>(
                value: pref.targetLanguage,
                items: const [
                  DropdownMenuItem(value: 'Japanese', child: Text('Japanese')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      pref.targetLanguage = val;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
