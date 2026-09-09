// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get helloWorld => '안녕하세요!';

  @override
  String get lookUp => '검색';

  @override
  String get history => '기록';

  @override
  String get favorite => '즐겨찾기';

  @override
  String get review => '복습';

  @override
  String get settings => '설정';

  @override
  String get examples => '예문';

  @override
  String get components => '한자';

  @override
  String get enableFloating => '플로팅 사전 사용';

  @override
  String get language => '언어';

  @override
  String get reviewComplete => '복습을 완료했습니다.';

  @override
  String get appTitle => 'JishoAnki 사전';

  @override
  String get newCardsPerDay => '하루 신규 카드 수';

  @override
  String get graduatingInterval => '졸업 간격 (일)';

  @override
  String get graduatingIntervalDescription => '새로 학습한 카드가 갖게 될 간격 (일)';

  @override
  String get startingEase => '초기 Ease 비율';

  @override
  String get startingEaseDescription => '다음 간격을 결정하는 비율 (다음 간격 = 이전 간격 × 이 비율)';

  @override
  String get lapsesSteps => '망각 단계';

  @override
  String get lapsesStepsDescription => '졸업한 카드를 잊었을 때의 간격';

  @override
  String get leechThreshold => 'Leech 한도 (회)';

  @override
  String get leechThresholdDescription =>
      '졸업한 카드를 잊은 횟수. 도달 시 카드는 삭제되어 즐겨찾기로 이동합니다';

  @override
  String get newCardsStep => '신규 카드 단계';

  @override
  String get newCardsStepDescription => '신규 카드는 졸업 전까지 이 간격들을 거칩니다.';

  @override
  String get sentenceTranslate => '문장 번역';

  @override
  String get statistics => '통계';

  @override
  String get exampleNumber => '예문 최대 개수';

  @override
  String get grammar => '문법';

  @override
  String get darkMode => '다크 모드';

  @override
  String get view => '보기';

  @override
  String get views => '조회수';

  @override
  String get unknownError => '알 수 없는 오류';

  @override
  String get tokenExpiredMessage => '세션이 만료되었습니다';

  @override
  String get invalidRequest => '잘못된 요청';

  @override
  String get unauthorised => '권한 없음';

  @override
  String get fetchDataError => '데이터 불러오기 오류';

  @override
  String get connectionError => '연결 오류';

  @override
  String get menu => '메뉴';

  @override
  String get selectLanguages => '언어 선택';

  @override
  String get welcomeJishoAnki => 'Jisho Anki에 오신 것을 환영합니다!';

  @override
  String get selectNativeTargetDesc => '모국어와 배우고 싶은 언어를 선택해 주세요.';

  @override
  String get onboardingNativeLanguage => '모국어 (Source):';

  @override
  String get onboardingTargetLanguage => '학습 언어 (Target):';

  @override
  String get getStarted => '시작하기';

  @override
  String get languageConfiguration => '언어 설정 (Source·Target)';

  @override
  String get nativeLanguageSource => '모국어 (Source):';

  @override
  String get learningLanguageTarget => '학습 언어 (Target):';

  @override
  String get aiLlmSettingsTitle => 'AI / LLM 설정 (Gemini)';

  @override
  String get enableAiExplanation => 'AI 설명 사용';

  @override
  String get useGenuiInterface => 'GenUI 인터페이스 사용';

  @override
  String get enterGeminiApiKeyHint => 'Gemini API 키 입력';

  @override
  String get geminiApiKeyLabel => 'Gemini API 키:';

  @override
  String get llmModelNameLabel => '모델 이름 (Gemini):';

  @override
  String get enterApiKeyFirst => '먼저 API 키를 입력해 주세요.';

  @override
  String get fetchFromApi => 'API에서 불러오기';

  @override
  String get selectModel => '모델 선택';

  @override
  String get pressFetchToLoadList => '«API에서 불러오기»를 눌러 목록 불러오기';

  @override
  String get customPromptTemplateLabel => '사용자 지정 프롬프트 (텍스트 출력용):';

  @override
  String get resetToDefault => '기본값으로';

  @override
  String get customPromptHint => '%search_words%를 검색어 자리로 사용';

  @override
  String get accountCloudSync => '계정 및 클라우드 동기화';

  @override
  String get accountGuest => '게스트 (익명)';

  @override
  String get accountActive => '클라우드 계정 활성';

  @override
  String emailLabel(String email) {
    return '이메일: $email';
  }

  @override
  String get createAccountSync => '계정 만들기 및 동기화';

  @override
  String get signOut => '로그아웃';

  @override
  String get signinExistingAccount => '기존 계정으로 로그인';

  @override
  String get switchAccount => '계정 전환';

  @override
  String get syncNow => '지금 동기화';

  @override
  String get cloudSyncSuccess => '클라우드 동기화 완료! 데이터를 주고받았습니다.';

  @override
  String syncFailed(String error) {
    return '동기화 실패: $error';
  }

  @override
  String get linkAccountSync => '계정 연결 및 동기화';

  @override
  String get signIn => '로그인';

  @override
  String get enterEmailPassword => '이메일과 비밀번호를 입력해 주세요';

  @override
  String get linkWithGoogle => 'Google과 연결';

  @override
  String get continueWithGoogle => 'Google로 계속하기';

  @override
  String get emailAddress => '이메일 주소';

  @override
  String get password => '비밀번호';

  @override
  String get linkingEmailHint => '새 이메일은 신규 가입 · 기존 이메일은 로그인됩니다';

  @override
  String get linkWithEmail => '이메일로 연결';

  @override
  String get signinWithEmail => '이메일로 로그인';

  @override
  String get cancel => '취소';

  @override
  String get regenerate => '다시 생성';

  @override
  String get save => '저장';

  @override
  String get addToReview => '복습에 추가';

  @override
  String get aiExplanation => 'AI 설명';

  @override
  String get geminiKeyNotSet => 'Gemini API 키가 설정되지 않았습니다.';

  @override
  String get configureGeminiKeyDesc => '설정에서 개인 Gemini API 키를 등록해 주세요.';

  @override
  String get openSettings => '설정 열기';

  @override
  String get aiConnectionError => 'AI 연결 중 오류 발생:';

  @override
  String get noOutputReceived => '응답이 없습니다.';

  @override
  String get analyzingQuery => '어휘 분석 중...';

  @override
  String aiExplanationTitle(String query) {
    return '✨   AI 설명: “$query”';
  }

  @override
  String get openFullAiPage => '전체 AI 페이지 열기';

  @override
  String get retry => '다시 시도';

  @override
  String get copy => '복사';

  @override
  String get copiedToClipboard => '클립보드에 복사했습니다!';

  @override
  String get aiTutorInsightsSection => 'AI 튜터';

  @override
  String get aiGrammarInsightsTutor => 'AI 문법 인사이트';

  @override
  String get searchForWordHint => '단어 검색';

  @override
  String get searchHistoryHint => '기록 검색...';

  @override
  String get clearHistory => '기록 지우기';

  @override
  String get clearHistoryConfirm => '모든 검색 기록을 지우겠습니까?';

  @override
  String get clear => '지우기';

  @override
  String get noHistoryMatches => '일치하는 기록이 없습니다.';

  @override
  String get noHistoryYet => '아직 검색 기록이 없습니다.';

  @override
  String get searchFavoritesHint => '즐겨찾기 검색...';

  @override
  String get noMatchesFound => '결과가 없습니다.';

  @override
  String get noFavoritesYet => '저장된 즐겨찾기가 없습니다.';

  @override
  String get searchGrammarHint => '문법 항목 검색';

  @override
  String get commonWordBadge => '상용 단어';

  @override
  String get deleteWordFromHistoryConfirm => '이 단어를 기록에서 삭제하겠습니까?';

  @override
  String get notice => '알림';

  @override
  String get understood => '확인';

  @override
  String reviewSessionCompletedCount(int count) {
    return '이번 세션에서 $count장 완료!';
  }

  @override
  String get removeCardFromReview => '이 카드를 복습 덱에서 제거하겠습니까?';

  @override
  String get showAnswer => '정답 보기';

  @override
  String get srsAgain => '다시';

  @override
  String get srsHard => '어려움';

  @override
  String get srsGood => '좋음';

  @override
  String get srsEasy => '쉬움';

  @override
  String get reviewBadgeNew => '신규';

  @override
  String get reviewBadgeLearn => '학습 중';

  @override
  String get reviewBadgeDue => '기한';

  @override
  String get statisticsToday => '오늘의 통계';

  @override
  String get metricTotalDue => '총 기한';

  @override
  String get metricRetention => '유지율';

  @override
  String get metricLeechDifficult => '어려운 카드';

  @override
  String get sevenDayForecast => '7일 예측';

  @override
  String get dueNew => '신규';

  @override
  String get dueYoung => '초기';

  @override
  String get dueMature => '정착';

  @override
  String get dueDifficult => '어려움';

  @override
  String get reviewActivity4weeks => '복습 활동 (지난 4주)';

  @override
  String reviewsCountTooltip(String date, int count) {
    return '$date: $count회 복습';
  }

  @override
  String get less => '적음';

  @override
  String get more => '많음';

  @override
  String get noForecastData => '예측 데이터가 없습니다.';

  @override
  String cardsDueToday(int count) {
    return '오늘 기한인 카드가 $count장 있습니다.';
  }

  @override
  String get aiTutorAnalyzing => 'AI 튜터가 단어 노트를 분석 중...';

  @override
  String get aiTutorLoadFailed => 'AI 튜터 의견을 불러오지 못했습니다';

  @override
  String get aiTutorInsightsTitle => 'AI 튜터';

  @override
  String get noAiTutorInsights => '아직 인사이트가 없습니다.';

  @override
  String get noMemoryTip => '아직 암기 팁이 없습니다.';

  @override
  String get memoryTipTitle => '암기 팁';

  @override
  String get noGrammarBreakdown => '아직 문법 분석이 없습니다.';

  @override
  String get grammarBreakdownTitle => '문법·구조 분석';

  @override
  String get askAiTutor => 'AI 튜터에게 질문';

  @override
  String get aiGeneratingInsights => 'AI가 인사이트 생성 중...';

  @override
  String aiTutorChatTitle(String word) {
    return 'AI 튜터 상담: $word';
  }

  @override
  String chatErrorPrefix(String message) {
    return '오류: $message';
  }

  @override
  String get aiSuggestionNuance => '뉘앙스와 용법 설명';

  @override
  String get aiSuggestionExamples => '회화 예문 3개 제시';

  @override
  String get aiSuggestionMnemonic => '암기 팁 알려주기';

  @override
  String get aiSuggestionEtymology => '어원과 외래어 유래';

  @override
  String get askAiTutorHint => '이 단어에 대해 질문...';

  @override
  String get cardInfo => '카드 정보';

  @override
  String get cardInfoWord => '단어';

  @override
  String get cardInfoDeck => '덱';

  @override
  String get cardInfoStage => '단계';

  @override
  String get cardInfoAdded => '추가일';

  @override
  String get cardInfoFirstReview => '첫 복습';

  @override
  String get cardInfoLatestReview => '최근 복습';

  @override
  String get cardInfoDue => '기한';

  @override
  String get cardInfoInterval => '간격';

  @override
  String get cardInfoEaseFactor => 'Ease 계수';

  @override
  String get cardInfoReviews => '복습 횟수';

  @override
  String get cardInfoLapses => '망각 횟수';

  @override
  String get notAvailable => '없음';

  @override
  String get cardStageNew => '신규';
}
