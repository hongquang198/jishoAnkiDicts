// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get helloWorld => 'Xin chào!';

  @override
  String get lookUp => 'Tìm kiếm';

  @override
  String get history => 'Lịch sử';

  @override
  String get favorite => 'Yêu thích';

  @override
  String get review => 'Ôn tập';

  @override
  String get settings => 'Tùy chọn';

  @override
  String get examples => 'Ví dụ';

  @override
  String get components => 'Hán tự';

  @override
  String get enableFloating => 'Nút tra nhanh khi thoát ứng dụng';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get reviewComplete => 'Bạn đã hoàn thành phần ôn tập.';

  @override
  String get appTitle => 'Từ điển JishoAnki';

  @override
  String get newCardsPerDay => 'Số thẻ flashcard mới / ngày';

  @override
  String get graduatingInterval =>
      'Khoảng thời gian thẻ flashcard trưởng thành';

  @override
  String get graduatingIntervalDescription =>
      'Graduating Interval: Khi một thẻ mới được học sẽ có khoảng thời gian (interval) này';

  @override
  String get startingEase => 'Tỉ lệ ease ban đầu';

  @override
  String get startingEaseDescription =>
      'Starting ease: Tỉ lệ ban đầu được nhân với khoảng thời gian (interval) của thẻ để quyết định khoảng interval tiếp theo khi ấn nút Tốt';

  @override
  String get lapsesSteps => '';

  @override
  String get lapsesStepsDescription =>
      'Lapses Steps: Khi một thẻ đã đạt độ trưởng thành mà bị quên, thẻ sẽ có khoảng thời gian mới này';

  @override
  String get leechThreshold => 'Ngưỡng học lại (số lần)';

  @override
  String get leechThresholdDescription =>
      'Leech Threshold: Số lần một thẻ trưởng thành bị học lại (ấn nút Again) quá nhiều lần, thẻ sẽ bị xóa';

  @override
  String get newCardsStep => 'Bước nhảy của thẻ mới';

  @override
  String get newCardsStepDescription =>
      'New cards steps: Khoảng thời gian của thẻ sẽ lần lượt có interval trong list sau mỗi lần ấn nút \'Tốt\'';

  @override
  String get sentenceTranslate => 'Dịch câu';

  @override
  String get statistics => 'Thống kê';

  @override
  String get exampleNumber => 'Số câu ví dụ (tối đa)';

  @override
  String get grammar => 'Ngữ pháp';

  @override
  String get darkMode => 'Chế độ ban đêm';

  @override
  String get view => 'Xem';

  @override
  String get views => 'Lượt xem';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get tokenExpiredMessage => 'Token expired';

  @override
  String get invalidRequest => 'Invalid request';

  @override
  String get unauthorised => 'Unauthorised';

  @override
  String get fetchDataError => 'Fetch data error';

  @override
  String get connectionError => 'Connection error';

  @override
  String get menu => 'Tùy chọn';
}
