// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get helloWorld => '你好！';

  @override
  String get lookUp => '查词';

  @override
  String get history => '历史';

  @override
  String get favorite => '收藏';

  @override
  String get review => '复习';

  @override
  String get settings => '设置';

  @override
  String get examples => '例句';

  @override
  String get components => '汉字';

  @override
  String get enableFloating => '启用悬浮查词';

  @override
  String get language => '语言';

  @override
  String get reviewComplete => '你已完成本次复习。';

  @override
  String get appTitle => 'JishoAnki 词典';

  @override
  String get newCardsPerDay => '每日新卡片数';

  @override
  String get graduatingInterval => '毕业间隔（天）';

  @override
  String get graduatingIntervalDescription => '新卡片学会后将获得此间隔（天）';

  @override
  String get startingEase => '初始简易度';

  @override
  String get startingEaseDescription => '决定下次间隔的比率（新间隔 = 旧间隔 × 此比率）';

  @override
  String get lapsesSteps => '遗忘步伐';

  @override
  String get lapsesStepsDescription => '已毕业卡片被遗忘后将获得此间隔';

  @override
  String get leechThreshold => '难记阈值（次）';

  @override
  String get leechThresholdDescription => '已毕业卡片被遗忘的次数。达到后卡片将被删除并移入收藏';

  @override
  String get newCardsStep => '新卡片步伐';

  @override
  String get newCardsStepDescription => '新卡片毕业前将依次经过这些间隔。';

  @override
  String get sentenceTranslate => '句子翻译';

  @override
  String get statistics => '统计';

  @override
  String get exampleNumber => '例句最大数量';

  @override
  String get grammar => '语法';

  @override
  String get darkMode => '深色模式';

  @override
  String get view => '查看';

  @override
  String get views => '浏览量';

  @override
  String get unknownError => '未知错误';

  @override
  String get tokenExpiredMessage => '登录已过期';

  @override
  String get invalidRequest => '无效请求';

  @override
  String get unauthorised => '未授权';

  @override
  String get fetchDataError => '数据加载失败';

  @override
  String get connectionError => '连接错误';

  @override
  String get menu => '菜单';

  @override
  String get selectLanguages => '选择语言';

  @override
  String get welcomeJishoAnki => '欢迎使用 Jisho Anki！';

  @override
  String get selectNativeTargetDesc => '请选择你的母语和想要学习的语言。';

  @override
  String get onboardingNativeLanguage => '母语（源语言）:';

  @override
  String get onboardingTargetLanguage => '学习语言（目标）:';

  @override
  String get getStarted => '开始使用';

  @override
  String get languageConfiguration => '语言配置（源语言·目标）';

  @override
  String get nativeLanguageSource => '母语（源语言）:';

  @override
  String get learningLanguageTarget => '学习语言（目标）:';

  @override
  String get aiLlmSettingsTitle => 'AI / LLM 设置（Gemini）';

  @override
  String get enableAiExplanation => '启用 AI 讲解';

  @override
  String get useGenuiInterface => '使用 GenUI 界面';

  @override
  String get enterGeminiApiKeyHint => '输入 Gemini API Key';

  @override
  String get geminiApiKeyLabel => 'Gemini API Key:';

  @override
  String get llmModelNameLabel => '模型名称（Gemini）:';

  @override
  String get enterApiKeyFirst => '请先输入 API Key。';

  @override
  String get fetchFromApi => '从 API 获取';

  @override
  String get selectModel => '选择模型';

  @override
  String get pressFetchToLoadList => '点击“从 API 获取”加载列表';

  @override
  String get customPromptTemplateLabel => '自定义提示词模板（文本输出）:';

  @override
  String get resetToDefault => '恢复默认';

  @override
  String get customPromptHint => '使用 %search_words% 作为查询占位符';

  @override
  String get accountCloudSync => '账号与云同步';

  @override
  String get accountGuest => '访客（匿名）';

  @override
  String get accountActive => '云账号已激活';

  @override
  String emailLabel(String email) {
    return '邮箱：$email';
  }

  @override
  String get createAccountSync => '创建账号并同步';

  @override
  String get signOut => '退出登录';

  @override
  String get signinExistingAccount => '登录已有账号';

  @override
  String get switchAccount => '切换账号';

  @override
  String get syncNow => '立即同步';

  @override
  String get cloudSyncSuccess => '云同步成功！数据已上传并下载。';

  @override
  String syncFailed(String error) {
    return '同步失败：$error';
  }

  @override
  String get linkAccountSync => '绑定账号并同步';

  @override
  String get signIn => '登录';

  @override
  String get enterEmailPassword => '请输入邮箱和密码';

  @override
  String get linkWithGoogle => '绑定 Google';

  @override
  String get continueWithGoogle => '使用 Google 继续';

  @override
  String get emailAddress => '邮箱地址';

  @override
  String get password => '密码';

  @override
  String get linkingEmailHint => '新邮箱将创建账号 · 已有邮箱将直接登录';

  @override
  String get linkWithEmail => '用邮箱绑定';

  @override
  String get signinWithEmail => '用邮箱登录';

  @override
  String get cancel => '取消';

  @override
  String get regenerate => '重新生成';

  @override
  String get save => '保存';

  @override
  String get addToReview => '加入复习';

  @override
  String get aiExplanation => 'AI 讲解';

  @override
  String get geminiKeyNotSet => '尚未配置 Gemini API Key。';

  @override
  String get configureGeminiKeyDesc => '请前往设置添加你的个人 Gemini API Key。';

  @override
  String get openSettings => '打开设置';

  @override
  String get aiConnectionError => '连接 AI 时出错：';

  @override
  String get noOutputReceived => '未收到回复。';

  @override
  String get analyzingQuery => '正在分析词汇...';

  @override
  String aiExplanationTitle(String query) {
    return '✨   AI 讲解：“$query”';
  }

  @override
  String get openFullAiPage => '打开完整 AI 页面';

  @override
  String get retry => '重试';

  @override
  String get copy => '复制';

  @override
  String get copiedToClipboard => '已复制到剪贴板！';

  @override
  String get aiTutorInsightsSection => 'AI 导师';

  @override
  String get aiGrammarInsightsTutor => 'AI 语法解析';

  @override
  String get searchForWordHint => '搜索单词';

  @override
  String get searchHistoryHint => '搜索历史...';

  @override
  String get clearHistory => '清空历史';

  @override
  String get clearHistoryConfirm => '确定要清空全部查询历史吗？';

  @override
  String get clear => '清空';

  @override
  String get noHistoryMatches => '没有匹配的历史记录。';

  @override
  String get noHistoryYet => '暂无查询历史。';

  @override
  String get searchFavoritesHint => '搜索收藏...';

  @override
  String get noMatchesFound => '没有找到结果。';

  @override
  String get noFavoritesYet => '还没有收藏单词。';

  @override
  String get searchGrammarHint => '搜索语法点';

  @override
  String get commonWordBadge => '常用词';

  @override
  String get deleteWordFromHistoryConfirm => '从历史中删除这个词？';

  @override
  String get notice => '通知';

  @override
  String get understood => '知道了';

  @override
  String reviewSessionCompletedCount(int count) {
    return '本次已完成 $count 张卡片！';
  }

  @override
  String get removeCardFromReview => '将这张卡片移出复习牌组？';

  @override
  String get showAnswer => '显示答案';

  @override
  String get srsAgain => '重来';

  @override
  String get srsHard => '难';

  @override
  String get srsGood => '好';

  @override
  String get srsEasy => '简单';

  @override
  String get reviewBadgeNew => '新';

  @override
  String get reviewBadgeLearn => '学习中';

  @override
  String get reviewBadgeDue => '到期';

  @override
  String get statisticsToday => '今日统计';

  @override
  String get metricTotalDue => '到期总数';

  @override
  String get metricRetention => '记忆保持率';

  @override
  String get metricLeechDifficult => '难记卡';

  @override
  String get sevenDayForecast => '7 天预测';

  @override
  String get dueNew => '新卡';

  @override
  String get dueYoung => '年轻';

  @override
  String get dueMature => '成熟';

  @override
  String get dueDifficult => '困难';

  @override
  String get reviewActivity4weeks => '复习活动（近 4 周）';

  @override
  String reviewsCountTooltip(String date, int count) {
    return '$date：复习 $count 次';
  }

  @override
  String get less => '少';

  @override
  String get more => '多';

  @override
  String get noForecastData => '暂无预测数据。';

  @override
  String cardsDueToday(int count) {
    return '今天有 $count 张卡片到期。';
  }

  @override
  String get aiTutorAnalyzing => 'AI 导师正在分析单词笔记...';

  @override
  String get aiTutorLoadFailed => 'AI 导师点评加载失败';

  @override
  String get aiTutorInsightsTitle => 'AI 导师';

  @override
  String get noAiTutorInsights => '暂无点评。';

  @override
  String get noMemoryTip => '暂无记忆技巧。';

  @override
  String get memoryTipTitle => '记忆技巧';

  @override
  String get noGrammarBreakdown => '暂无语法解析。';

  @override
  String get grammarBreakdownTitle => '语法结构解析';

  @override
  String get askAiTutor => '向 AI 导师提问';

  @override
  String get aiGeneratingInsights => 'AI 正在生成点评...';

  @override
  String aiTutorChatTitle(String word) {
    return 'AI 导师对话：$word';
  }

  @override
  String chatErrorPrefix(String message) {
    return '错误：$message';
  }

  @override
  String get aiSuggestionNuance => '讲解语义差别与用法';

  @override
  String get aiSuggestionExamples => '给出 3 个会话例句';

  @override
  String get aiSuggestionMnemonic => '讲讲记忆技巧';

  @override
  String get aiSuggestionEtymology => '词源与外来语由来';

  @override
  String get askAiTutorHint => '向 AI 导师提问这个词...';

  @override
  String get cardInfo => '卡片信息';

  @override
  String get cardInfoWord => '单词';

  @override
  String get cardInfoDeck => '牌组';

  @override
  String get cardInfoStage => '阶段';

  @override
  String get cardInfoAdded => '添加时间';

  @override
  String get cardInfoFirstReview => '首次复习';

  @override
  String get cardInfoLatestReview => '最近复习';

  @override
  String get cardInfoDue => '到期';

  @override
  String get cardInfoInterval => '间隔';

  @override
  String get cardInfoEaseFactor => '简易因子';

  @override
  String get cardInfoReviews => '复习次数';

  @override
  String get cardInfoLapses => '遗忘次数';

  @override
  String get notAvailable => '无';

  @override
  String get cardStageNew => '新卡';
}
