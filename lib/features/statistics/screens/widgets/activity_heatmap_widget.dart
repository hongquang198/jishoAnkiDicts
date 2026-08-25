import 'package:flutter/material.dart';

class ActivityHeatmapWidget extends StatelessWidget {
  final Map<String, int> activityData;

  const ActivityHeatmapWidget({super.key, required this.activityData});

  Color _getColor(int count) {
    if (count == 0) return Colors.grey.shade200;
    if (count <= 5) return const Color(0xFFC8E6C9);
    if (count <= 15) return const Color(0xFF81C784);
    if (count <= 30) return const Color(0xFF4CAF50);
    return const Color(0xFF2E7D32);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(28, (i) => now.subtract(Duration(days: 27 - i)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review Activity (Past 4 Weeks)',
          style: TextStyle(
            color: Color(0xffDB8C8A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: days.map((date) {
            final key =
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            final count = activityData[key] ?? 0;
            return Tooltip(
              message: '$key: $count reviews',
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _getColor(count),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black12),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('Less ', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ...[0, 3, 10, 20, 35].map((c) => Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _getColor(c),
                    borderRadius: BorderRadius.circular(2),
                  ),
                )),
            const Text(' More', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}
