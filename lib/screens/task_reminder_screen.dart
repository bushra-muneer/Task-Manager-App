
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/task_controller.dart';
import '../models/task.dart';

class TaskReminderScreen extends StatefulWidget {
  static const String id = 'task_reminder_screen';

  @override
  _TaskReminderScreenState createState() => _TaskReminderScreenState();
}

class _TaskReminderScreenState extends State<TaskReminderScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _notificationsEnabled = true; // Default value, can be loaded from preferences
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _createNotificationChannel();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Load preferences for the logged-in user
    _loadUserPreferences();
  }

  Future<void> _createNotificationChannel() async {
    print("Creating notification channel...");
    var androidNotificationChannel = AndroidNotificationChannel(
      'task_reminders', // ID
      'Task Reminders', // Name
      description: 'Channel for task reminders', // Description
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
    print("Notification channel created.");
  }

  Future<void> _requestPermissions() async {
    print("Requesting permissions...");
    var status = await Permission.scheduleExactAlarm.status;
    if (!status.isGranted) {
      await Permission.scheduleExactAlarm.request();
    }
    print("Permissions status: ${status.isGranted}");
  }

  Future<void> _scheduleNotification(int id, Task task, TimeOfDay reminderTime) async {
    if (!_notificationsEnabled || _currentUserId == null) {
      print("Notifications are disabled or user is logged out. No notification scheduled.");
      return;
    }

    await _requestPermissions();

    DateTime now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    // Check if the selected time is in the past or present
    if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
      print("Selected time is in the past or present. No notification scheduled.");
      Get.snackbar(
        'Invalid Time',
        'Please select a future time for the reminder.',
      );
      return;
    }

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    print('Scheduling notification for: $scheduledDate');

    final location = tz.getLocation('Europe/Rome');
    final scheduledDateTime = tz.TZDateTime.from(scheduledDate, location);

    print('Scheduled TZDateTime: $scheduledDateTime');

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id, // Unique ID for the notification
        task.title,
        task.description,
        scheduledDateTime,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print("Notification scheduled successfully.");
    } catch (e) {
      print("Error scheduling notification: $e");
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _loadUserPreferences() async {
    // Simulate user login and retrieve user ID
    String userId = await _getCurrentUserId();
    setState(() {
      _currentUserId = userId;
    });
    _loadNotificationPreferences(userId);
  }

  Future<String> _getCurrentUserId() async {
    // Replace with actual user ID retrieval logic
    return "userA"; // Example user ID
  }

  Future<void> _loadNotificationPreferences(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled_$userId') ?? true;
    });
  }

  Future<void> _saveNotificationPreferences(bool enabled, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notifications_enabled_$userId', enabled);
  }

  void _toggleNotifications(bool enabled) {
    setState(() {
      _notificationsEnabled = enabled;
    });
    if (_currentUserId != null) {
      _saveNotificationPreferences(enabled, _currentUserId!);
    }
  }

  void _handleUserLogin(String userId) {
    setState(() {
      _currentUserId = userId;
    });
    _loadNotificationPreferences(userId);
  }

  void _handleUserLogout() {
    setState(() {
      _currentUserId = null;
      _notificationsEnabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.put(TaskController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Reminders'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Notification Settings'),
                    content: SwitchListTile(
                      title: Text('Enable Notifications'),
                      value: _notificationsEnabled,
                      onChanged: _toggleNotifications,
                    ),
                    actions: [
                      TextButton(
                        child: Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        // Filter out completed tasks
        final tasks = taskController.tasks.where((task) => !task.isComplete.value).toList();
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ListTile(
              title: Text(task.title),
              subtitle: Text(task.description),
              trailing: Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_active),
                    onPressed: () {
                      if (_notificationsEnabled) {
                        _selectTime(context).then((_) {
                          // Check again if the selected time is still in the future
                          DateTime now = DateTime.now();
                          DateTime selectedDateTime = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            _selectedTime.hour,
                            _selectedTime.minute,
                          );
                          if (selectedDateTime.isAfter(now)) {
                            _scheduleNotification(index, task, _selectedTime);
                            Get.snackbar(
                              'Reminder Set',
                              'Reminder set for ${task.title} at ${_selectedTime.format(context)}',
                            );
                          } else {
                            Get.snackbar(
                              'Invalid Time',
                              'Please select a future time for the reminder.',
                            );
                          }
                        });
                      } else {
                        Get.snackbar(
                          'Notifications Disabled',
                          'Please enable notifications to set reminders.',
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
