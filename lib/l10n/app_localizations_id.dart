// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get helloWorld => 'Halo!';

  @override
  String get lookUp => 'Cari';

  @override
  String get history => 'Riwayat';

  @override
  String get favorite => 'Favorit';

  @override
  String get review => 'Ulasan';

  @override
  String get settings => 'Pengaturan';

  @override
  String get examples => 'Contoh';

  @override
  String get components => 'Komponen';

  @override
  String get enableFloating => 'Aktifkan aplikasi mengambang';

  @override
  String get language => 'Bahasa';

  @override
  String get reviewComplete => 'Kamu telah menyelesaikan ulasan.';

  @override
  String get appTitle => 'Kamus JishoAnki';

  @override
  String get newCardsPerDay => 'Kartu baru per hari';

  @override
  String get graduatingInterval => 'Interval kelulusan (hari)';

  @override
  String get graduatingIntervalDescription =>
      'Kartu yang baru dipelajari akan memiliki interval ini (hari)';

  @override
  String get startingEase => 'Kemudahan awal';

  @override
  String get startingEaseDescription =>
      'Rasio yang menentukan interval berikutnya (interval baru = interval lama × rasio ini)';

  @override
  String get lapsesSteps => 'Langkah kelupaan';

  @override
  String get lapsesStepsDescription =>
      'Saat kartu lulus dilupakan, ia akan memiliki interval ini';

  @override
  String get leechThreshold => 'Ambang leech (kali)';

  @override
  String get leechThresholdDescription =>
      'Jumlah kartu lulus dilupakan. Jika tercapai, kartu dihapus dan dipindah ke Favorit';

  @override
  String get newCardsStep => 'Langkah kartu baru';

  @override
  String get newCardsStepDescription =>
      'Kartu baru akan melewati interval ini sebelum lulus.';

  @override
  String get sentenceTranslate => 'Terjemahan kalimat';

  @override
  String get statistics => 'Statistik';

  @override
  String get exampleNumber => 'Jumlah contoh maksimal';

  @override
  String get grammar => 'Tata bahasa';

  @override
  String get darkMode => 'Mode gelap';

  @override
  String get view => 'Lihat';

  @override
  String get views => 'tayangan';

  @override
  String get unknownError => 'Kesalahan tak dikenal';

  @override
  String get tokenExpiredMessage => 'Sesi kedaluwarsa';

  @override
  String get invalidRequest => 'Permintaan tidak valid';

  @override
  String get unauthorised => 'Tidak diotorisasi';

  @override
  String get fetchDataError => 'Gagal memuat data';

  @override
  String get connectionError => 'Kesalahan koneksi';

  @override
  String get menu => 'Menu';

  @override
  String get selectLanguages => 'Pilih Bahasa';

  @override
  String get welcomeJishoAnki => 'Selamat datang di Jisho Anki!';

  @override
  String get selectNativeTargetDesc =>
      'Silakan pilih bahasa ibumu dan bahasa yang ingin dipelajari.';

  @override
  String get onboardingNativeLanguage => 'Bahasa ibu (Sumber):';

  @override
  String get onboardingTargetLanguage => 'Bahasa dipelajari (Target):';

  @override
  String get getStarted => 'Mulai';

  @override
  String get languageConfiguration => 'Konfigurasi Bahasa (Sumber & Target)';

  @override
  String get nativeLanguageSource => 'Bahasa ibu (Sumber):';

  @override
  String get learningLanguageTarget => 'Bahasa dipelajari (Target):';

  @override
  String get aiLlmSettingsTitle => 'Pengaturan AI / LLM (Gemini)';

  @override
  String get enableAiExplanation => 'Aktifkan penjelasan AI';

  @override
  String get useGenuiInterface => 'Gunakan antarmuka GenUI';

  @override
  String get enterGeminiApiKeyHint => 'Masukkan Gemini API Key';

  @override
  String get geminiApiKeyLabel => 'Gemini API Key:';

  @override
  String get llmModelNameLabel => 'Nama Model (Gemini):';

  @override
  String get enterApiKeyFirst => 'Masukkan API Key terlebih dahulu.';

  @override
  String get fetchFromApi => 'Muat dari API';

  @override
  String get selectModel => 'Pilih Model';

  @override
  String get pressFetchToLoadList =>
      'Tekan «Muat dari API» untuk memuat daftar';

  @override
  String get customPromptTemplateLabel => 'Template Prompt kustom (teks):';

  @override
  String get resetToDefault => 'Kembalikan default';

  @override
  String get customPromptHint => 'Gunakan %search_words% sebagai placeholder';

  @override
  String get accountCloudSync => 'Akun & Sinkron cloud';

  @override
  String get accountGuest => 'Tamu (Anonim)';

  @override
  String get accountActive => 'Akun cloud aktif';

  @override
  String emailLabel(String email) {
    return 'Email: $email';
  }

  @override
  String get createAccountSync => 'Buat Akun & Sinkron';

  @override
  String get signOut => 'Keluar';

  @override
  String get signinExistingAccount => 'Masuk ke akun yang ada';

  @override
  String get switchAccount => 'Ganti akun';

  @override
  String get syncNow => 'Sinkron sekarang';

  @override
  String get cloudSyncSuccess =>
      'Sinkron cloud berhasil! Data terkirim & diterima.';

  @override
  String syncFailed(String error) {
    return 'Sinkron gagal: $error';
  }

  @override
  String get linkAccountSync => 'Tautkan Akun & Sinkron';

  @override
  String get signIn => 'Masuk';

  @override
  String get enterEmailPassword => 'Masukkan email dan kata sandi';

  @override
  String get linkWithGoogle => 'Tautkan dengan Google';

  @override
  String get continueWithGoogle => 'Lanjutkan dengan Google';

  @override
  String get emailAddress => 'Alamat Email';

  @override
  String get password => 'Kata sandi';

  @override
  String get linkingEmailHint =>
      'Email baru membuat akun baru · Email lama langsung masuk';

  @override
  String get linkWithEmail => 'Tautkan dengan Email';

  @override
  String get signinWithEmail => 'Masuk dengan Email';

  @override
  String get cancel => 'Batal';

  @override
  String get regenerate => 'Buat ulang';

  @override
  String get save => 'Simpan';

  @override
  String get addToReview => 'Tambah ke ulasan';

  @override
  String get aiExplanation => 'Penjelasan AI';

  @override
  String get geminiKeyNotSet => 'Gemini API Key belum diatur.';

  @override
  String get configureGeminiKeyDesc =>
      'Buka Pengaturan untuk menambahkan Gemini API Key pribadimu.';

  @override
  String get openSettings => 'Buka Pengaturan';

  @override
  String get aiConnectionError => 'Terjadi kesalahan saat menghubungi AI:';

  @override
  String get noOutputReceived => 'Tidak ada jawaban.';

  @override
  String get analyzingQuery => 'Menganalisis kosakata...';

  @override
  String aiExplanationTitle(String query) {
    return '✨   Penjelasan AI: «$query»';
  }

  @override
  String get openFullAiPage => 'Buka halaman AI penuh';

  @override
  String get retry => 'Coba lagi';

  @override
  String get copy => 'Salin';

  @override
  String get copiedToClipboard => 'Disalin ke clipboard!';

  @override
  String get aiTutorInsightsSection => 'Tutor AI';

  @override
  String get aiGrammarInsightsTutor => 'Tata bahasa AI';

  @override
  String get searchForWordHint => 'Cari kata';

  @override
  String get searchHistoryHint => 'Cari riwayat...';

  @override
  String get clearHistory => 'Hapus riwayat';

  @override
  String get clearHistoryConfirm => 'Yakin ingin menghapus seluruh riwayat?';

  @override
  String get clear => 'Hapus';

  @override
  String get noHistoryMatches => 'Tidak ada riwayat yang cocok.';

  @override
  String get noHistoryYet => 'Belum ada riwayat.';

  @override
  String get searchFavoritesHint => 'Cari favorit...';

  @override
  String get noMatchesFound => 'Tidak ada hasil.';

  @override
  String get noFavoritesYet => 'Belum ada favorit tersimpan.';

  @override
  String get searchGrammarHint => 'Cari poin tata bahasa';

  @override
  String get commonWordBadge => 'kata umum';

  @override
  String get deleteWordFromHistoryConfirm => 'Hapus kata ini dari riwayat?';

  @override
  String get notice => 'PEMBERITAHUAN';

  @override
  String get understood => 'Mengerti';

  @override
  String reviewSessionCompletedCount(int count) {
    return 'Selesai $count kartu sesi ini!';
  }

  @override
  String get removeCardFromReview => 'Keluarkan kartu ini dari dek ulasan?';

  @override
  String get showAnswer => 'Tampilkan Jawaban';

  @override
  String get srsAgain => 'Lagi';

  @override
  String get srsHard => 'Sulit';

  @override
  String get srsGood => 'Bagus';

  @override
  String get srsEasy => 'Mudah';

  @override
  String get reviewBadgeNew => 'Baru';

  @override
  String get reviewBadgeLearn => 'Belajar';

  @override
  String get reviewBadgeDue => 'Jatuh tempo';

  @override
  String get statisticsToday => 'Statistik hari ini';

  @override
  String get metricTotalDue => 'Total jatuh tempo';

  @override
  String get metricRetention => 'Retensi';

  @override
  String get metricLeechDifficult => 'Kartu sulit';

  @override
  String get sevenDayForecast => 'Prakiraan 7 hari';

  @override
  String get dueNew => 'Baru';

  @override
  String get dueYoung => 'Muda';

  @override
  String get dueMature => 'Matang';

  @override
  String get dueDifficult => 'Sulit';

  @override
  String get reviewActivity4weeks => 'Aktivitas ulasan (4 minggu terakhir)';

  @override
  String reviewsCountTooltip(String date, int count) {
    return '$date: $count ulasan';
  }

  @override
  String get less => 'Sedikit';

  @override
  String get more => 'Banyak';

  @override
  String get noForecastData => 'Belum ada data prakiraan.';

  @override
  String cardsDueToday(int count) {
    return 'Ada $count kartu jatuh tempo hari ini.';
  }

  @override
  String get aiTutorAnalyzing => 'Tutor AI sedang menganalisis catatan...';

  @override
  String get aiTutorLoadFailed => 'Gagal memuat komentar AI';

  @override
  String get aiTutorInsightsTitle => 'Tutor AI';

  @override
  String get noAiTutorInsights => 'Belum ada ulasan.';

  @override
  String get noMemoryTip => 'Belum ada tips menghafal.';

  @override
  String get memoryTipTitle => 'Tips menghafal';

  @override
  String get noGrammarBreakdown => 'Belum ada analisis tata bahasa.';

  @override
  String get grammarBreakdownTitle => 'Analisis tata bahasa';

  @override
  String get askAiTutor => 'Tanya Tutor AI';

  @override
  String get aiGeneratingInsights => 'AI sedang membuat ulasan...';

  @override
  String aiTutorChatTitle(String word) {
    return 'Chat AI: $word';
  }

  @override
  String chatErrorPrefix(String message) {
    return 'Kesalahan: $message';
  }

  @override
  String get aiSuggestionNuance => 'Jelaskan nuansa & penggunaan';

  @override
  String get aiSuggestionExamples => 'Berikan 3 contoh percakapan';

  @override
  String get aiSuggestionMnemonic => 'Tips menghafal';

  @override
  String get aiSuggestionEtymology => 'Etimologi & kata serapan';

  @override
  String get askAiTutorHint => 'Tanya Tutor AI tentang kata ini...';

  @override
  String get cardInfo => 'Info Kartu';

  @override
  String get cardInfoWord => 'Kata';

  @override
  String get cardInfoDeck => 'Dek';

  @override
  String get cardInfoStage => 'Tahap';

  @override
  String get cardInfoAdded => 'Ditambahkan';

  @override
  String get cardInfoFirstReview => 'Ulasan pertama';

  @override
  String get cardInfoLatestReview => 'Ulasan terakhir';

  @override
  String get cardInfoDue => 'Jatuh tempo';

  @override
  String get cardInfoInterval => 'Interval';

  @override
  String get cardInfoEaseFactor => 'Faktor Ease';

  @override
  String get cardInfoReviews => 'Ulasan';

  @override
  String get cardInfoLapses => 'Kelupaan';

  @override
  String get notAvailable => 'Tidak ada';

  @override
  String get cardStageNew => 'Baru';
}
