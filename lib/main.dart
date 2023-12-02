import 'package:flutter/material.dart';
import 'package:path/path.dart' as path; // Use an alias to avoid conflicts
import 'package:flutter/widgets.dart';

import 'Food.dart';
import 'FoodDatabaseHelper.dart';
import 'UserDatabaseHelper.dart';
import 'second_screen.dart';

void main() {
  // Initialize FFi
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalorieTrackerScreen(),
    );
  }
}

class CalorieTrackerScreen extends StatefulWidget {
  @override
  _CalorieTrackerScreenState createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen> {
  FoodDatabaseHelper _dbHelper = FoodDatabaseHelper();
  UserDatabaseHelper _mealDbHelper = UserDatabaseHelper();


  DateTime selectedDate = DateTime.now();
  double calorieLimit = 0;
  double totalCalories = 0;
  double calories = 0;
  List<Food> foods = [];
  List<Food> addedFoods = [];
  Food selectedFood = Food(id: 0, name: "", calories: 0.0);




  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    await _dbHelper.saveFoodDataToDatabase();
    List<Food> loadedFoods = await _dbHelper.getAllFoods();
    setState(() {
      foods = loadedFoods;
      // foods.add(Food(id: 0, name: "banana", calories: 10.0));
      // foods.add(Food(id:1, name: "apple", calories: 25));
    });
    selectedFood = foods.isNotEmpty ? foods.first : Food(id: 0, name: "test", calories: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calorie Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Date:'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2023, 12),
                  lastDate: DateTime(2024, 12),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: Text('Select Date'),
            ),
            SizedBox(height: 16),
            Text('Date:' + selectedDate.toIso8601String()),
            SizedBox(height: 16),
            Text('Enter Calorie Limit:'),
            SizedBox(height: 8),
            TextFormField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  calorieLimit = double.parse(value);
                });
              },
            ),
            SizedBox(height: 16),
            Text('Select an item:'),
            SizedBox(height: 8),
            DropdownButton<Food>(
              value: selectedFood,
              hint: Text(selectedFood.name),
              onChanged: (Food? value) {
                setState(() {
                  selectedFood = value!; // Ensure the value is non-null
                  calories = selectedFood.calories;
                });
              },
              items: foods.map((Food item) {
                return DropdownMenuItem<Food>(
                  value: item,
                  child: Text(item.name),
                );
              }).toList(),
            ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: 16),
            Text('Selected Item Calories: $calories'),

            SizedBox(height: 16),
            Text('Total Calories: $totalCalories'),
            SizedBox(height: 16),
            ]),
            ElevatedButton(
              onPressed: () async {
                showResultDialog();
                List<Food> queryFoods = await _mealDbHelper.getFoods();
                for (Food food in queryFoods) {
                  print(food.name);
                  print(queryFoods.length);
                  // print(food.date);
                }
              },
              child: Text('Check Calories'),
            ),
            // Display selected foods dynamically
            SizedBox(height: 16),
            Text('Added Foods:'),
            ListView.builder(
              shrinkWrap: true,
              itemCount: addedFoods.length,
              itemBuilder: (BuildContext context, int index) {
                return Text(addedFoods[index].name);
              },
            ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                addToAddedFoods();
                calories = 59;
              },
              child: Text('Add to List'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  addedFoods.clear();
                  totalCalories = 0;
                });
              },
              child: Text('Clear Current Meal Plan'),
            ),
          ]),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
               addToMealPlan();
              },
              child: Text('Save Entry'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the second screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecondScreen()),
                );
              },
              child: Text('View or change meal plans'),
            ),
          ],
        ),
      ),
    );
  }


  void addToAddedFoods() {
    setState(() {
      addedFoods.add(selectedFood);
      totalCalories += calories;
      selectedFood = foods.first; // Reset to the first item after adding to the list
    });
  }

  void addToMealPlan() {
    setState(() {
      if(totalCalories > calorieLimit) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Meal Plan Calorie Check'),
              content: Text('Cannot save to database as the calorie amount is too high for this meal plan.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
      else {
        Future<int> insertedId;
        for (Food food in addedFoods) {
          // Add the selected food to the database
          insertedId =
              _mealDbHelper.insertFood(food, selectedDate.toIso8601String());
        }
        selectedFood = foods.first; // Reset to the first item after adding to the list
      }
      });
  }


    void showResultDialog() {
      String result;
      if (totalCalories > calorieLimit) {
        result = 'Current Meal Plan has Exceeded Calorie Limit!';
      } else {
        result = 'Current Meal Plan is under Calorie Limit. Well done!';
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Calorie Check Result'),
            content: Text(result),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
}
