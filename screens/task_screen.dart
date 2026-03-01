import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TaskScreen extends StatefulWidget {
  final String categoryName;

  const TaskScreen({super.key, required this.categoryName});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<Map<String, dynamic>> tasks = [];
  TextEditingController taskController = TextEditingController();
  String selectedPriority = "Medium";

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString("tasks");

    if (data != null) {
      List<Map<String, dynamic>> allTasks =
          List<Map<String, dynamic>>.from(jsonDecode(data));

      setState(() {
        tasks = allTasks
            .where((task) =>
                task["category"] == widget.categoryName)
            .toList();
      });
    }
  }

  Future<void> saveAllTasks(
      List<Map<String, dynamic>> allTasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("tasks", jsonEncode(allTasks));
  }

  void addTask() async {
    if (taskController.text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString("tasks");
    List<Map<String, dynamic>> allTasks = [];

    if (data != null) {
      allTasks =
          List<Map<String, dynamic>>.from(jsonDecode(data));
    }

    allTasks.add({
      "title": taskController.text,
      "category": widget.categoryName,
      "priority": selectedPriority,
      "completed": false,
    });

    await saveAllTasks(allTasks);
    taskController.clear();
    loadTasks();
  }

  void deleteTask(int index) async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString("tasks");
    if (data == null) return;

    List<Map<String, dynamic>> allTasks =
        List<Map<String, dynamic>>.from(jsonDecode(data));

    allTasks.removeWhere((task) =>
        task["title"] == tasks[index]["title"] &&
        task["category"] == widget.categoryName);

    await saveAllTasks(allTasks);
    loadTasks();
  }

  void toggleComplete(int index) async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString("tasks");
    if (data == null) return;

    List<Map<String, dynamic>> allTasks =
        List<Map<String, dynamic>>.from(jsonDecode(data));

    int realIndex = allTasks.indexWhere((task) =>
        task["title"] == tasks[index]["title"] &&
        task["category"] == widget.categoryName);

    allTasks[realIndex]["completed"] =
        !allTasks[realIndex]["completed"];

    await saveAllTasks(allTasks);
    loadTasks();
  }

  void editTask(int index) {
    TextEditingController editController =
        TextEditingController(text: tasks[index]["title"]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Task"),
          content: TextField(controller: editController),
          actions: [
            TextButton(
              onPressed: () async {
                final prefs =
                    await SharedPreferences.getInstance();
                String? data = prefs.getString("tasks");
                if (data == null) return;

                List<Map<String, dynamic>> allTasks =
                    List<Map<String, dynamic>>.from(
                        jsonDecode(data));

                int realIndex =
                    allTasks.indexWhere((task) =>
                        task["title"] ==
                            tasks[index]["title"] &&
                        task["category"] ==
                            widget.categoryName);

                allTasks[realIndex]["title"] =
                    editController.text;

                await saveAllTasks(allTasks);
              if (context.mounted) {
              Navigator.pop(context);
}
                loadTasks();
              },
              child: const Text("Save"),
            )
          ],
        );
      },
    );
  }

  Color getPriorityColor(String priority) {
    if (priority == "High") return Colors.red;
    if (priority == "Medium") return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: taskController,
              decoration: const InputDecoration(
                labelText: "Enter Task",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              value: selectedPriority,
              items: ["High", "Medium", "Low"]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedPriority = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Priority",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addTask,
              child: const Text("Add Task"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  var task = tasks[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                      side: BorderSide(
                          color: getPriorityColor(
                              task["priority"]),
                          width: 2),
                    ),
                    child: ListTile(
                      title: Text(
                        task["title"],
                        style: TextStyle(
                          decoration: task["completed"]
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                          "Priority: ${task["priority"]}"),
                      leading: IconButton(
                        icon: Icon(Icons.check_circle,
                            color: task["completed"]
                                ? Colors.green
                                : Colors.grey),
                        onPressed: () =>
                            toggleComplete(index),
                      ),
                      trailing: Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          IconButton(
                            icon:
                                const Icon(Icons.edit),
                            onPressed: () =>
                                editTask(index),
                          ),
                          IconButton(
                            icon: const Icon(
                                Icons.delete,
                                color: Colors.red),
                            onPressed: () =>
                                deleteTask(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}