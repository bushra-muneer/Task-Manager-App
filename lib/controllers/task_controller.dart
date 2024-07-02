// import 'package:get/get.dart';
// import '../models/task_data.dart';
// import '../models/task.dart';

// class TaskController extends GetxController {
//   final taskData = TaskData().obs;

//   List<Task> get completedTasks => taskData.value.tasks.where((task) => task.isComplete).toList();
// }



// import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';// Add this line to import the Event class
// import '../models/task.dart';

// class TaskController extends GetxController {
//   // var tasks = <Task>[].obs;
//    final RxList<Task> tasks = <Task>[].obs;
//   // List<Task> get tasks => _tasks.toList();
//   final _auth = FirebaseAuth.instance;
//   final _database = FirebaseDatabase.instance.reference();
//  var isLoading = true.obs;
//   @override
//   void onInit() {
//     super.onInit();
//     fetchTasks();
//   }

//   Future<void> fetchTasks() async {
//     try {
//         isLoading(true); 
//       final user = _auth.currentUser;
//       if (user != null) {
//         DatabaseReference tasksRef = _database.child('tasks').child(user.uid);
//         tasksRef.onValue.listen((event) {
//           tasks.clear();
//           Map<dynamic, dynamic> tasksMap = event.snapshot.value as Map<dynamic, dynamic>;
//           if (tasksMap != null) {
//             tasksMap.forEach((key, value) {
//               Task task = Task(
//                 id: key,
//                 title: value['title'],
//                 description: value['description'],
//                 priority: value['priority'],
//                 dueDate: DateTime.parse(value['dueDate']),
//                 isComplete: value['isComplete'],
//               );
//               tasks.add(task);
//             });
//           }
//         });
//       }
//     } catch (e) {
//       print('Error fetching tasks: $e');
//     }
//     finally {
//       isLoading(false); // Set loading state to false after fetching tasks
//     }
//   }

//   Future<void> addTask(String title, String description, String priority, DateTime dueDate) async {
//     try {
//        isLoading(true); 
//       final user = _auth.currentUser;
//       if (user != null) {
//         if (title.isEmpty || description.isEmpty) {
//           Get.snackbar('Invalid Input', 'Task title and description cannot be empty.');
//           return;
//         }

//         DatabaseReference tasksRef = _database.child('tasks').child(user.uid);
//         String taskId = tasksRef.push().key ?? DateTime.now().toString();
//         Task newTask = Task(
//           id: taskId,
//           title: title,
//           description: description,
//           priority: priority,
//           dueDate: dueDate,
//         );
//         await tasksRef.child(taskId).set(newTask.toJson());
//         tasks.add(newTask);
//       }
//     } catch (e) {
//       print('Error adding task: $e');
//     }
//     finally {
//       isLoading(false); // Set loading state to false after adding task
//     }
//   }

//   Future<void> updateTask(String id, String title, String description, String priority, DateTime dueDate) async {
//     try {
//         isLoading(true); 
//       final user = _auth.currentUser;
//       if (user != null) {
//         if (title.isEmpty || description.isEmpty) {
//           Get.snackbar('Invalid Input', 'Task title and description cannot be empty.');
//           return;
//         }

//         DatabaseReference taskRef = _database.child('tasks').child(user.uid).child(id);
//         Task updatedTask = Task(
//           id: id,
//           title: title,
//           description: description,
//           priority: priority,
//           dueDate: dueDate,
//         );
//         await taskRef.update(updatedTask.toJson());

//         int index = tasks.indexWhere((task) => task.id == id);
//         if (index != -1) {
//           tasks[index] = updatedTask;
//         }
//       }
//     } catch (e) {
//       print('Error updating task: $e');
//     }
//     finally {
//       isLoading(false); // Set loading state to false after adding task
//     }
//   }

//   Future<void> deleteTask(Task task) async {
//     try {
//         isLoading(true); 
//       final user = _auth.currentUser;
//       if (user != null) {
//         DatabaseReference taskRef = _database.child('tasks').child(user.uid).child(task.id);
//         await taskRef.remove();
//         tasks.remove(task);
//       }
//     } catch (e) {
//       print('Error deleting task: $e');
//     }
//     finally {
//       isLoading(false); // Set loading state to false after adding task
//     }
//   }

