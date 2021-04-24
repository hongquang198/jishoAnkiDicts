import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
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
    final Future<Database> database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), '$dbName.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE history(id INTEGER PRIMARY KEY, slug TEXT, is_common INTEGER, tags TEXT, jlpt TEXT, word TEXT, reading TEXT, senses TEXT, vietnamese_definition TEXT)",
        );
        db.execute(
          "CREATE TABLE favorite(id INTEGER PRIMARY KEY, slug TEXT, is_common INTEGER, tags TEXT, jlpt TEXT, word TEXT, reading TEXT, senses TEXT, vietnamese_definition TEXT)",
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

  Future<void> insertKanjiDictionary(Kanji kanji) async {
    final Database db = await initDatabase();
    await db.insert(
      'kanjiDictionary',
      kanji.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertJpvnDictionary(
      VietnameseDefinition vietnameseDefinition) async {
    final Database db = await initDatabase();
    await db.insert(
      'jpvnDictionary',
      vietnameseDefinition.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertExampleDictionary(ExampleSentence exampleSentence) async {
    final Database db = await initDatabase();
    await db.insert(
      'exampleDictionary',
      exampleSentence.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertWord(
      {OfflineWordRecord offlineWordRecord, String tableName}) async {
    // Get a reference to the database.
    final Database db = await initDatabase();

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
    // Get a reference to the database.
    final Database db = await initDatabase();
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('$tableName');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return OfflineWordRecord(
        id: maps[i]['id'],
        slug: maps[i]['slug'],
        is_common: maps[i]['is_common'],
        tags: maps[i]['tags'],
        jlpt: maps[i]['jlpt'],
        word: maps[i]['word'],
        reading: maps[i]['reading'],
        senses: maps[i]['senses'],
        vietnamese_definition: maps[i]['vietnamese_definition'],
      );
    });
  }

  Future<List<VietnameseDefinition>> retrieveJpvnDictionary() async {
    // Get a reference to the database.
    final Database db = await initDatabase();
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
    // Get a reference to the database.
    final Database db = await initDatabase();
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

  Future<List<ExampleSentence>> retrieveExampleDictionary() async {
    // Get a reference to the database.
    final Database db = await initDatabase();
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('exampleDictionary');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return ExampleSentence(
        jpSentence: maps[i]['jpSentence'],
        jpSentenceId: maps[i]['jpSentenceId'],
        vnSentence: maps[i]['vnSentence'],
        vnSentenceId: maps[i]['vnSentenceId'],
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
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [offlineWordRecord.id],
    );
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

  // var fido = Dog(
  //   id: 0,
  //   name: 'Fido',
  //   age: 35,
  // );

  // Insert a dog into the database.
  // await insertDog(fido);

  // Print the list of dogs (only Fido for now).
  // print(await dogs());

  // Update Fido's age and save it to the database.
  // fido = Dog(
  //   id: fido.id,
  //   name: fido.name,
  //   age: fido.age + 7,
  // );
  // await updateDog(fido);

  // Print Fido's updated information.
  // print(await dogs());

  // Delete Fido from the database.
  // await deleteDog(fido.id);

  // Print the list of dogs (empty).
  // print(await dogs());
}

class OfflineWordRecord {
  int id;
  String slug; //
  int is_common; //
  String tags; //
  String jlpt; //
  String word; //
  String reading; //
  String senses; //
  String vietnamese_definition; //

  OfflineWordRecord({
    this.id,
    this.slug,
    this.is_common,
    this.tags,
    this.jlpt,
    this.word,
    this.reading,
    this.senses,
    this.vietnamese_definition,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'slug': slug,
      'is_common': is_common,
      'tags': tags,
      'jlpt': jlpt,
      'word': word,
      'reading': reading,
      'senses': senses,
      'vietnamese_definition': vietnamese_definition,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'OfflineWordRecord{slug: $slug, is_common: $is_common, tags: $tags, '
        'jlpt: $jlpt, word: $word, reading: $reading, senses: $senses,'
        'vietnamese_definition: $vietnamese_definition}';
  }
}
