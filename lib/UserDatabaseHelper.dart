import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'Food.dart';

class UserDatabaseHelper {
  static Database? _database;
  static final _tableName = 'mealPlans';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_database.db');

    return await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $_tableName(id INTEGER PRIMARY KEY, name TEXT, calories REAL, date TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<int> insertFood(Food food, String date) async {
    final Database db = await database;
    Map<String, dynamic> foodMap = food.toMap();
    foodMap['date'] = date; // Add the date to the food map

    int insertedId = await db.insert(
      _tableName,
      foodMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return insertedId;
  }

  Future<List<Food>> getFoods() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    return List.generate(maps.length, (i) {
      return Food.fromMap(maps[i]);
    });
  }

  Future<void> deleteFood(String name, DateTime date) async {
    final Database db = await database;
    await db.delete(
      _tableName,
      where: 'name = ? AND date = ?',
      whereArgs: [name, date.toIso8601String()],
    );
  }

  Future<List<Food>> getMealPlanByDate(DateTime date) async {
    final Database db = await database;

    // Format the DateTime to match the format stored in the 'date' column
    String formattedDate = date.toIso8601String();

    // Execute the query to get meal plan entries for the specified date
    List<Map<String, dynamic>> result = await db.query(
      'mealPlans',
      where: 'date = ?',
      whereArgs: [formattedDate],
    );

    // Convert the result into a list of Food objects
    List<Food> mealPlanEntries = result.map((map) => Food.fromMap(map)).toList();

    return mealPlanEntries;
  }
}
