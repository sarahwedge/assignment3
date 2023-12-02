import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


import 'Food.dart';

class FoodDatabaseHelper {
  static Database? _database;
  static final _tableName = 'foods';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {

    String path = join(await getDatabasesPath(), 'food_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE $_tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            calories REAL
          )
          ''',
        );
      },
    );
  }

  Future<List<Food>> readFoodDataFromFile() async {
    List<Food> foods = [];

    try {
      String contents = await rootBundle.loadString('assets/foodData.txt');
      List<String> lines = contents.split('\n');
      int i = 1;
      for (String line in lines) {
        List<String> values = line.split(' - ');

        if (values.length == 2) {
          String name = values[0].trim();
          double calories = double.parse(values[1].trim());

          foods.add(Food(
            id: i,
            name: name,
            calories: calories,
          ));

        }
        i++;
      }
    } catch (e) {
      print('Error reading file: $e');
    }

    return foods;
  }

  Future<void> saveFoodDataToDatabase() async {
    try {
      // Read food data from the file
      List<Food> foods = await readFoodDataFromFile();

      // Initialize the database
      final Database db = await database;

      // Insert each food into the database
      for (Food food in foods) {
        await db.insert(
          _tableName,
          food.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      print('Error saving food data to database: $e');
    }
  }


  Future<void> insertFood(Food food) async {
    final Database db = await database;
    await db.insert(
      _tableName,
      food.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Food>> getAllFoods() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (index) {
      return Food.fromMap(maps[index]);
    });
  }
}
