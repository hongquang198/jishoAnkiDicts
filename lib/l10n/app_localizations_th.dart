// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get helloWorld => 'สวัสดี!';

  @override
  String get lookUp => 'ค้นหา';

  @override
  String get history => 'ประวัติ';

  @override
  String get favorite => 'รายการโปรด';

  @override
  String get review => 'ทบทวน';

  @override
  String get settings => 'ตั้งค่า';

  @override
  String get examples => 'ตัวอย่าง';

  @override
  String get components => 'อักษรจีน';

  @override
  String get enableFloating => 'เปิดใช้แอปลอย';

  @override
  String get language => 'ภาษา';

  @override
  String get reviewComplete => 'คุณทบทวนครบแล้ว';

  @override
  String get appTitle => 'พจนานุกรม JishoAnki';

  @override
  String get newCardsPerDay => 'การ์ดใหม่ต่อวัน';

  @override
  String get graduatingInterval => 'ช่วงเวลาจบการเรียน (วัน)';

  @override
  String get graduatingIntervalDescription =>
      'การ์ดที่เรียนใหม่จะมีช่วงเวลานี้ (วัน)';

  @override
  String get startingEase => 'ค่า ease เริ่มต้น';

  @override
  String get startingEaseDescription =>
      'อัตราที่กำหนดช่วงเวลาถัดไป (ช่วงใหม่ = ช่วงเก่า × อัตรานี้)';

  @override
  String get lapsesSteps => 'ขั้นตอนเมื่อลืม';

  @override
  String get lapsesStepsDescription =>
      'เมื่อลืมการ์ดที่จบแล้ว จะได้ช่วงเวลานี้';

  @override
  String get leechThreshold => 'เกณฑ์ leech (ครั้ง)';

  @override
  String get leechThresholdDescription =>
      'จำนวนครั้งที่ลืมการ์ด ถ้าถึงจำนวนนี้การ์ดจะถูกลบและย้ายไปรายการโปรด';

  @override
  String get newCardsStep => 'ขั้นตอนการ์ดใหม่';

  @override
  String get newCardsStepDescription =>
      'การ์ดใหม่จะผ่านช่วงเวลาเหล่านี้ก่อนจบการเรียน';

  @override
  String get sentenceTranslate => 'แปลประโยค';

  @override
  String get statistics => 'สถิติ';

  @override
  String get exampleNumber => 'จำนวนตัวอย่างสูงสุด';

  @override
  String get grammar => 'ไวยากรณ์';

  @override
  String get darkMode => 'โหมดกลางคืน';

  @override
  String get view => 'ดู';

  @override
  String get views => 'ยอดดู';

  @override
  String get unknownError => 'ข้อผิดพลาดไม่ทราบสาเหตุ';

  @override
  String get tokenExpiredMessage => 'เซสชันหมดอายุ';

  @override
  String get invalidRequest => 'คำขอไม่ถูกต้อง';

  @override
  String get unauthorised => 'ไม่ได้รับอนุญาต';

  @override
  String get fetchDataError => 'โหลดข้อมูลล้มเหลว';

  @override
  String get connectionError => 'ข้อผิดพลาดการเชื่อมต่อ';

  @override
  String get menu => 'เมนู';

  @override
  String get selectLanguages => 'เลือกภาษา';

  @override
  String get welcomeJishoAnki => 'ยินดีต้อนรับสู่ Jisho Anki!';

  @override
  String get selectNativeTargetDesc =>
      'กรุณาเลือกภาษาแม่และภาษาที่ต้องการเรียน';

  @override
  String get onboardingNativeLanguage => 'ภาษาแม่ (Source):';

  @override
  String get onboardingTargetLanguage => 'ภาษาที่เรียน (Target):';

  @override
  String get getStarted => 'เริ่มเลย';

  @override
  String get languageConfiguration => 'ตั้งค่าภาษา (Source & Target)';

  @override
  String get nativeLanguageSource => 'ภาษาแม่ (Source):';

  @override
  String get learningLanguageTarget => 'ภาษาที่เรียน (Target):';

  @override
  String get aiLlmSettingsTitle => 'ตั้งค่า AI / LLM (Gemini)';

  @override
  String get enableAiExplanation => 'เปิดคำอธิบาย AI';

  @override
  String get useGenuiInterface => 'ใช้อินเทอร์เฟซ GenUI';

  @override
  String get enterGeminiApiKeyHint => 'ป้อน Gemini API Key';

  @override
  String get geminiApiKeyLabel => 'Gemini API Key:';

  @override
  String get llmModelNameLabel => 'ชื่อโมเดล (Gemini):';

  @override
  String get enterApiKeyFirst => 'กรุณาป้อน API Key ก่อน';

  @override
  String get fetchFromApi => 'ดึงจาก API';

  @override
  String get selectModel => 'เลือกโมเดล';

  @override
  String get pressFetchToLoadList => 'กด «ดึงจาก API» เพื่อโหลดรายการ';

  @override
  String get customPromptTemplateLabel => 'เทมเพลต Prompt (ข้อความ):';

  @override
  String get resetToDefault => 'คืนค่าเริ่มต้น';

  @override
  String get customPromptHint => 'ใช้ %search_words% แทนคำค้น';

  @override
  String get accountCloudSync => 'บัญชี & ซิงก์คลาวด์';

  @override
  String get accountGuest => 'ผู้เยี่ยมชม (ไม่ระบุตัวตน)';

  @override
  String get accountActive => 'บัญชีคลาวด์ใช้งานอยู่';

  @override
  String emailLabel(String email) {
    return 'อีเมล: $email';
  }

  @override
  String get createAccountSync => 'สร้างบัญชี & ซิงก์';

  @override
  String get signOut => 'ออกจากระบบ';

  @override
  String get signinExistingAccount => 'เข้าสู่ระบบบัญชีเดิม';

  @override
  String get switchAccount => 'สลับบัญชี';

  @override
  String get syncNow => 'ซิงก์เลย';

  @override
  String get cloudSyncSuccess => 'ซิงก์คลาวด์สำเร็จ! ส่งและรับข้อมูลแล้ว';

  @override
  String syncFailed(String error) {
    return 'ซิงก์ล้มเหลว: $error';
  }

  @override
  String get linkAccountSync => 'เชื่อมบัญชี & ซิงก์';

  @override
  String get signIn => 'เข้าสู่ระบบ';

  @override
  String get enterEmailPassword => 'กรุณาป้อนอีเมลและรหัสผ่าน';

  @override
  String get linkWithGoogle => 'เชื่อมกับ Google';

  @override
  String get continueWithGoogle => 'ดำเนินการต่อด้วย Google';

  @override
  String get emailAddress => 'ที่อยู่อีเมล';

  @override
  String get password => 'รหัสผ่าน';

  @override
  String get linkingEmailHint =>
      'อีเมลใหม่สร้างบัญชีใหม่ · อีเมลเดิมเข้าสู่ระบบ';

  @override
  String get linkWithEmail => 'เชื่อมด้วยอีเมล';

  @override
  String get signinWithEmail => 'เข้าสู่ระบบด้วยอีเมล';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get regenerate => 'สร้างใหม่';

  @override
  String get save => 'บันทึก';

  @override
  String get addToReview => 'เพิ่มเข้าทบทวน';

  @override
  String get aiExplanation => 'คำอธิบาย AI';

  @override
  String get geminiKeyNotSet => 'ยังไม่ได้ตั้งค่า Gemini API Key';

  @override
  String get configureGeminiKeyDesc =>
      'ไปที่ตั้งค่าเพื่อเพิ่ม Gemini API Key ส่วนตัว';

  @override
  String get openSettings => 'เปิดตั้งค่า';

  @override
  String get aiConnectionError => 'เกิดข้อผิดพลาด khi เชื่อมต่อ AI:';

  @override
  String get noOutputReceived => 'ไม่ได้รับคำตอบ';

  @override
  String get analyzingQuery => 'กำลังวิเคราะห์คำศัพท์...';

  @override
  String aiExplanationTitle(String query) {
    return '✨   AI อธิบาย: «$query»';
  }

  @override
  String get openFullAiPage => 'เปิดหน้า AI เต็ม';

  @override
  String get retry => 'ลองใหม่';

  @override
  String get copy => 'คัดลอก';

  @override
  String get copiedToClipboard => 'คัดลอกแล้ว!';

  @override
  String get aiTutorInsightsSection => 'ผู้ช่วย AI';

  @override
  String get aiGrammarInsightsTutor => 'ไวยากรณ์ AI';

  @override
  String get searchForWordHint => 'ค้นหาคำศัพท์';

  @override
  String get searchHistoryHint => 'ค้นประวัติ...';

  @override
  String get clearHistory => 'ล้างประวัติ';

  @override
  String get clearHistoryConfirm => 'แน่ใจหรือไม่ที่จะล้างประวัติทั้งหมด?';

  @override
  String get clear => 'ล้าง';

  @override
  String get noHistoryMatches => 'ไม่พบประวัติที่ตรงกัน';

  @override
  String get noHistoryYet => 'ยังไม่มีประวัติ';

  @override
  String get searchFavoritesHint => 'ค้นรายการโปรด...';

  @override
  String get noMatchesFound => 'ไม่พบผลลัพธ์';

  @override
  String get noFavoritesYet => 'ยังไม่มีรายการโปรด';

  @override
  String get searchGrammarHint => 'ค้นหัวข้อไวยากรณ์';

  @override
  String get commonWordBadge => 'คำที่ใช้บ่อย';

  @override
  String get deleteWordFromHistoryConfirm => 'ลบคำนี้ออกจากประวัติ?';

  @override
  String get notice => 'แจ้งเตือน';

  @override
  String get understood => 'เข้าใจแล้ว';

  @override
  String reviewSessionCompletedCount(int count) {
    return 'ทำเสร็จ $count ใบในรอบนี้!';
  }

  @override
  String get removeCardFromReview => 'นำการ์ดนี้ออกจากสำรับทบทวน?';

  @override
  String get showAnswer => 'แสดงคำตอบ';

  @override
  String get srsAgain => 'อีกครั้ง';

  @override
  String get srsHard => 'ยาก';

  @override
  String get srsGood => 'ดี';

  @override
  String get srsEasy => 'ง่าย';

  @override
  String get reviewBadgeNew => 'ใหม่';

  @override
  String get reviewBadgeLearn => 'กำลังเรียน';

  @override
  String get reviewBadgeDue => 'ถึงกำหนด';

  @override
  String get statisticsToday => 'สถิติวันนี้';

  @override
  String get metricTotalDue => 'ถึงกำหนดทั้งหมด';

  @override
  String get metricRetention => 'อัตราจำได้';

  @override
  String get metricLeechDifficult => 'การ์ดยาก';

  @override
  String get sevenDayForecast => 'พยากรณ์ 7 วัน';

  @override
  String get dueNew => 'ใหม่';

  @override
  String get dueYoung => 'อ่อน';

  @override
  String get dueMature => 'แก่';

  @override
  String get dueDifficult => 'ยาก';

  @override
  String get reviewActivity4weeks => 'กิจกรรมการทบทวน (4 สัปดาห์)';

  @override
  String reviewsCountTooltip(String date, int count) {
    return '$date: ทบทวน $count ครั้ง';
  }

  @override
  String get less => 'น้อย';

  @override
  String get more => 'มาก';

  @override
  String get noForecastData => 'ไม่มีข้อมูลพยากรณ์';

  @override
  String cardsDueToday(int count) {
    return 'วันนี้มีการ์ดถึงกำหนด $count ใบ';
  }

  @override
  String get aiTutorAnalyzing => 'ผู้ช่วย AI กำลังวิเคราะห์โน้ต...';

  @override
  String get aiTutorLoadFailed => 'โหลดความเห็น AI ไม่สำเร็จ';

  @override
  String get aiTutorInsightsTitle => 'ผู้ช่วย AI';

  @override
  String get noAiTutorInsights => 'ยังไม่มีความเห็น';

  @override
  String get noMemoryTip => 'ยังไม่มีเคล็ดลับจำ';

  @override
  String get memoryTipTitle => 'เคล็ดลับจำ';

  @override
  String get noGrammarBreakdown => 'ยังไม่มีวิเคราะห์ไวยากรณ์';

  @override
  String get grammarBreakdownTitle => 'วิเคราะห์ไวยากรณ์';

  @override
  String get askAiTutor => 'ถามผู้ช่วย AI';

  @override
  String get aiGeneratingInsights => 'AI กำลังสร้างความเห็น...';

  @override
  String aiTutorChatTitle(String word) {
    return 'คุยกับ AI: $word';
  }

  @override
  String chatErrorPrefix(String message) {
    return 'ข้อผิดพลาด: $message';
  }

  @override
  String get aiSuggestionNuance => 'อธิบายความต่าง & การใช้';

  @override
  String get aiSuggestionExamples => 'ยกตัวอย่างสนทนา 3 ข้อ';

  @override
  String get aiSuggestionMnemonic => 'เคล็ดลับจำ';

  @override
  String get aiSuggestionEtymology => 'ที่มาของคำ';

  @override
  String get askAiTutorHint => 'ถามผู้ช่วย AI เกี่ยวกับคำนี้...';

  @override
  String get cardInfo => 'ข้อมูลการ์ด';

  @override
  String get cardInfoWord => 'คำ';

  @override
  String get cardInfoDeck => 'สำรับ';

  @override
  String get cardInfoStage => 'ขั้น';

  @override
  String get cardInfoAdded => 'เพิ่มเมื่อ';

  @override
  String get cardInfoFirstReview => 'ทบทวนครั้งแรก';

  @override
  String get cardInfoLatestReview => 'ทบทวนล่าสุด';

  @override
  String get cardInfoDue => 'กำหนด';

  @override
  String get cardInfoInterval => 'ช่วงเวลา';

  @override
  String get cardInfoEaseFactor => 'ค่า Ease';

  @override
  String get cardInfoReviews => 'ครั้งที่ทบทวน';

  @override
  String get cardInfoLapses => 'ครั้งที่ลืม';

  @override
  String get notAvailable => 'ไม่มี';

  @override
  String get cardStageNew => 'ใหม่';
}
