// second_screen.dart

import 'package:flutter/material.dart';
import 'Food.dart';
import 'UserDatabaseHelper.dart';
import 'dart:math';

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  DateTime selectedDate = DateTime.now();
  List<String> itemList = []; // Initial list
  UserDatabaseHelper _mealDbHelper = UserDatabaseHelper();
  String oldFood ="";
  String newFood = "";
  Random random = Random();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen'),
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
                updateMealPlanList();
              },
              child: Text('Select Date'),
            ),
            SizedBox(height: 16),
            Text('Date:' + selectedDate.toIso8601String()),
            SizedBox(height: 16),

            Text('Enter name of food to be added or to replace old name if updating:'),
            SizedBox(height: 16),
            Text('Meal Plan:'),
            Expanded(
              child: itemList.isNotEmpty
                  ? ListView.builder(
                itemCount: itemList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(itemList[index]),
                  );
                },
              )
                  : Text('No entries for the selected date.'),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              SizedBox(height: 16),
              Text('Enter new food name:'),
              // TextFormField(
              //   keyboardType: TextInputType.text,
              //   onChanged: (value) {
              //     setState(() {
              //       oldFood = value;
              //     });
              //   },
              // ),
              //     SizedBox(height: 16),
              //     Text('Enter old food name:'),
              //     SizedBox(height: 8),
              //     TextFormField(
              //       keyboardType: TextInputType.text,
              //       onChanged: (value) {
              //         setState(() {
              //           newFood = value;
              //         });
              //       },
              //     ),
        ]
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Add button logic
                    setState(() {

                    });
                  },
                  child: Text('Add'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Update button logic
                    setState(() {
                      // _mealDbHelper.insertFood(Food(id:random.nextInt(1000), name:newFood, calories
                      //     date)Food(oldFood, selectedDate);

                      
                    });
                  },
                  child: Text('Update'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                       _mealDbHelper.deleteFood(oldFood, selectedDate);
                    });
                  },
                  child: Text('Delete'),
                ),
              ],

            ),
          ],
        ),

      ),
    );
  }

  void updateMealPlanList() async {
    List<Food> mealPlanItems = await _mealDbHelper.getMealPlanByDate(selectedDate);

    setState(() {
      for(Food food in mealPlanItems){
        itemList.add(food.name);
      }
    });
  }
}
