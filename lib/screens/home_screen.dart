
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/task_controller.dart';
import '../models/task.dart';

class HomeScreen extends StatelessWidget {
  final TaskController taskController = Get.put(TaskController());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final Rx<DateTime?> _dueDate = Rx<DateTime?>(null);
  final RxString _selectedPriority = 'Low'.obs;
  final RxString _searchText = ''.obs;
  final RxString _selectedFilterPriority = 'All'.obs; // Default filter option

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Handle loggedInUser
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    getCurrentUser();
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Get.toNamed('/task_history_screen');
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Get.toNamed('/task_reminder_screen');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Get.toNamed('/loginScreen');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterDropdown(),
          Expanded(
            child: Obx(() {
              if (taskController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              List<Task> filteredTasks = taskController.tasks.where((task) {
                return (task.title.toLowerCase().contains(_searchText.value.toLowerCase()) ||
                        task.description.toLowerCase().contains(_searchText.value.toLowerCase())) &&
                    (_selectedFilterPriority.value == 'All' || task.priority == _selectedFilterPriority.value);
              }).toList();
              return ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return TaskTile(
                    task: task,
                    onDelete: () {
                      taskController.deleteTask(task);
                    },
                    onEdit: () {
                      _editTask(context, task);
                    },
                    onComplete: () {
                      taskController.toggleTaskComplete(task);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (value) {
          _searchText.value = value;
        },
        decoration: InputDecoration(
          hintText: 'Search by Title or Description',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Text('Filter by Priority:'),
          SizedBox(width: 10.0),
          Obx(() => DropdownButton<String>(
                value: _selectedFilterPriority.value,
                onChanged: (String? newValue) {
                  _selectedFilterPriority.value = newValue!;
                },
                items: <String>['All', 'Low', 'Medium', 'High']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  void _editTask(BuildContext context, Task task) {
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _dueDate.value = task.dueDate;
    _selectedPriority.value = task.priority;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              Row(
                children: [
                  Obx(() => Text(
                    _dueDate.value == null
                        ? 'No Date Chosen!'
                        : 'Due Date: ${_formatDueDate(_dueDate.value!)}',
                  )),
                  Spacer(),
                  IconButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _dueDate.value ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDate != null) {
                        _dueDate.value = selectedDate;
                      }
                    },
                    icon: Icon(Icons.calendar_today),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                value: _selectedPriority.value,
                onChanged: (String? newValue) {
                  _selectedPriority.value = newValue!;
                },
                items: <String>['Low', 'Medium', 'High']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final updatedTask = Task(
                  id: task.id,
                  title: _titleController.text,
                  description: _descriptionController.text,
                  priority: _selectedPriority.value,
                  dueDate: _dueDate.value ?? DateTime.now(),
                  isComplete: task.isComplete.value,
                );

                taskController.updateTask(
                  updatedTask.id,
                  updatedTask.title,
                  updatedTask.description,
                  updatedTask.priority,
                  updatedTask.dueDate,
                );

                Get.back(); // Close dialog
              },
              child: Text('Update Task'),
            ),
          ],
        );
      },
    );
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference > 1) {
      return 'Due in $difference days';
    } else {
      return 'Overdue';
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    _titleController.clear();
    _descriptionController.clear();
    _dueDate.value = null;
    _selectedPriority.value = 'Low';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              Row(
                children: [
                  Obx(() => Text(
                    _dueDate.value == null
                        ? 'No Date Chosen!'
                        : 'Due Date: ${_formatDueDate(_dueDate.value!)}',
                  )),
                  Spacer(),
                  IconButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _dueDate.value ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDate != null) {
                        _dueDate.value = selectedDate;
                      }
                    },
                    icon: Icon(Icons.calendar_today),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                value: _selectedPriority.value,
                onChanged: (String? newValue) {
                  _selectedPriority.value = newValue!;
                },
                items: <String>['Low', 'Medium', 'High']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final task = Task(
                  id: DateTime.now().toString(),
                  title: _titleController.text,
                  description: _descriptionController.text,
                  priority: _selectedPriority.value,
                  dueDate: _dueDate.value ?? DateTime.now(),
                  isComplete: false.obs.value,
                );

                if (taskController.isDuplicateTask(task.title, task.description, task.priority, task.dueDate)) {
                  // Handle duplicate task
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Task already exists. Please enter a new task.'),
                    duration: Duration(seconds: 2),
                  ));
                } else {
                  taskController.addTask(task);
                  Get.back(); // Close dialog
                }
              },
              child: Text('Add Task'),
            ),
          ],
        );
      },
    );
  }
}

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onComplete;

  TaskTile({
    required this.task,
    required this.onDelete,
    required this.onEdit,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDueDate = _formatDueDate(task.dueDate);
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description),
            SizedBox(height: 4),
            Text(
              'Due: $formattedDueDate • Priority: ${task.priority}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getDueDateColor(task.dueDate),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDelete,
            ),
            Checkbox(
              value: task.isComplete.value,
              onChanged: (_) {
                onComplete();
              },
            ),
          ],
        ),
        onTap: onEdit,
        onLongPress: () {
          onDelete();
        },
      ),
    );
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference > 1) {
      return 'Due in $difference days';
    } else {
      return 'Overdue';
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return Colors.red; // Overdue
    } else if (difference == 0 || difference == 1) {
      return Colors.orange; // Today or Tomorrow
    } else {
      return Colors.green; // Due in more than 1 day
    }
  }
}


