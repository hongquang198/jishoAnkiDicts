// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get helloWorld => 'こんにちは！';

  @override
  String get lookUp => '調べる';

  @override
  String get history => '履歴';

  @override
  String get favorite => 'お気に入り';

  @override
  String get review => '復習';

  @override
  String get settings => '設定';

  @override
  String get examples => '例文';

  @override
  String get components => '漢字';

  @override
  String get enableFloating => 'フローティング辞書を有効にする';

  @override
  String get language => '言語';

  @override
  String get reviewComplete => '復習が完了しました。';

  @override
  String get appTitle => 'JishoAnki辞書';

  @override
  String get newCardsPerDay => '1日あたりの新規カード数';

  @override
  String get graduatingInterval => '卒業間隔（日）';

  @override
  String get graduatingIntervalDescription => '新規カードが卒業する際の間隔（日数）';

  @override
  String get startingEase => '初期イーズ率';

  @override
  String get startingEaseDescription => '次の間隔を決める比率（次回間隔＝前回間隔 × この比率）';

  @override
  String get lapsesSteps => '失念ステップ';

  @override
  String get lapsesStepsDescription => '卒業済みカードを忘れた場合の間隔';

  @override
  String get leechThreshold => 'リーチ上限（回）';

  @override
  String get leechThresholdDescription =>
      '卒業済みカードを忘れた回数。この回数に達するとカードは削除され「お気に入り」に移動します';

  @override
  String get newCardsStep => '新規カードのステップ';

  @override
  String get newCardsStepDescription => '新規カードは卒業までにこれらの間隔を進みます。';

  @override
  String get sentenceTranslate => '例文翻訳';

  @override
  String get statistics => '統計';

  @override
  String get exampleNumber => '例文の最大数';

  @override
  String get grammar => '文法';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get view => '表示';

  @override
  String get views => '閲覧数';

  @override
  String get unknownError => '不明なエラー';

  @override
  String get tokenExpiredMessage => 'トークンの有効期限が切れました';

  @override
  String get invalidRequest => '無効なリクエスト';

  @override
  String get unauthorised => '認証されていません';

  @override
  String get fetchDataError => 'データ取得エラー';

  @override
  String get connectionError => '接続エラー';

  @override
  String get menu => 'メニュー';

  @override
  String get selectLanguages => '言語を選択';

  @override
  String get welcomeJishoAnki => 'Jisho Ankiへようこそ！';

  @override
  String get selectNativeTargetDesc => '母語と学習したい言語を選んでください。';

  @override
  String get onboardingNativeLanguage => '母語（Source）:';

  @override
  String get onboardingTargetLanguage => '学習言語（Target）:';

  @override
  String get getStarted => 'はじめる';

  @override
  String get languageConfiguration => '言語設定（Source・Target）';

  @override
  String get nativeLanguageSource => '母語（Source）:';

  @override
  String get learningLanguageTarget => '学習言語（Target）:';

  @override
  String get aiLlmSettingsTitle => 'AI / LLM設定（Gemini）';

  @override
  String get enableAiExplanation => 'AI解説を有効にする';

  @override
  String get useGenuiInterface => 'GenUIインターフェースを使う';

  @override
  String get enterGeminiApiKeyHint => 'Gemini APIキーを入力';

  @override
  String get geminiApiKeyLabel => 'Gemini APIキー:';

  @override
  String get llmModelNameLabel => 'モデル名（Gemini）:';

  @override
  String get enterApiKeyFirst => '先にAPIキーを入力してください。';

  @override
  String get fetchFromApi => 'APIから取得';

  @override
  String get selectModel => 'モデルを選択';

  @override
  String get pressFetchToLoadList => '「APIから取得」を押して一覧を読み込む';

  @override
  String get customPromptTemplateLabel => 'カスタムプロンプト（テキスト出力用）:';

  @override
  String get resetToDefault => 'デフォルトに戻す';

  @override
  String get customPromptHint => '検索語の置換に %search_words% を使用';

  @override
  String get accountCloudSync => 'アカウント・クラウド同期';

  @override
  String get accountGuest => 'ゲストユーザー（匿名）';

  @override
  String get accountActive => 'クラウドアカウント有効';

  @override
  String emailLabel(String email) {
    return 'メール: $email';
  }

  @override
  String get createAccountSync => 'アカウント作成・同期';

  @override
  String get signOut => 'サインアウト';

  @override
  String get signinExistingAccount => '既存アカウントにサインイン';

  @override
  String get switchAccount => 'アカウント切替';

  @override
  String get syncNow => '今すぐ同期';

  @override
  String get cloudSyncSuccess => 'クラウド同期が完了しました！データを送受信しました。';

  @override
  String syncFailed(String error) {
    return '同期に失敗しました: $error';
  }

  @override
  String get linkAccountSync => 'アカウント連携・同期';

  @override
  String get signIn => 'サインイン';

  @override
  String get enterEmailPassword => 'メールとパスワードを入力してください';

  @override
  String get linkWithGoogle => 'Googleと連携';

  @override
  String get continueWithGoogle => 'Googleで続ける';

  @override
  String get emailAddress => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get linkingEmailHint => '新規メールは新規登録・既存メールはサインインになります';

  @override
  String get linkWithEmail => 'メールで連携';

  @override
  String get signinWithEmail => 'メールでサインイン';

  @override
  String get cancel => 'キャンセル';

  @override
  String get regenerate => '再生成';

  @override
  String get save => '保存';

  @override
  String get addToReview => '復習に追加';

  @override
  String get aiExplanation => 'AI解説';

  @override
  String get geminiKeyNotSet => 'Gemini APIキーが未設定です。';

  @override
  String get configureGeminiKeyDesc => '設定画面で個人のGemini APIキーを登録してください。';

  @override
  String get openSettings => '設定を開く';

  @override
  String get aiConnectionError => 'AI接続中にエラーが発生しました:';

  @override
  String get noOutputReceived => '応答がありませんでした。';

  @override
  String get analyzingQuery => '語彙を解析中...';

  @override
  String aiExplanationTitle(String query) {
    return '✨   AI解説: 「$query」';
  }

  @override
  String get openFullAiPage => 'AIページ全体を開く';

  @override
  String get retry => '再試行';

  @override
  String get copy => 'コピー';

  @override
  String get copiedToClipboard => 'クリップボードにコピーしました！';

  @override
  String get aiTutorInsightsSection => 'AIチューター';

  @override
  String get aiGrammarInsightsTutor => 'AI文法インサイト';

  @override
  String get searchForWordHint => '単語を検索';

  @override
  String get searchHistoryHint => '履歴を検索...';

  @override
  String get clearHistory => '履歴を消去';

  @override
  String get clearHistoryConfirm => 'すべての検索履歴を消去しますか？';

  @override
  String get clear => '消去';

  @override
  String get noHistoryMatches => '一致する履歴がありません。';

  @override
  String get noHistoryYet => '検索履歴はまだありません。';

  @override
  String get searchFavoritesHint => 'お気に入りを検索...';

  @override
  String get noMatchesFound => '一致する結果がありません。';

  @override
  String get noFavoritesYet => 'お気に入りはまだありません。';

  @override
  String get searchGrammarHint => '文法項目を検索';

  @override
  String get commonWordBadge => '常用語';

  @override
  String get deleteWordFromHistoryConfirm => 'この単語を履歴から削除しますか？';

  @override
  String get notice => 'お知らせ';

  @override
  String get understood => '了解';

  @override
  String reviewSessionCompletedCount(int count) {
    return 'このセッションで$count枚完了しました！';
  }

  @override
  String get removeCardFromReview => 'このカードを復習デッキから外しますか？';

  @override
  String get showAnswer => '答えを見る';

  @override
  String get srsAgain => 'もう一度';

  @override
  String get srsHard => '難しい';

  @override
  String get srsGood => '良い';

  @override
  String get srsEasy => '簡単';

  @override
  String get reviewBadgeNew => '新規';

  @override
  String get reviewBadgeLearn => '学習中';

  @override
  String get reviewBadgeDue => '期限';

  @override
  String get statisticsToday => '今日の統計';

  @override
  String get metricTotalDue => '期限合計';

  @override
  String get metricRetention => '定着率';

  @override
  String get metricLeechDifficult => '難関';

  @override
  String get sevenDayForecast => '7日間予測';

  @override
  String get dueNew => '新規';

  @override
  String get dueYoung => '若い';

  @override
  String get dueMature => '定着';

  @override
  String get dueDifficult => '難関';

  @override
  String get reviewActivity4weeks => '復習履歴（過去4週間）';

  @override
  String reviewsCountTooltip(String date, int count) {
    return '$date: $count件の復習';
  }

  @override
  String get less => '少ない';

  @override
  String get more => '多い';

  @override
  String get noForecastData => '予測データがありません。';

  @override
  String cardsDueToday(int count) {
    return '今日は$count枚の期限カードがあります。';
  }

  @override
  String get aiTutorAnalyzing => 'AIチューターが単語ノートを解析中...';

  @override
  String get aiTutorLoadFailed => 'AIチューターのコメントを読み込めませんでした';

  @override
  String get aiTutorInsightsTitle => 'AIチューター';

  @override
  String get noAiTutorInsights => 'インサイトはまだありません。';

  @override
  String get noMemoryTip => '記憶のコツはまだありません。';

  @override
  String get memoryTipTitle => '記憶のコツ・語呂合わせ';

  @override
  String get noGrammarBreakdown => '文法の解説はまだありません。';

  @override
  String get grammarBreakdownTitle => '文法・構造の解説';

  @override
  String get askAiTutor => 'AIチューターに質問';

  @override
  String get aiGeneratingInsights => 'AIがインサイトを生成中...';

  @override
  String aiTutorChatTitle(String word) {
    return 'AIチューター相談: $word';
  }

  @override
  String chatErrorPrefix(String message) {
    return 'エラー: $message';
  }

  @override
  String get aiSuggestionNuance => 'ニュアンスと使い方を解説';

  @override
  String get aiSuggestionExamples => '会話例を3つ挙げる';

  @override
  String get aiSuggestionMnemonic => '記憶のコツを教える';

  @override
  String get aiSuggestionEtymology => '語源・外来語の由来';

  @override
  String get askAiTutorHint => 'この単語について質問...';

  @override
  String get cardInfo => 'カード情報';

  @override
  String get cardInfoWord => '単語';

  @override
  String get cardInfoDeck => 'デッキ';

  @override
  String get cardInfoStage => '段階';

  @override
  String get cardInfoAdded => '追加日';

  @override
  String get cardInfoFirstReview => '初回復習';

  @override
  String get cardInfoLatestReview => '最新復習';

  @override
  String get cardInfoDue => '期限';

  @override
  String get cardInfoInterval => '間隔';

  @override
  String get cardInfoEaseFactor => 'イーズ係数';

  @override
  String get cardInfoReviews => '復習回数';

  @override
  String get cardInfoLapses => '失念回数';

  @override
  String get notAvailable => 'なし';

  @override
  String get cardStageNew => '新規';
}
