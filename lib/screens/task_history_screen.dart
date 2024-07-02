
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import 'home_screen.dart';

class TaskHistoryScreen extends StatelessWidget {
  static const String id = 'task_history_screen';

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.put(TaskController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Task History'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Get.toNamed('/home_screen');
              
            },
          ),
        ],
      ),
      body: Obx(() {
        final completedTasks = taskController.tasks.where((task) => task.isComplete.value).toList();
        return ListView.builder(
          itemCount: completedTasks.length,
          itemBuilder: (context, index) {
            final task = completedTasks[index];
            return ListTile(
              title: Text(task.title),
              subtitle: Text(task.description),
              trailing: Icon(Icons.check, color: Colors.green),
            );
          },
        );
      }),
    );
  }
}
