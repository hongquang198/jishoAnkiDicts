import 'package:flutter/material.dart';

/// Pitch-accent line shared by the dictionary detail headers.
///
/// Shows the accent widgets once loaded, falling back to the plain reading
/// (or nothing when even that is empty) so every header shares one rule.
class PitchAccentLine extends StatelessWidget {
  final Future<List<Widget>> pitchAccent;
  final String fallbackReading;
  final double fontSize;

  const PitchAccentLine({
    super.key,
    required this.pitchAccent,
    required this.fallbackReading,
    this.fontSize = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: pitchAccent,
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data?.isEmpty == true) {
          if (fallbackReading.isEmpty) return const SizedBox.shrink();
          return Text(
            fallbackReading,
            style: TextStyle(fontSize: fontSize, color: Colors.grey),
          );
        }
        return Row(children: snapshot.data!);
      },
    );
  }
}
