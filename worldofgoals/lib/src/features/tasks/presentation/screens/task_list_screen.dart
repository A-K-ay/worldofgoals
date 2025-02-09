import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worldofgoals/src/core/database/database.dart';
import 'package:worldofgoals/src/core/database/tables/tasks_table.dart';
import 'package:worldofgoals/src/features/tasks/presentation/cubits/task_cubit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import provider

import '../../task_filter.dart'; // Import TaskFilter

final DateFormat dayMonthDateFormat = DateFormat('d MMM');

class TaskList extends StatelessWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DefaultTabController(
            length: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hi Onky,',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600])),
                        BlocBuilder<TasksCubit, TasksState>(
                          builder: (context, state) {
                            if (state is TasksLoaded) {
                              return Text(
                                'You have ${state.tasks.length} tasks\nfor today',
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              );
                            }
                            return const Text('Loading tasks...');
                          },
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search your task',
                    // prefixIcon: const Icon(Icons.search), // Removed prefixIcon
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: TabBar(
                      isScrollable: true,
                      onTap: (index) {
                        final date = DateTime.now().add(Duration(days: index));
                        BlocProvider.of<TasksCubit>(context).updateTaskFilter(
                          TaskFilter(byDate: date),
                        );
                      },
                      tabs: List.generate(7, (index) {
                        final date = DateTime.now().add(Duration(days: index));
                        return Tab(
                          child: Text(_getDayName(date)),
                        );
                      })),
                ),
                Expanded(
                  child: BlocBuilder<TasksCubit, TasksState>(
                    builder: (context, state) {
                      if (state is TasksLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is TasksError) {
                        return Center(child: Text('Error: ${state.message}'));
                      } else if (state is TasksLoaded) {
                        final tasks = state.tasks;
                        if (tasks.isEmpty) {
                          return const Center(
                              child: Text('No tasks available.'));
                        }
                        return ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return _TaskCard(task: task);
                          },
                        );
                      }
                      return const Center(child: Text('No tasks loaded.'));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context,
              '/task_creation'); // Assuming '/task_creation' is the route for TaskCreationScreen
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getDayName(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day + 1) {
      return 'Tomorrow';
    } else {
      return dayMonthDateFormat.format(date);
    }
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Changed Card to Container
      // elevation: 2, // Removed elevation
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        // Added BoxDecoration for styling
        color:
            task.status == TaskStatus.completed ? Colors.black12 : Colors.white,
        borderRadius: BorderRadius.circular(15), // Still keep border radius
        boxShadow: [
          // Added shadow
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  task.difficulty.name.toUpperCase(),
                  style: TextStyle(
                      color: _getDifficultyColor(task.difficulty),
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      dayMonthDateFormat
                          .format(task.createdAt), // Replace with actual date
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            Visibility(
              visible: task.description?.isNotEmpty ?? false,
              child: Column(
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold), // Increased font size
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Visibility(
              visible: task.description?.isNotEmpty ?? false,
              child: Column(
                children: [
                  Text(
                    task.description ?? "", // Replace with actual project name
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14), // Subtitle style
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Checkbox(
                  value: task.status == TaskStatus.completed,
                  onChanged: (value) {
                    if (value != null && value) {
                      context.read<TasksCubit>().markTaskAsCompleted(task.id);
                    }
                  },
                ),
                if (task.status == TaskStatus.completed)
                  Text(
                    'Completed',
                    style: TextStyle(color: Colors.green),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return Colors.green;
      case TaskDifficulty.medium:
        return Colors.orange;
      case TaskDifficulty.hard:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
