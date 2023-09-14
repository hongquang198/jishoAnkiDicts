class Kanji {
  final String? id;
  final String? keyword;
  final String? hanViet;
  final String? kanji;
  final String? constituent;
  final String? strokeCount;
  final String? lessonNo;
  final String? heisigStory;
  final String? heisigComment;
  final String? koohiiStory1;
  final String? koohiiStory2;
  final String? jouYou;
  final String? jlpt;
  final String? onYomi;
  final String? kunYomi;
  final String? readingExamples;

  Kanji(
      {this.id = '',
      this.keyword = '',
      this.hanViet = '',
      this.kanji = '',
      this.constituent = '',
      this.strokeCount = '',
      this.lessonNo = '',
      this.heisigStory = '',
      this.heisigComment = '',
      this.koohiiStory1 = '',
      this.koohiiStory2 = '',
      this.jouYou = '',
      this.jlpt = '',
      this.onYomi = '',
      this.kunYomi = '',
      this.readingExamples = ''});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'keyword': keyword,
      'hanViet': hanViet,
      'kanji': kanji,
      'constituent': constituent,
      'strokeCount': strokeCount,
      'lessonNo': lessonNo,
      'heisigStory': heisigStory,
      'heisigComment': heisigComment,
      'koohiiStory1': koohiiStory1,
      'koohiiStory2': koohiiStory2,
      'jouYou': jouYou,
      'jlpt': jlpt,
      'onYomi': onYomi,
      'kunYomi': kunYomi,
      'readingExamples': readingExamples,
    };
  }
}
