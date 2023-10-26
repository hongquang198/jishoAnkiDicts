import 'package:jisho_anki/features/main_search/presentation/screens/widgets/draw_screen.dart';

class MediaQuerySize {
  double _maxWidth = 0;
  double _maxHeight = 0;

  void setMaxWidth(double value) => _maxWidth = value;
  void setMaxHeight(double value) => _maxHeight = value;

  double get maxWidth => _maxWidth;
  double get maxHeight => _maxHeight;
  double get canvasSize =>
      _maxWidth -
      DrawScreenConst.canvasOptionMaxSize -
      DrawScreenConst.canvasPadding.horizontal -
      8.0;
}
