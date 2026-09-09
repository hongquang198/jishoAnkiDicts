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
  String get lapsesSteps => 'Bước Lapses';

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
  String get unknownError => 'Lỗi không xác định';

  @override
  String get tokenExpiredMessage => 'Phiên đăng nhập đã hết hạn';

  @override
  String get invalidRequest => 'Yêu cầu không hợp lệ';

  @override
  String get unauthorised => 'Chưa được cấp quyền';

  @override
  String get fetchDataError => 'Lỗi tải dữ liệu';

  @override
  String get connectionError => 'Lỗi kết nối';

  @override
  String get menu => 'Tùy chọn';

  @override
  String get selectLanguages => 'Chọn Ngôn Ngữ';

  @override
  String get welcomeJishoAnki => 'Chào mừng bạn đến với Jisho Anki!';

  @override
  String get selectNativeTargetDesc =>
      'Vui lòng chọn ngôn ngữ mẹ đẻ và ngôn ngữ bạn muốn học.';

  @override
  String get onboardingNativeLanguage => 'Ngôn ngữ mẹ đẻ (Source):';

  @override
  String get onboardingTargetLanguage => 'Ngôn ngữ muốn học (Target):';

  @override
  String get getStarted => 'Bắt đầu ngay';

  @override
  String get languageConfiguration => 'Cấu hình Ngôn ngữ (Source & Target)';

  @override
  String get nativeLanguageSource => 'Ngôn ngữ mẹ đẻ (Source):';

  @override
  String get learningLanguageTarget => 'Ngôn ngữ học (Target):';

  @override
  String get aiLlmSettingsTitle => 'Cấu hình AI / LLM (Gemini)';

  @override
  String get enableAiExplanation => 'Bật giải thích AI';

  @override
  String get useGenuiInterface => 'Sử dụng giao diện GenUI';

  @override
  String get enterGeminiApiKeyHint => 'Nhập Gemini API Key';

  @override
  String get geminiApiKeyLabel => 'Gemini API Key:';

  @override
  String get llmModelNameLabel => 'Tên Model (Gemini):';

  @override
  String get enterApiKeyFirst => 'Vui lòng nhập API Key trước.';

  @override
  String get fetchFromApi => 'Tải từ API';

  @override
  String get selectModel => 'Chọn Model';

  @override
  String get pressFetchToLoadList => 'Nhấn \"Tải từ API\" để lấy danh sách';

  @override
  String get customPromptTemplateLabel =>
      'Mẫu Prompt (Custom for text-based output):';

  @override
  String get resetToDefault => 'Đặt lại mặc định';

  @override
  String get customPromptHint =>
      'Sử dụng %search_words% để thay thế từ tra cứu';

  @override
  String get accountCloudSync => 'Tài khoản & Đồng bộ đám mây';

  @override
  String get accountGuest => 'Khách (Ẩn danh)';

  @override
  String get accountActive => 'Tài khoản đám mây đang hoạt động';

  @override
  String emailLabel(String email) {
    return 'Email: $email';
  }

  @override
  String get createAccountSync => 'Tạo tài khoản & Đồng bộ';

  @override
  String get signOut => 'Đăng xuất';

  @override
  String get signinExistingAccount => 'Đăng nhập tài khoản có sẵn';

  @override
  String get switchAccount => 'Đổi tài khoản';

  @override
  String get syncNow => 'Đồng bộ ngay';

  @override
  String get cloudSyncSuccess =>
      'Đồng bộ đám mây thành công! Dữ liệu đã được đẩy & kéo.';

  @override
  String syncFailed(String error) {
    return 'Đồng bộ thất bại: $error';
  }

  @override
  String get linkAccountSync => 'Liên kết tài khoản & Đồng bộ';

  @override
  String get signIn => 'Đăng nhập';

  @override
  String get enterEmailPassword => 'Vui lòng nhập email và mật khẩu';

  @override
  String get linkWithGoogle => 'Liên kết với Google';

  @override
  String get continueWithGoogle => 'Tiếp tục với Google';

  @override
  String get emailAddress => 'Địa chỉ Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get linkingEmailHint =>
      'Email mới sẽ tạo tài khoản mới · Email có sẵn sẽ đăng nhập';

  @override
  String get linkWithEmail => 'Liên kết bằng Email';

  @override
  String get signinWithEmail => 'Đăng nhập bằng Email';

  @override
  String get cancel => 'Hủy';

  @override
  String get regenerate => 'Tạo lại';

  @override
  String get save => 'Lưu';

  @override
  String get addToReview => 'Thêm vào ôn tập';

  @override
  String get aiExplanation => 'Giải thích AI';

  @override
  String get geminiKeyNotSet => 'Chưa cấu hình Gemini API Key.';

  @override
  String get configureGeminiKeyDesc =>
      'Vui lòng truy cập Cài đặt để thêm Gemini API Key cá nhân của bạn.';

  @override
  String get openSettings => 'Mở Cài đặt';

  @override
  String get aiConnectionError => 'Đã xảy ra lỗi khi kết nối AI:';

  @override
  String get noOutputReceived => 'Không có câu trả lời.';

  @override
  String get analyzingQuery => 'Đang phân tích từ vựng...';

  @override
  String aiExplanationTitle(String query) {
    return '✨   AI Giải thích: \"$query\"';
  }

  @override
  String get openFullAiPage => 'Mở trang AI đầy đủ';

  @override
  String get retry => 'Thử lại';

  @override
  String get copy => 'Sao chép';

  @override
  String get copiedToClipboard => 'Đã sao chép vào bộ nhớ tạm!';

  @override
  String get aiTutorInsightsSection => 'Trợ lý AI';

  @override
  String get aiGrammarInsightsTutor => 'AI Ngữ pháp & Trợ lý';

  @override
  String get searchForWordHint => 'Tra cứu từ vựng';

  @override
  String get searchHistoryHint => 'Tìm trong lịch sử...';

  @override
  String get clearHistory => 'Xóa lịch sử';

  @override
  String get clearHistoryConfirm =>
      'Bạn có chắc muốn xóa toàn bộ lịch sử tra cứu?';

  @override
  String get clear => 'Xóa';

  @override
  String get noHistoryMatches => 'Không tìm thấy lịch sử phù hợp.';

  @override
  String get noHistoryYet => 'Chưa có lịch sử tra cứu.';

  @override
  String get searchFavoritesHint => 'Tìm trong yêu thích...';

  @override
  String get noMatchesFound => 'Không tìm thấy kết quả.';

  @override
  String get noFavoritesYet => 'Chưa lưu từ yêu thích nào.';

  @override
  String get searchGrammarHint => 'Tìm điểm ngữ pháp';

  @override
  String get commonWordBadge => 'từ phổ biến';

  @override
  String get deleteWordFromHistoryConfirm => 'Xóa từ này khỏi lịch sử?';

  @override
  String get notice => 'THÔNG BÁO';

  @override
  String get understood => 'Đã hiểu';

  @override
  String reviewSessionCompletedCount(int count) {
    return 'Đã hoàn thành $count thẻ trong phiên này!';
  }

  @override
  String get removeCardFromReview => 'Xóa thẻ này khỏi bộ ôn tập?';

  @override
  String get showAnswer => 'Hiện đáp án';

  @override
  String get srsAgain => 'Học lại';

  @override
  String get srsHard => 'Khó';

  @override
  String get srsGood => 'Tốt';

  @override
  String get srsEasy => 'Dễ';

  @override
  String get reviewBadgeNew => 'Mới';

  @override
  String get reviewBadgeLearn => 'Đang học';

  @override
  String get reviewBadgeDue => 'Đến hạn';

  @override
  String get statisticsToday => 'Thống kê hôm nay';

  @override
  String get metricTotalDue => 'Tổng đến hạn';

  @override
  String get metricRetention => 'Tỉ lệ nhớ';

  @override
  String get metricLeechDifficult => 'Thẻ khó';

  @override
  String get sevenDayForecast => 'Dự báo 7 ngày';

  @override
  String get dueNew => 'Mới';

  @override
  String get dueYoung => 'Non';

  @override
  String get dueMature => 'Chín';

  @override
  String get dueDifficult => 'Khó';

  @override
  String get reviewActivity4weeks => 'Hoạt động ôn tập (4 tuần qua)';

  @override
  String reviewsCountTooltip(String date, int count) {
    return '$date: $count lượt ôn';
  }

  @override
  String get less => 'Ít';

  @override
  String get more => 'Nhiều';

  @override
  String get noForecastData => 'Chưa có dữ liệu dự báo.';

  @override
  String cardsDueToday(int count) {
    return 'Hôm nay có $count thẻ đến hạn.';
  }

  @override
  String get aiTutorAnalyzing => 'Trợ lý AI đang phân tích ghi chú từ vựng...';

  @override
  String get aiTutorLoadFailed => 'Không tải được nhận xét của Trợ lý AI';

  @override
  String get aiTutorInsightsTitle => 'Trợ lý AI';

  @override
  String get noAiTutorInsights => 'Chưa có nhận xét nào.';

  @override
  String get noMemoryTip => 'Chưa có mẹo ghi nhớ.';

  @override
  String get memoryTipTitle => 'Mẹo ghi nhớ';

  @override
  String get noGrammarBreakdown => 'Chưa có phân tích ngữ pháp.';

  @override
  String get grammarBreakdownTitle => 'Phân tích ngữ pháp & cấu trúc';

  @override
  String get askAiTutor => 'Hỏi Trợ lý AI';

  @override
  String get aiGeneratingInsights => 'AI đang tạo nhận xét...';

  @override
  String aiTutorChatTitle(String word) {
    return 'Trò chuyện AI: $word';
  }

  @override
  String chatErrorPrefix(String message) {
    return 'Lỗi: $message';
  }

  @override
  String get aiSuggestionNuance => 'Giải thích sắc thái & cách dùng';

  @override
  String get aiSuggestionExamples => 'Cho 3 ví dụ hội thoại';

  @override
  String get aiSuggestionMnemonic => 'Mẹo ghi nhớ từ vựng';

  @override
  String get aiSuggestionEtymology => 'Nguồn gốc từ & từ vay mượn';

  @override
  String get askAiTutorHint => 'Hỏi Trợ lý AI về từ này...';

  @override
  String get cardInfo => 'Thông tin thẻ';

  @override
  String get cardInfoWord => 'Từ';

  @override
  String get cardInfoDeck => 'Bộ thẻ';

  @override
  String get cardInfoStage => 'Giai đoạn';

  @override
  String get cardInfoAdded => 'Đã thêm';

  @override
  String get cardInfoFirstReview => 'Ôn lần đầu';

  @override
  String get cardInfoLatestReview => 'Ôn gần nhất';

  @override
  String get cardInfoDue => 'Đến hạn';

  @override
  String get cardInfoInterval => 'Khoảng cách';

  @override
  String get cardInfoEaseFactor => 'Hệ số Ease';

  @override
  String get cardInfoReviews => 'Lượt ôn';

  @override
  String get cardInfoLapses => 'Lượt quên';

  @override
  String get notAvailable => 'Không có';

  @override
  String get cardStageNew => 'Mới';
}
