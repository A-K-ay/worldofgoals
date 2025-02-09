import 'package:worldofgoals/src/core/database/database.dart';

class TaskFilter {
  final String? byName;
  final DateTime? byDate;

  TaskFilter({this.byName, this.byDate});

  List<Task> filter(List<Task> tasks) {
    return tasks.where((task) {
      bool show = true;
      if (byDate != null && task.dueDate != null) {
        show = show && checkDateFilter(task.dueDate!, byDate!);
      }
      if (byName != null) {
        show && task.title.toLowerCase().contains(byName!.toLowerCase());
      }
      return show;
    }).toList();
  }

  bool checkDateFilter(DateTime dueDate, DateTime filterDate) {
    dueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    filterDate = DateTime(filterDate.year, filterDate.month, filterDate.day);
    return
        // dueDate.isBefore(filterDate) ||
        dueDate.isAtSameMomentAs(filterDate);
  }
}
