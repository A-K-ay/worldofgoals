import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worldofgoals/src/features/tasks/presentation/cubits/task_cubit.dart';
import '../../../../core/database/tables/tasks_table.dart'; // Correct import path

class TaskCreationScreen extends StatefulWidget {
  const TaskCreationScreen({super.key});

  @override
  TaskCreationScreenState createState() => TaskCreationScreenState();
}

class TaskCreationScreenState extends State<TaskCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskDifficulty _difficulty = TaskDifficulty.easy;
  DateTime? _dueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Description (optional)'),
                maxLines: 3,
              ),
              DropdownButtonFormField<TaskDifficulty>(
                value: _difficulty,
                decoration: const InputDecoration(labelText: 'Difficulty'),
                items: TaskDifficulty.values.map((TaskDifficulty value) {
                  return DropdownMenuItem<TaskDifficulty>(
                    value: value,
                    child: Text(value.toString().split('.').last.capitalize()),
                  );
                }).toList(),
                onChanged: (TaskDifficulty? newValue) {
                  setState(() {
                    _difficulty = newValue!;
                  });
                },
              ),
              ListTile(
                title: Text(_dueDate == null
                    ? 'No due date selected'
                    : 'Due Date: ${_dueDate!.toLocal()}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final now = DateTime.now();
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: DateTime(now.year - 1),
                    lastDate: DateTime(now.year + 1),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dueDate = pickedDate;
                    });
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final taskCubit =
                          Provider.of<TasksCubit>(context, listen: false);
                      await taskCubit.createTask(
                        title: _titleController.text,
                        description: _descriptionController.text,
                        difficulty: _difficulty,
                        dueDate: _dueDate,
                      );
                      Navigator.pop(
                          context); // Go back to task list after creating task
                    }
                  },
                  child: const Text('Create Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension to capitalize first letter of string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

// enum TaskDifficulty { // Removed duplicated enum
//   easy,
//   medium,
//   hard,
//   epic,
// }


