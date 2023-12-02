import 'package:path/path.dart'; // Importing a library for path manipulation
import 'package:sqflite/sqflite.dart'; // Importing the sqflite package for SQLite database functionality

// A class to assist with database operations
class DatabaseHelper {
  static Database? _database; // Singleton instance of the database
  static const String dbName = 'food_calories.db'; // Name of the database file
  static const String tableFoodCalories = 'food_calories'; // Name of the table for food calories
  static const String tableMealPlans = 'meal_plans'; // Name of the table for meal plans

  // Getter for the database, initializes it if it's not already initialized
  Future<Database> get database async {
    if (_database != null) return _database!; // Return the existing database if it's already created

    _database = await initDatabase(); // Initialize the database if it's null
    return _database!;
  }

  // Method to initialize the database
  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), dbName); // Setting the path for the database
    return await openDatabase(
      path,
      version: 4, // Database version
      onCreate: _onCreate, // Function to call when creating the database
      onUpgrade: _onUpgrade, // Function to call when upgrading the database
    );
  }

  // Function to create tables when the database is created
  Future _onCreate(Database db, int version) async {
    // Creating the food_calories table
    await db.execute('''
      CREATE TABLE $tableFoodCalories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        food TEXT,
        calories INTEGER
      )
    ''');

    // Inserting some preset foods into the food_calories table
    List<Map<String, dynamic>> presetFoods = [
      // List of preset food items with their calorie counts
      // ...
    ];

    for (var food in presetFoods) {
      await db.insert(tableFoodCalories, food); // Inserting each preset food into the table
    }

    // Creating the meal_plans table
    await db.execute('''
      CREATE TABLE $tableMealPlans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        targetCalories INTEGER,
        foodItems TEXT
      )
    ''');
  }

  // Function to handle database upgrades
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Creating the meal_plans table if the old version is less than 2
      await db.execute('''
        CREATE TABLE $tableMealPlans (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT,
          targetCalories INTEGER,
          foodItems TEXT
        )
      ''');
    }
  }

  // Method to get all food calorie pairs from the database
  Future<List<Map<String, dynamic>>> getFoodCalories() async {
    final db = await database;
    return await db.query(tableFoodCalories); // Querying the food_calories table
  }

  // Method to add a new food calorie pair to the database
  Future<void> addFoodCaloriePair(String food, int calories) async {
    final db = await database;
    await db.insert(
      tableFoodCalories,
      {'food': food, 'calories': calories},
      conflictAlgorithm: ConflictAlgorithm.replace, // Handling conflicts by replacing the existing record
    );
  }

  // Method to update a food calorie pair in the database
  Future<void> updateFoodCaloriePair(int id, String food, int calories) async {
    final db = await database;
    await db.update(
      tableFoodCalories,
      {'food': food, 'calories': calories},
      where: 'id = ?', // Updating the record where the id matches
      whereArgs: [id],
    );
  }

  // Method to delete a food calorie pair from the database
  Future<void> deleteFoodPair(int id) async {
    final db = await database;
    await db.delete(
      tableFoodCalories,
      where: 'id = ?', // Deleting the record where the id matches
      whereArgs: [id],
    );
  }

  // Method to add a new meal plan to the database
  Future<void> addMealPlan(DateTime date, int targetCalories, String foodItemsJson) async {
    final db = await database;
    await db.insert(
      tableMealPlans,
      {
        'date': date.toIso8601String(),
        'targetCalories': targetCalories,
        'foodItems': foodItemsJson
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Handling conflicts by replacing the existing record
    );
  }

  // Method to get all meal plans from the database
  Future<List<Map<String, dynamic>>> getMealPlans() async {
    final db = await database;
    return await db.query(tableMealPlans); // Querying the meal_plans table
  }

  // Method to delete a meal plan from the database
  Future<void> deleteMealPlan(int id) async {
    final db = await database;
    await db.delete(
      tableMealPlans,
      where: 'id = ?', // Deleting the record where the id matches
      whereArgs: [id],
    );
  }

  // Method to update a meal plan in the database
  Future<void> updateMealPlan(int id, DateTime date, int targetCalories, String foodItemsJson) async {
    final db = await database;
    await db.update(
      tableMealPlans,
      {
        'date': date.toIso8601String(),
        'targetCalories': targetCalories,
        'foodItems': foodItemsJson
      },
      where: 'id = ?', // Updating the record where the id matches
      whereArgs: [id],
    );
  }

  // Method to print the contents of the database for debugging purposes
  Future<void> debugPrintDatabaseContents() async {
    final db = await database;
    final resultFoodCalories = await db.query(tableFoodCalories); // Querying the food_calories table
    final resultMealPlans = await db.query(tableMealPlans); // Querying the meal_plans table
    print('Food Calorie Table: $resultFoodCalories');
    print('Meal Plans Table: $resultMealPlans');
  }

  // Method to clear the database
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete(tableFoodCalories); // Deleting all records from the food_calories table
    await db.delete(tableMealPlans); // Deleting all records from the meal_plans table
  }

  // Method to reset and initialize the database
  void resetAndInitializeDatabase() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.clearDatabase(); // Clearing the database
    await dbHelper.initDatabase(); // Initializing the database
    print('Database reset and initialized.'); // Printing a message to indicate completion
  }

}
