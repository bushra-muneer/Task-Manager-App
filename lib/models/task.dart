
// class Task {
//    String id;
//   final String title;
//   final String description;
//   final DateTime dueDate;
//   final String priority;
//   bool isComplete;

//   Task({
//   this.id='',
//     required this.title,
//     required this.description,
//     required this.dueDate,
//     required this.priority,
//     this.isComplete = false,
//   });


//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'description': description,
//       'priority': priority,
//       'dueDate': dueDate.toIso8601String(),
//       'isComplete': isComplete,
//     };
//   }
//   // Getter to determine if task is overdue
//   bool get isOverdue {
//     final now = DateTime.now();
//     return dueDate.isBefore(now);
//   }
//   void toggleComplete() {
//     isComplete = !isComplete;
//   }
// }
import 'package:get/get.dart';

class Task {
  String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority;
  RxBool isComplete;

  Task({
    this.id = '',
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    bool isComplete = false,
  }) : isComplete = isComplete.obs;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'dueDate': dueDate.toIso8601String(),
      'isComplete': isComplete.value,
    };
  }

  // Getter to determine if task is overdue
  bool get isOverdue {
    final now = DateTime.now();
    return dueDate.isBefore(now);
  }

  void toggleComplete() {
    isComplete.value = !isComplete.value;
  }
}
