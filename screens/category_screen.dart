import 'package:flutter/material.dart';
import 'task_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {"name": "Work", "icon": Icons.work},
    {"name": "Study", "icon": Icons.school},
    {"name": "Personal", "icon": Icons.person},
    {"name": "Finance", "icon": Icons.attach_money},
    {"name": "Home", "icon": Icons.home},
    {"name": "Health", "icon": Icons.favorite},
    {"name": "Important", "icon": Icons.priority_high},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Task Categories"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                categories[index]["icon"],
                color: Colors.teal,
                size: 28,
              ),
              title: Text(
                categories[index]["name"],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskScreen(
                      categoryName: categories[index]["name"],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}