

// import 'package:flutter/material.dart';
// import 'task.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';

// class TaskData extends ChangeNotifier {
//   List<Task> tasks = [];
//   final _auth = FirebaseAuth.instance;
//   final _database = FirebaseDatabase.instance.reference();
//  final User? user = FirebaseAuth.instance.currentUser;
//   Future<void> addTask(BuildContext context, String title, String description, String priority, DateTime dueDate) async {
//     final User? user = _auth.currentUser;
//     if (user != null) {
//       final task = Task(
//         id: DateTime.now().toString(),
//         title: title,
//         description: description,
//         priority: priority,
//         dueDate: dueDate,
//       );
//       tasks.add(task);
//       notifyListeners();

//       await _database.child('tasks').child(user.uid).push().set({
//         'title': title,
//         'description': description,
//         'priority': priority,
//         'dueDate': dueDate.toIso8601String(),
//         'isComplete': task.isComplete,
//       });
//     }
//   }

//   // Future<void> getTasks() async {
//   //   final User? user = _auth.currentUser;
//   //   if (user != null) {
//   //     _database.child('tasks').child(user.uid).once().then((DataSnapshot snapshot) {
//   //       if (snapshot.value != null) {
//   //         Map<dynamic, dynamic> taskMap = snapshot.value;
//   //         tasks = taskMap.entries.map((entry) {
//   //           final data = entry.value;
//   //           return Task(
//   //             id: entry.key,
//   //             title: data['title'],
//   //             description: data['description'],
//   //             priority: data['priority'],
//   //             dueDate: DateTime.parse(data['dueDate']),
//   //             isComplete: data['isComplete'],
//   //           );
//   //         }).toList();
//   //         notifyListeners();
//   //       }
//   //     });
//   //   }
//   // }
//  final String user_id = FirebaseAuth.instance.currentUser!.uid;


//   Future<void> getTasks(user_id) async {
   
//       _database.child('tasks').child(user_id).once().then(( snapshot) {
//         if (snapshot.snapshot.value != null) {
//           Map<dynamic, dynamic> tasksData = snapshot.snapshot.value as Map<dynamic, dynamic>;
//           tasks.clear();
//           tasksData.forEach((key, value) {
//             Task task = Task(
//               id: key,
//               title: value['title'],
//               description: value['description'],
//               priority: value['priority'],
//               dueDate: DateTime.parse(value['dueDate']),
//               isComplete: value['isComplete'],
//             );
//             tasks.add(task);
//           });
//           notifyListeners();
//         }
//       }).catchError((error) {
//         print('Failed to fetch tasks: $error');
//       });
//     }
    

//   Future<void> deleteTask(BuildContext context, Task task) async {
//     final User? user = _auth.currentUser;
//     if (user != null) {
//       tasks.remove(task);
//       notifyListeners();

//       await _database.child('tasks').child(user.uid).child(task.id).remove();
//     }
//   }

//   Future<void> toggleTaskComplete(BuildContext context, Task task) async {
//     final User? user = _auth.currentUser;
//     if (user != null) {
//       task.toggleComplete();
//       notifyListeners();

//       await _database.child('tasks').child(user.uid).child(task.id).update({
//         'isComplete': task.isComplete,
//       });
//     }
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart'; // Use Firebase Realtime Database
// import '../models/task.dart';

// class TaskData extends ChangeNotifier {
//   List<Task> tasks = [];
//   final _auth = FirebaseAuth.instance;
//   final _database = FirebaseDatabase.instance;

//   Future<void> fetchTasks(String userId) async {
//     try {
//       DatabaseReference tasksRef =
//           _database.reference().child('tasks').child(userId);
//       tasksRef.onValue.listen((event) {
//         tasks.clear();
//         Map<dynamic, dynamic> tasksMap = event.snapshot.value as Map<dynamic, dynamic>;
//         if (tasksMap != null) {
//           tasksMap.forEach((key, value) {
//             Task task = Task(
//               id: key,
//               title: value['title'],
//               description: value['description'],
//               priority: value['priority'],
//               dueDate: DateTime.parse(value['dueDate']),
//               isComplete: value['isComplete'],
//             );
//             tasks.add(task);
//           });
//         }
//         notifyListeners();
//       });
//     } catch (e) {
//       print('Error fetching tasks: $e');
//     }
//   }

//   Future<void> addTask(
//     BuildContext context,
//     String title,
//     String description,
//     String priority,
//     DateTime dueDate,
//   ) async {
//     try {
//       final User? user = _auth.currentUser;
//       if (user != null) {
//         if (title.isEmpty || description.isEmpty) {
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: Text('Invalid Input'),
//               content: Text('Task title and description cannot be empty.'),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: Text('OK'),
//                 ),
//               ],
//             ),
//           );
//           return;
//         }

//         DatabaseReference tasksRef =
//             _database.reference().child('tasks').child(user.uid);
//         String taskId = tasksRef.push().key ?? DateTime.now().toString();
//         Task newTask = Task(
//           id: taskId,
//           title: title,
//           description: description,
//           priority: priority,
//           dueDate: dueDate,
//           isComplete: false,
//         );
//         await tasksRef.child(taskId).set(newTask.toJson());
//         tasks.add(newTask);
//         notifyListeners();
//       }
//     } catch (e) {
//       print('Error adding task: $e');
//     }
//   }

//   Future<void> updateTask(
//     BuildContext context,
//     String id,
//     String title,
//     String description,
//     String priority,
//     DateTime dueDate,
//   ) async {
//     try {
//       final User? user = _auth.currentUser;
//       if (user != null) {
//         if (title.isEmpty || description.isEmpty) {
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: Text('Invalid Input'),
//               content: Text('Task title and description cannot be empty.'),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: Text('OK'),
//                 ),
//               ],
//             ),
//           );
//           return;
//         }

//         DatabaseReference taskRef =
//             _database.reference().child('tasks').child(user.uid).child(id);
//         Task updatedTask = Task(
//           id: id,
//           title: title,
//           description: description,
//           priority: priority,
//           dueDate: dueDate,
//           isComplete: false, // Assuming task status cannot be updated here
//         );
//         await taskRef.update(updatedTask.toJson());
        
//         // Update local tasks list if necessary
//         int index = tasks.indexWhere((task) => task.id == id);
//         if (index != -1) {
//           tasks[index] = updatedTask;
//           notifyListeners();
//         }
//       }
//     } catch (e) {
//       print('Error updating task: $e');
//     }
//   }

//   Future<void> deleteTask(BuildContext context, Task task) async {
//     try {
//       final User? user = _auth.currentUser;
//       if (user != null) {
//         DatabaseReference taskRef =
//             _database.reference().child('tasks').child(user.uid).child(task.id);
//         await taskRef.remove();
//         tasks.remove(task);
//         notifyListeners();
//       }
//     } catch (e) {
//       print('Error deleting task: $e');
//     }
//   }

//   Future<void> toggleTaskComplete(BuildContext context, Task task) async {
//     try {
//       final User? user = _auth.currentUser;
//       if (user != null) {
//         DatabaseReference taskRef =
//             _database.reference().child('tasks').child(user.uid).child(task.id);
//         task.toggleComplete();
//         await taskRef.update({'isComplete': task.isComplete});
//         notifyListeners();
//       }
//     } catch (e) {
//       print('Error toggling task completion: $e');
//     }
//   }
// }
