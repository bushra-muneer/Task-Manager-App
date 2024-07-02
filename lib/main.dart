import 'package:flutter/material.dart';
import 'screens/task_history_screen.dart';
import 'screens/task_reminder_screen.dart';
import 'screens/home_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tz.initializeTimeZones();
  runApp(TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Task Manager App',
        theme: ThemeData(
          primarySwatch: Colors.purple,
        ),
        initialRoute: '/loginScreen',
         getPages: [
        GetPage(name: '/home_screen', page: () => HomeScreen()),
        GetPage(name: '/task_history_screen', page: () => TaskHistoryScreen()),
        GetPage(name: '/task_reminder_screen', page: () => TaskReminderScreen()),
        GetPage(name: '/loginScreen', page: () => LoginScreen()),
        GetPage(name: '/signUpScreen', page: () => SignUpScreen()),
        GetPage(name: '/forgotPasswordScreen', page: () => ForgotPasswordScreen()),
      ],
        debugShowCheckedModeBanner: false,
      );
  }
}