//   Future<void> toggleTaskComplete(Task task) async {
//     try {
//         isLoading(true); 
//       final user = _auth.currentUser;
//       if (user != null) {
//         DatabaseReference taskRef = _database.child('tasks').child(user.uid).child(task.id);
//         task.toggleComplete();
//         await taskRef.update({'isComplete': task.isComplete.value});
//       }
//     } catch (e) {
//       print('Error toggling task completion: $e');
//     }
//     finally {
//       isLoading(false); // Set loading state to false after adding task
//     }
//   }
// }


// class TaskController extends GetxController {
//   final RxList<Task> tasks = <Task>[].obs;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final DatabaseReference _database =
//       FirebaseDatabase.instance.reference();
//   final RxBool isLoading = true.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchTasks();
//   }

//   Future<void> fetchTasks() async {
//     try {
//       isLoading(true);
//       final User? user = _auth.currentUser;
//       if (user != null) {
//         DatabaseReference tasksRef =
//             _database.child('tasks').child(user.uid);
//         tasksRef.onValue.listen(( event) {
//           tasks.clear();
//           Map<dynamic, dynamic>? tasksMap =
//               event.snapshot.value as Map<dynamic, dynamic>?;
//           if (tasksMap != null) {
//             tasksMap.forEach((dynamic key, dynamic value) {
//               Task task = Task(
//                 id: key,
//                 title: value['title'],
//                 description: value['description'],
//                 priority: value['priority'],
//                 dueDate: DateTime.parse(value['dueDate']),
//                 isComplete: value['isComplete'],
//               );
//               tasks.add(task);
//             });
//           }
//         });
//       }
//     } catch (e) {
//       print('Error fetching tasks: $e');
//     } finally {
//       isLoading(false); // Set loading state to false after fetching tasks
//     }
//   }

//   Future<void> addTask(String title, String description, String priority,
//       DateTime dueDate) async {
//     try {
//       isLoading(true);
//       final User? user = _auth.currentUser;
//       if (user != null) {
//         if (title.isEmpty || description.isEmpty) {
//           Get.snackbar(
//               'Invalid Input', 'Task title and description cannot be empty.');
//           return;
//         }

//         DatabaseReference tasksRef =
//             _database.child('tasks').child(user.uid);
//         String taskId = tasksRef.push().key ?? DateTime.now().toString();
//         Task newTask = Task(
//           id: taskId,
//           title: title,
//           description: description,
//           priority: priority,
//           dueDate: dueDate,
//         );
//         await tasksRef.child(taskId).set(newTask.toJson());
//         tasks.add(newTask);
//       }
//     } catch (e) {
//       print('Error adding task: $e');
//     } finally {
//       isLoading(false); // Set loading state to false after adding task
//     }
//   }

//   // Other methods like updateTask, deleteTask, toggleTaskComplete





//   Future<void> updateTask(String id, String title, String description, String priority, DateTime dueDate) async {
//     try {
//         isLoading(true); 
//       final user = _auth.currentUser;
//       if (user != null) {
//         if (title.isEmpty || description.isEmpty) {
//           Get.snackbar('Invalid Input', 'Task title and description cannot be empty.');
//           return;
//         }

//         DatabaseReference taskRef = _database.child('tasks').child(user.uid).child(id);
//         Task updatedTask = Task(
//           id: id,
//           title: title,
//           description: description,
//           priority: priority,
//           dueDate: dueDate,
//         );
//         await taskRef.update(updatedTask.toJson());

//         int index = tasks.indexWhere((task) => task.id == id);
//         if (index != -1) {
//           tasks[index] = updatedTask;
//         }
//       }
//     } catch (e) {
//       print('Error updating task: $e');
//     }
//     finally {
//       isLoading(false); // Set loading state to false after adding task
//     }
//   }

//   Future<void> deleteTask(Task task) async {
//     try {
//         isLoading(true); 
//       final user = _auth.currentUser;
//       if (user != null) {
//         DatabaseReference taskRef = _database.child('tasks').child(user.uid).child(task.id);
//         await taskRef.remove();
//         tasks.remove(task);
//       }
//     } catch (e) {
//       print('Error deleting task: $e');
//     }
//     finally {
//       isLoading(false); // Set loading state to false after adding task
//     }
//   }

