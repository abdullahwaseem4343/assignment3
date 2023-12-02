import 'dart:convert'; // Importing Dart's built-in library for JSON processing
import 'package:flutter/material.dart'; // Importing Flutter's material design library
import 'database_helper.dart'; // Importing a custom database helper class
import 'package:intl/intl.dart'; // Importing a package for date formatting

// A StatefulWidget class for creating a meal plan
class CreateMealPlanPage extends StatefulWidget {
  const CreateMealPlanPage({super.key}); // Constructor with an optional key

  @override
  _CreateMealPlanPageState createState() => _CreateMealPlanPageState(); // Creating the state for this widget
}

class _CreateMealPlanPageState extends State<CreateMealPlanPage> {
  final _targetCaloriesController = TextEditingController(); // Controller for the target calories input field
  DateTime _selectedDate = DateTime.now(); // Variable to store the selected date, initialized to current date
  final List<Map<String, dynamic>> _selectedFoodItems = []; // List to keep track of selected food items
  List<Map<String, dynamic>> _availableFoodItems = []; // List to store all available food items
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // Instance of DatabaseHelper for database operations

  @override
  void initState() {
    super.initState();
    _loadFoodItems(); // Load food items from the database when the widget is initialized
  }

  // Asynchronous function to load available food items from the database
  Future<void> _loadFoodItems() async {
    List<Map<String, dynamic>> fetchedData = await _databaseHelper.getFoodCalories();
    setState(() {
      _availableFoodItems = fetchedData.map((item) => {
        ...item,
        'isSelected': false, // Initialize all food items as unselected
      }).toList();
    });
  }

  // Asynchronous function to present a date picker and update the selected date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // Update the selected date
      });
    }
  }

  // Getter to calculate remaining calories by subtracting total calories of selected food from the target
  int get _remainingCalories {
    int targetCalories = int.tryParse(_targetCaloriesController.text) ?? 0;
    int currentCalories = _selectedFoodItems.fold(0, (sum, el) => sum + (el['calories'] as int));
    return targetCalories - currentCalories;
  }

  // Function to toggle the selection state of a food item
  void _toggleFoodItem(Map<String, dynamic> item) {
    setState(() {
      item['isSelected'] = !item['isSelected']; // Toggle the isSelected state
      if (item['isSelected']) {
        _selectedFoodItems.add(item); // Add to selected items if selected
      } else {
        _selectedFoodItems.removeWhere((el) => el['id'] == item['id']); // Remove from selected items if unselected
      }
    });
  }

  // Function to clear all selections
  void _clearSelection() {
    setState(() {
      _selectedFoodItems.clear(); // Clear the list of selected food items
      for (var item in _availableFoodItems) {
        item['isSelected'] = false; // Reset the selection state of all items
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Building the UI for the create meal plan page
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Meal Plan'), // App bar with title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TextField for entering target calories
            TextFormField(
              controller: _targetCaloriesController,
              decoration: const InputDecoration(
                labelText: 'Target Calories',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 20),
            // Row for displaying and selecting date
            Row(
              children: [
                Text('Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Select date'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Displaying remaining calories
            Text('Remaining Calories: $_remainingCalories'),
            const SizedBox(height: 20),
            // ListView for displaying available food items with checkboxes
            Expanded(
              child: ListView.builder(
                itemCount: _availableFoodItems.length,
                itemBuilder: (context, index) {
                  final item = _availableFoodItems[index];
                  return CheckboxListTile(
                    value: item['isSelected'],
                    title: Text(item['food']),
                    subtitle: Text('${item['calories']} calories'),
                    onChanged: (bool? newValue) {
                      _toggleFoodItem(item);
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _clearSelection,
              child: const Text('Clear Selection'),
            ),
            const SizedBox(height: 20),
            // Button to save the meal plan
            ElevatedButton(
              onPressed: _saveMealPlan,
              child: const Text('Save Meal Plan'),
            ),
          ],
        ),
      ),
    );
  }

  // Asynchronous function to save the meal plan to the database
  void _saveMealPlan() async {
    if (_selectedFoodItems.isNotEmpty && _remainingCalories >= 0) {
      String foodItemsJson = jsonEncode(_selectedFoodItems);
      await _databaseHelper.addMealPlan(_selectedDate, int.parse(_targetCaloriesController.text), foodItemsJson);
      Navigator.pop(context); // Return to the previous screen after saving the meal plan
    } else {
      // Show a snack bar if the selection is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please adjust your meal plan.")),
      );
    }
  }

  @override
  void dispose() {
    // Dispose the controller when the widget is removed from the widget tree
    _targetCaloriesController.dispose();
    super.dispose();
  }
}
