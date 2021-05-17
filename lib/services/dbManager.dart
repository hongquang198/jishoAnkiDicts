import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:JapaneseOCR/models/offlineWordRecord.dart';
import 'package:JapaneseOCR/models/pitchAccent.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:JapaneseOCR/models/kanji.dart';
import 'package:JapaneseOCR/models/vietnamese_definition.dart';
import 'package:JapaneseOCR/models/example_sentence.dart';

class DbManager {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  final String dbName;
  DbManager({this.dbName});

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
      print("Opening existing database");
    }
// open the database
    Database db = await openDatabase(path, readOnly: false);
    return db;

    final Future<Database> database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), '$dbName.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE history(slug TEXT, is_common INTEGER, tags TEXT, jlpt TEXT, word TEXT, reading TEXT, senses TEXT, vietnamese_definition TEXT, added INTEGER, firstReview INTEGER, lastReview INTEGER, due INTEGER, interval INTEGER, ease REAL, reviews INTEGER, lapses INTEGER, averageTimeMinute REAL, totalTimeMinute REAL, cardType TEXT, noteType TEXT, deck TEXT)",
        );
        db.execute(
          "CREATE TABLE favorite(slug TEXT, is_common INTEGER, tags TEXT, jlpt TEXT, word TEXT, reading TEXT, senses TEXT, vietnamese_definition TEXT, added INTEGER, firstReview INTEGER, lastReview INTEGER, due INTEGER, interval INTEGER, ease REAL, reviews INTEGER, lapses INTEGER, averageTimeMinute REAL, totalTimeMinute REAL, cardType TEXT, noteType TEXT, deck TEXT)",
        );
        db.execute(
          "CREATE TABLE review(slug TEXT, is_common INTEGER, tags TEXT, jlpt TEXT, word TEXT, reading TEXT, senses TEXT, vietnamese_definition TEXT, added INTEGER, firstReview INTEGER, lastReview INTEGER, due INTEGER, interval INTEGER, ease REAL, reviews INTEGER, lapses INTEGER, averageTimeMinute REAL, totalTimeMinute REAL, cardType TEXT, noteType TEXT, deck TEXT)",
        );

        // Offline vietnamese dictionary covert from text file to sqlite
        db.execute(
          "CREATE TABLE jpvnDictionary(id INTEGER PRIMARY KEY, word TEXT, definition TEXT)",
        );
        print('Create jpvnDicts successfully');

        db.execute(
          "CREATE TABLE kanjiDictionary(id TEXT PRIMARY KEY, keyword TEXT, hanViet TEXT, kanji TEXT, constituent TEXT, strokeCount TEXT, lessonNo TEXT, heisigStory TEXT, heisigComment TEXT, koohiiStory1 TEXT, koohiiStory2 TEXT, jouYou TEXT, jlpt TEXT, onYomi TEXT, kunYomi TEXT, readingExamples TEXT)",
        );
        print('Create kanjiDicts successfully');
        db.execute(
          "CREATE TABLE pitchDictionary(orths_txt TEXT, hira TEXT, hz TEXT, accs_txt TEXT, patts_txt TEXT)",
        );
        print('Create pitchDicts successfully');

        db.execute(
          "CREATE TABLE exampleDictionary(jpSentenceId INTEGER PRIMARY KEY, jpSentence TEXT, vnSentenceId INTEGER, vnSentence TEXT)",
        );
        print('Create kanjiDicts successfully');
        return db;
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
    return database;
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
      {OfflineWordRecord offlineWordRecord, String tableName}) async {
    Database db = await initDatabase();
    // Insert the Dog into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same dog is inserted
    // multiple times, it replaces the previous data.
    await db.insert(
      '$tableName',
      offlineWordRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<OfflineWordRecord>> retrieve({String tableName}) async {
    Database db = await initDatabase();
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('$tableName');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return OfflineWordRecord(
        slug: maps[i]['slug'],
        is_common: maps[i]['is_common'],
        tags: maps[i]['tags'],
        jlpt: maps[i]['jlpt'],
        word: maps[i]['word'],
        reading: maps[i]['reading'],
        senses: maps[i]['senses'],
        vietnamese_definition: maps[i]['vietnamese_definition'],
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
        orths_txt: maps[i]['orths_txt'],
        hira: maps[i]['hira'],
        hz: maps[i]['hz'],
        accs_txt: maps[i]['accs_txt'],
        patts_txt: maps[i]['patts_txt'],
      );
    });
  }

  Future<List<PitchAccent>> searchForPitchAccent(
      {String word, String reading}) async {
    Database db = await initDatabase();
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('pitchDictionary',
        where: "orths_txt LIKE ? AND hira = ?",
        whereArgs: ['%$word%', reading]);
    return List.generate(maps.length, (i) {
      return PitchAccent(
        orths_txt: maps[i]['orths_txt'],
        hira: maps[i]['hira'],
        hz: maps[i]['hz'],
        accs_txt: maps[i]['accs_txt'],
        patts_txt: maps[i]['patts_txt'],
      );
    });
  }

  Future<List<Kanji>> searchForKanji({String kanji}) async {
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

  Future<List<ExampleSentence>> searchForExample(
      {String word, String tableName}) async {
    Database db = await initDatabase();
    // Query the table for all The Dogs
    final List<Map<String, dynamic>> maps = await db
        .query(tableName, where: "jpSentence LIKE ?", whereArgs: ['%$word%']);
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
  }

  Future<List<VietnameseDefinition>> searchForVnMeaning({String word}) async {
    Database db = await initDatabase();
    // Query the table for all The Dogs
    final List<Map<String, dynamic>> maps =
        await db.query('jpvnDictionary', where: "word = ?", whereArgs: [word]);
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
      {OfflineWordRecord offlineWordRecord, String tableName}) async {
    // Get a reference to the database.
    final db = await initDatabase();

    // Update the given Dog.
    await db.update(
      '$tableName',
      offlineWordRecord.toMap(),
      // Ensure that the Dog has a matching id.
      where: "slug = ? OR word = ? OR reading = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [offlineWordRecord.slug ?? offlineWordRecord.word],
    );

    print('Updated successfully');
  }

  Future<void> delete({String word, String tableName}) async {
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
