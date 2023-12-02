import 'package:flutter/material.dart'; // Importing Flutter's material design library
import 'database_helper.dart'; // Importing a custom database helper class

// A StatefulWidget class for displaying and managing food calorie pairs
class FoodCaloriePairPage extends StatefulWidget {
  const FoodCaloriePairPage({super.key}); // Constructor with an optional key

  @override
  // ignore: library_private_types_in_public_api
  _FoodCaloriePairPageState createState() => _FoodCaloriePairPageState(); // Creating the state for this widget
}

class _FoodCaloriePairPageState extends State<FoodCaloriePairPage> {
  DatabaseHelper databaseHelper = DatabaseHelper(); // Instance of the DatabaseHelper class
  late List<Map<String, dynamic>> foodCaloriePairs = []; // List to store food calorie pairs

  @override
  void initState() {
    super.initState();
    _loadFoodCaloriePairs(); // Load food calorie pairs from the database on initialization
    databaseHelper.resetAndInitializeDatabase(); // Reset and initialize the database (for debugging or setup)
    // databaseHelper.debugPrintDatabaseContents(); // Optionally print database contents for debugging
  }

  // Asynchronous function to load food calorie pairs from the database
  Future<void> _loadFoodCaloriePairs() async {
    List<Map<String, dynamic>> fetchedData = await databaseHelper.getFoodCalories();
    setState(() {
      foodCaloriePairs = fetchedData; // Update the list of food calorie pairs
    });
  }

  @override
  Widget build(BuildContext context) {
    // Building the UI for the food calorie pair page
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Calories'), // App bar with title
      ),
      body: ListView.builder(
        itemCount: foodCaloriePairs.length, // Number of items is the length of foodCaloriePairs
        itemBuilder: (context, index) {
          final foodItem = foodCaloriePairs[index]; // Get the food item at the current index
          return ListTile(
            title: Text(foodItem['food']), // Display the food name
            subtitle: Text('${foodItem['calories']} calories'), // Display the calorie count
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _deleteFoodPair(foodItem['id']); // Delete the food pair on button press
              },
            ),
            onTap: () {
              _navigateToUpdateFoodPage(foodItem); // Navigate to update food page on tap (functionality not implemented here)
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddFoodPage(); // Navigate to add food page on button press
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Asynchronous function to delete a food pair by its ID
  void _deleteFoodPair(int id) async {
    await databaseHelper.deleteFoodPair(id);
    await _loadFoodCaloriePairs(); // Reload food calorie pairs after deletion
  }

  // Function to navigate to the page for updating a food item (functionality not implemented in this code)
  void _navigateToUpdateFoodPage(Map<String, dynamic> foodItem) {}

  // Function to navigate to the page for adding a new food item
  void _navigateToAddFoodPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddFoodPage(),
      ),
    ).then((_) {
      _loadFoodCaloriePairs(); // Reload food calorie pairs after returning from the add food page
    });
  }
}

// A StatefulWidget class for adding a new food item
class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key}); // Constructor with an optional key

  @override
  _AddFoodPageState createState() => _AddFoodPageState(); // Creating the state for this widget
}

class _AddFoodPageState extends State<AddFoodPage> {
  final _formKey = GlobalKey<FormState>(); // Key for the form
  final TextEditingController _foodNameController = TextEditingController(); // Controller for food name input
  final TextEditingController _caloriesController = TextEditingController(); // Controller for calories input

  @override
  Widget build(BuildContext context) {
    // Building the UI for the add food page
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Food Information'), // App bar with title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _foodNameController,
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                ),
                validator: (value) {
                  // Validation for food name input
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a food name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  // Validation for calories input
                  if (value?.isEmpty ?? true) {
                    return 'Please enter the calories';
                  }
                  if (int.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Save the food item if the form is valid
                  if (_formKey.currentState?.validate() ?? false) {
                    _saveFoodItem();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Asynchronous function to save the new food item to the database
  void _saveFoodItem() async {
    String? foodName = _foodNameController.text;
    int? calories = int.tryParse(_caloriesController.text);

    if (foodName != null && calories != null) {
      DatabaseHelper databaseHelper = DatabaseHelper();
      await databaseHelper.addFoodCaloriePair(foodName, calories);
      Navigator.pop(context); // Return to the previous screen after saving
    }
  }

  @override
  void dispose() {
    // Dispose the controllers when the widget is removed from the widget tree
    _foodNameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }
}
