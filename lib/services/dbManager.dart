import 'dart:async';
import 'dart:io';
import '../models/grammarPoint.dart';
import '../models/offlineWordRecord.dart';
import '../models/pitchAccent.dart';
import '../utils/sharedPref.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/kanji.dart';
import '../models/vietnameseDefinition.dart';
import '../models/exampleSentence.dart';

class DbManager {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  final String dbName;
  DbManager({required this.dbName});

  Future<Database> initDatabase() async {
    // Open the database and store the reference.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "offlineDatabase.db");

    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");
      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data =
          await rootBundle.load(join("assets", "offlineDatabase.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      // print("Opening existing database");
    }
// open the database
    Database db = await openDatabase(path, readOnly: false);
    return db;

  }

  Future<void> batchInsertKanjiDictionary(List<Kanji> kanjiDictionary) async {
    Database db = await initDatabase();
    Batch batch = db.batch();
    kanjiDictionary.forEach((element) {
      batch.insert(
        'kanjiDictionary',
        element.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit();
  }

  Future<void> batchInsertPitchDictionary(
      List<PitchAccent> pitchDictionary) async {
    Database db = await initDatabase();
    Batch batch = db.batch();
    pitchDictionary.forEach((element) {
      batch.insert(
        'pitchDictionary',
        element.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit();
  }

  Future<void> batchInsertJpvnDictionary(
      List<VietnameseDefinition> vietnameseDict) async {
    Database db = await initDatabase();
    Batch batch = db.batch();
    vietnameseDict.forEach((element) {
      batch.insert('jpvnDictionary', element.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
    await batch.commit();
  }

  Future<void> batchInsertExampleDictionary(
      List<ExampleSentence> exampleDictionary) async {
    Database db = await initDatabase();
    Batch batch = db.batch();
    exampleDictionary.forEach((element) {
      batch.insert('exampleDictionary', element.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
    await batch.commit();
  }

  Future<void> insertWord(
      {required OfflineWordRecord offlineWordRecord, required String tableName}) async {
    Database db = await initDatabase();
    try {
      await db.insert(
        '$tableName',
        offlineWordRecord.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Added to history database');
    } catch (e) {
      print('error inserting to database: $e');
    }
  }

  Future<List<OfflineWordRecord>> retrieve({required String tableName}) async {
    Database db = await initDatabase();
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('$tableName');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return OfflineWordRecord(
        slug: maps[i]['slug'],
        isCommon: maps[i]['is_common'],
        tags: maps[i]['tags'],
        jlpt: maps[i]['jlpt'],
        word: maps[i]['word'],
        reading: maps[i]['reading'],
        senses: maps[i]['senses'],
        vietnameseDefinition: maps[i]['vietnamese_definition'],
        added: maps[i]['added'],
        firstReview: maps[i]['firstReview'],
        lastReview: maps[i]['lastReview'],
        due: maps[i]['due'],
        interval: maps[i]['interval'],
        ease: maps[i]['ease'],
        reviews: maps[i]['reviews'],
        lapses: maps[i]['lapses'],
        averageTimeMinute: maps[i]['averageTimeMinute'],
        totalTimeMinute: maps[i]['totalTimeMinute'],
        cardType: maps[i]['cardType'],
        noteType: maps[i]['noteType'],
        deck: maps[i]['deck'],
      );
    });
  }

  Future<List<VietnameseDefinition>> retrieveJpvnDictionary() async {
    Database db = await initDatabase();
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('jpvnDictionary');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return VietnameseDefinition(
        word: maps[i]['word'],
        definition: maps[i]['definition'],
      );
    });
  }

  Future<List<GrammarPoint>> retrieveJpGrammarDictionary() async {
    Database db = await initDatabase();
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps =
        await db.query('japaneseGrammar', groupBy: 'grammarPoint');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return GrammarPoint(
        enSentence: maps[i]['enSentence'],
        jpSentence: maps[i]['jpSentence'],
        jlptLevel: maps[i]['jlptLevel'],
        grammarMeaning: maps[i]['grammarMeaning'],
        grammarPoint: maps[i]['grammarPoint'],
        romanSentence: maps[i]['romanSentence'],
      );
    });
  }

  Future<List<Kanji>> retrieveKanjiDictionary() async {
    Database db = await initDatabase();
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('kanjiDictionary');
    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Kanji(
        id: maps[i]['id'],
        keyword: maps[i]['keyword'],
        hanViet: maps[i]['hanViet'],
        kanji: maps[i]['kanji'],
        constituent: maps[i]['constituent'],
        strokeCount: maps[i]['strokeCount'],
        lessonNo: maps[i]['lessonNo'],
        heisigStory: maps[i]['heisigStory'],
        heisigComment: maps[i]['heisigComment'],
        koohiiStory1: maps[i]['koohiiStory1'],
        koohiiStory2: maps[i]['koohiiStory2'],
        jouYou: maps[i]['jouYou'],
        jlpt: maps[i]['jlpt'],
        onYomi: maps[i]['onYomi'],
        kunYomi: maps[i]['kunYomi'],
        readingExamples: maps[i]['readingExamples'],
      );
    });
  }

  Future<List<PitchAccent>> retrievePitchDictionary() async {
    Database db = await initDatabase();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('pitchDictionary');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return PitchAccent(
        orthsTxt: maps[i]['orths_txt'],
        hira: maps[i]['hira'],
        hz: maps[i]['hz'],
        accsTxt: maps[i]['accs_txt'],
        pattsTxt: maps[i]['patts_txt'],
      );
    });
  }

  Future<List<PitchAccent>> searchForPitchAccent(
      {required String word, required String reading}) async {
    Database db = await initDatabase();
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('pitchDictionary',
        where: "orths_txt LIKE ? AND hira = ?",
        whereArgs: ['%$word%', reading]);
    return List.generate(maps.length, (i) {
      return PitchAccent(
        orthsTxt: maps[i]['orths_txt'],
        hira: maps[i]['hira'],
        hz: maps[i]['hz'],
        accsTxt: maps[i]['accs_txt'],
        pattsTxt: maps[i]['patts_txt'],
      );
    });
  }

  Future<List<Kanji>> searchForKanji({required String kanji}) async {
    Database db = await initDatabase();
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db
        .query('kanjiDictionary', where: "kanji = ?", whereArgs: [kanji]);
    return List.generate(maps.length, (i) {
      return Kanji(
        id: maps[i]['id'],
        keyword: maps[i]['keyword'],
        hanViet: maps[i]['hanViet'],
        kanji: maps[i]['kanji'],
        constituent: maps[i]['constituent'],
        strokeCount: maps[i]['strokeCount'],
        lessonNo: maps[i]['lessonNo'],
        heisigStory: maps[i]['heisigStory'],
        heisigComment: maps[i]['heisigComment'],
        koohiiStory1: maps[i]['koohiiStory1'],
        koohiiStory2: maps[i]['koohiiStory2'],
        jouYou: maps[i]['jouYou'],
        jlpt: maps[i]['jlpt'],
        onYomi: maps[i]['onYomi'],
        kunYomi: maps[i]['kunYomi'],
        readingExamples: maps[i]['readingExamples'],
      );
    });
  }

  // ignore: missing_return
  Future<List<ExampleSentence>> searchForExample(
      {required String word, required String tableName}) async {
    Database db = await initDatabase();
    // Query the table for all The Dogs
    final List<Map<String, dynamic>> maps = await db.query(tableName,
        where: "jpSentence LIKE ?",
        whereArgs: ['%$word%'],
        limit: SharedPref.prefs.getInt('exampleNumber') ?? 3);
    if (tableName == 'exampleDictionary') {
      return List.generate(maps.length, (i) {
        return ExampleSentence(
          jpSentenceId: maps[i]['jpSentenceId'].toString(),
          targetSentenceId: maps[i]['vnSentenceId'].toString(),
          jpSentence: maps[i]['jpSentence'],
          targetSentence: maps[i]['vnSentence'],
        );
      });
    } else if (tableName == 'englishExampleDictionary') {
      return List.generate(maps.length, (i) {
        return ExampleSentence(
          jpSentenceId: maps[i]['jpSentenceId'].toString(),
          targetSentenceId: maps[i]['enSentenceId'].toString(),
          jpSentence: maps[i]['jpSentence'],
          targetSentence: maps[i]['enSentence'],
        );
      });
    }
    return [];
  }

  Future<List<ExampleSentence>> searchForGrammarExample(
      {required String grammarPoint}) async {
    Database db = await initDatabase();
    // Query the table for all The Dogs
    final List<Map<String, dynamic>> maps = await db.query(
      'japaneseGrammar',
      where: 'grammarPoint = ?',
      whereArgs: [grammarPoint],
    );
    return List.generate(maps.length, (i) {
      print(maps[i]['enSentence']);
      return ExampleSentence(
        targetSentence: maps[i]['enSentence'],
        jpSentence: maps[i]['jpSentence'],
        jpSentenceId: null,
        targetSentenceId: null,
      );
    });
  }

  Future<List<GrammarPoint>> searchForGrammar({required String grammarPoint}) async {
    Database db = await initDatabase();
    // Query the table for all The Dogs
    final List<Map<String, dynamic>> maps = await db.query('japaneseGrammar',
        where: 'grammarPoint LIKE ?',
        whereArgs: ['%$grammarPoint%'],
        groupBy: 'grammarPoint',
        orderBy: 'length(grammarPoint) ASC');
    return List.generate(maps.length, (i) {
      return GrammarPoint(
        jpSentence: maps[i]['jpSentence'],
        enSentence: maps[i]['enSentence'],
        jlptLevel: maps[i]['jlptLevel'],
        grammarMeaning: maps[i]['grammarMeaning'],
        romanSentence: maps[i]['romanSentence'],
        grammarPoint: maps[i]['grammarPoint'],
      );
    });
  }

  Future<List<VietnameseDefinition>> searchForVnMeaning({required String word}) async {
    Database db = await initDatabase();
    // Don't input limit parameter because this search function is using LIKE function
    final List<Map<String, dynamic>> maps = await db.query('jpvnDictionary',
        where: "word LIKE ?",
        whereArgs: ['%$word%'],
        orderBy: 'length(word) ASC');
    return List.generate(maps.length, (i) {
      return VietnameseDefinition(
        word: maps[i]['word'],
        definition: maps[i]['definition'],
      );
    });
  }

  Future<List<ExampleSentence>> retrieveExampleDictionary() async {
    Database db = await initDatabase();
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('exampleDictionary');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return ExampleSentence(
        jpSentence: maps[i]['jpSentence'],
        jpSentenceId: maps[i]['jpSentenceId'].toString(),
        targetSentence: maps[i]['vnSentence'],
        targetSentenceId: maps[i]['vnSentenceId'].toString(),
      );
    });
  }

  Future<void> update(
      {required OfflineWordRecord offlineWordRecord, required String tableName}) async {
    // Get a reference to the database.
    final db = await initDatabase();
    try {
      await db.update(
        '$tableName',
        offlineWordRecord.toMap(),
        // Ensure that the Dog has a matching id.
        where: "slug = ? OR word = ? OR reading = ?",
        // Pass the Dog's id as a whereArg to prevent SQL injection.
        whereArgs: [
          offlineWordRecord.slug.isEmpty
              ? offlineWordRecord.word
              : offlineWordRecord.slug
        ],
      );
      print('Updated successfully');
    } catch (e) {
      print('Error updating to database: $e');
    }
  }

  Future<void> delete({required String word, required String tableName}) async {
    // Get a reference to the database.
    final db = await initDatabase();

    // Remove the Dog from the database.
    await db.delete(
      '$tableName',
      // Use a `where` clause to delete a specific dog.
      where: "slug = ? OR word = ? OR reading = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [word],
    );
  }
}
