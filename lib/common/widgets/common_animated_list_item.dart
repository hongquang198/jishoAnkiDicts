import 'package:flutter/material.dart';

class CommonAnimatedListItem extends StatefulWidget {
  final Duration animationDuration;
  final Widget child;
  final Curve curve;
  const CommonAnimatedListItem({
    super.key,
    required this.animationDuration,
    required this.child,
    this.curve = Curves.elasticOut,
  });

  @override
  State<CommonAnimatedListItem> createState() => _CommonAnimatedListItemState();
}

class _CommonAnimatedListItemState extends State<CommonAnimatedListItem> {
  bool postFrame = false;
  GlobalKey key = GlobalKey();
  double? height;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final keyContext = key.currentContext;
      double? itsHeight;
      if (keyContext != null) {
        final box = keyContext.findRenderObject() as RenderBox;
        itsHeight = box.size.height;
      }
      setState(() {
        height = 0;
      });
      Future.delayed(const Duration(milliseconds: 50), () {
        setState(() {
          postFrame = true;
          height = itsHeight;
        });
      });
  });
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      key: key,
      opacity: postFrame ? 1 : 0,
      child: AnimatedContainer(
        curve: Curves.elasticOut,
        duration: widget.animationDuration,
        height: height,
        child: widget.child,
      ),
    );
  }
}