//   Future<void> toggleTaskComplete(Task task) async {
//     try {
//         isLoading(true); 
//       final user = _auth.currentUser;
//       if (user != null) {
//         DatabaseReference taskRef = _database.child('tasks').child(user.uid).child(task.id);
//         task.toggleComplete();
//         await taskRef.update({'isComplete': task.isComplete.value});
//       }
//     } catch (e) {
//       print('Error toggling task completion: $e');
//     }
//     finally {
//       isLoading(false); // Set loading state to false after adding task
//     }
//   }
// }


import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/task.dart';

class TaskController extends GetxController {
  final RxList<Task> tasks = <Task>[].obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  final RxBool isLoading = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      isLoading(true);
      final User? user = _auth.currentUser;
      if (user != null) {
        DatabaseReference tasksRef = _database.child('tasks').child(user.uid);
        tasksRef.onValue.listen((event) {
          tasks.clear();
          Map<dynamic, dynamic>? tasksMap = event.snapshot.value as Map<dynamic, dynamic>?;
          if (tasksMap != null) {
            tasksMap.forEach((dynamic key, dynamic value) {
              Task task = Task(
                id: key,
                title: value['title'],
                description: value['description'],
                priority: value['priority'],
                dueDate: DateTime.parse(value['dueDate']),
                isComplete: (value['isComplete']),
              );
              tasks.add(task);
            });
          }
        });
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    } finally {
      isLoading(false); // Set loading state to false after fetching tasks
    }
  }

  Future<void> addTask(Task task) async {
    try {
      isLoading(true);
      final User? user = _auth.currentUser;
      if (user != null) {
        if (task.title.isEmpty || task.description.isEmpty) {
          Get.snackbar('Invalid Input', 'Task title and description cannot be empty.');
          return;
        }

        DatabaseReference tasksRef = _database.child('tasks').child(user.uid);
        String taskId = tasksRef.push().key ?? DateTime.now().toString();
        task.id = taskId;
        await tasksRef.child(taskId).set(task.toJson());
       // tasks.add(task);

      }
    } catch (e) {
      print('Error adding task: $e');
    } finally {
      isLoading(false); // Set loading state to false after adding task
    }
  }

  Future<void> updateTask(String id, String title, String description, String priority, DateTime dueDate) async {
    try {
      isLoading(true);
      final User? user = _auth.currentUser;
      if (user != null) {
        if (title.isEmpty || description.isEmpty) {
          Get.snackbar('Invalid Input', 'Task title and description cannot be empty.');
          return;
        }

        DatabaseReference taskRef = _database.child('tasks').child(user.uid).child(id);
        Task updatedTask = Task(
          id: id,
          title: title,
          description: description,
          priority: priority,
          dueDate: dueDate,
          isComplete: false.obs.value,
        );
        await taskRef.update(updatedTask.toJson());

        int index = tasks.indexWhere((task) => task.id == id);
        if (index != -1) {
          tasks[index] = updatedTask;
        }
      }
    } catch (e) {
      print('Error updating task: $e');
    } finally {
      isLoading(false); // Set loading state to false after updating task
    }
  }

  Future<void> deleteTask(Task task) async {
    try {
      isLoading(true);
      final User? user = _auth.currentUser;
      if (user != null) {
        DatabaseReference taskRef = _database.child('tasks').child(user.uid).child(task.id);
        await taskRef.remove();
        tasks.remove(task);
      }
    } catch (e) {
      print('Error deleting task: $e');
    } finally {
      isLoading(false); // Set loading state to false after deleting task
    }
  }

  Future<void> toggleTaskComplete(Task task) async {
    try {
      isLoading(true);
      final User? user = _auth.currentUser;
      if (user != null) {
        DatabaseReference taskRef = _database.child('tasks').child(user.uid).child(task.id);
        task.toggleComplete();
        await taskRef.update({'isComplete': task.isComplete.value});
      }
    } catch (e) {
      print('Error toggling task completion: $e');
    } finally {
      isLoading(false); // Set loading state to false after toggling task completion
    }
  }

  bool isDuplicateTask(String title, String description, String priority, DateTime dueDate) {
    return tasks.any((task) =>
      task.title == title &&
      task.description == description &&
      task.priority == priority &&
      task.dueDate == dueDate
    );
  }
}
