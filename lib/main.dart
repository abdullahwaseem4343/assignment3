import 'package:flutter/material.dart'; // Importing the Flutter material design package
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Importing the sqflite_ffi package for SQLite database operations
import 'createmealplan.dart'; // Importing a custom widget for creating meal plans
import 'foods.dart'; // Importing a custom widget related to food items
import 'mealplan.dart'; // Importing a custom widget for meal plan management
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi; // Importing sqflite_ffi with an alias

// Main function to run the Flutter application
void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensuring that Flutter bindings are initialized before running the app
  sqfliteFfiInit(); // Initializing sqflite for Flutter desktop apps
  
  databaseFactory = databaseFactoryFfi; // Setting the database factory to the ffi version for SQLite

  runApp(const CalorieCalculatorApp()); // Running the Calorie Calculator App
}

// A stateless widget for the main application
class CalorieCalculatorApp extends StatelessWidget {
  const CalorieCalculatorApp({super.key}); // Constructor with an optional key

  @override
  Widget build(BuildContext context) {
    // Building the MaterialApp with a title, theme, and home screen
    return MaterialApp(
      title: 'Calorie Calculator', // Title of the application
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity, // Setting the visual density to adapt to the platform
      ),
      home: const MainScreen(), // Setting the home screen to MainScreen widget
    );
  }
}

// A StatefulWidget for the main screen of the application
class MainScreen extends StatefulWidget {
  const MainScreen({super.key}); // Constructor with an optional key

  @override
  _MainScreenState createState() => _MainScreenState(); // Creating the state for this widget
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Variable to keep track of the current index for navigation
  final List<Widget> _screens = [
    const FoodCaloriePairPage(), // Widget for the food calorie page
    const CreateMealPlanPage(), // Widget for creating a meal plan
    const ViewMealPlanPage(), // Widget for viewing meal plans
  ];

  @override
  Widget build(BuildContext context) {
    // Building the UI for the main screen with an AppBar and BottomNavigationBar
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Tracker'), // App bar title
      ),
      body: _screens[_currentIndex], // Displaying the currently selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Setting the current index
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Updating the current index on tap
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Foods', // Navigation item for Foods
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Create Meal Plan', // Navigation item for Creating Meal Plan
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: 'Meal Plans', // Navigation item for Meal Plans
          ),
        ],
      ),
    );
  }
}
