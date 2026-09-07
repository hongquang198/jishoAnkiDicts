import 'package:flutter/material.dart';

/// Pinned collapsing app bar shared by the dictionary detail screens.
///
/// Renders the animated scroll-reveal [title], a horizontally scrolling
/// [tags] lane, caller-supplied [actions], and a [header] body showing the
/// reading, headword, and descriptive picture. Both the classic definition
/// screen and the GenUI definition screen use it so the collapse behavior
/// exists exactly once.
class DefinitionSliverAppBar extends StatelessWidget {
  /// Drives the title reveal animation. Owned by the hosting screen.
  final ScrollController scrollController;

  /// Headword shown collapsed in the toolbar and expanded in [header].
  final String title;

  /// Common/JLPT tag lane shown beside the collapsed title.
  final Widget tags;

  /// Toolbar actions (view count, bookmark, review, regenerate, ...).
  final List<Widget> actions;

  /// Expanded header body (reading, headword, picture, ...).
  final Widget header;

  const DefinitionSliverAppBar({
    super.key,
    required this.scrollController,
    required this.title,
    this.tags = const SizedBox.shrink(),
    this.actions = const [],
    required this.header,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSplitMode = MediaQuery.sizeOf(context).height < 650;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 145,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: scrollController,
            builder: (context, child) {
              final textPainter = TextPainter(
                text: TextSpan(
                  text: title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                textDirection: TextDirection.ltr,
              )..layout();

              final offset =
                  scrollController.hasClients ? scrollController.offset : 0.0;
              const double maxScroll = 100.0;
              final double progress = (offset / maxScroll).clamp(0.0, 1.0);
              final double dynamicWidth = textPainter.width * progress;

              return SizedBox(
                width: dynamicWidth,
                child: dynamicWidth == 0 ? null : child,
              );
            },
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: tags,
            ),
          ),
        ],
      ),
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.fromLTRB(12, isSplitMode ? 50 : 98, 12, 8),
          child: header,
        ),
      ),
    );
  }
}
