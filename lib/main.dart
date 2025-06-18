import 'package:chat_application/pages/create_account_page.dart';
import 'package:chat_application/pages/home_page.dart';
import 'package:chat_application/pages/login_page.dart';
import 'package:chat_application/pages/splash_screen_page.dart';

import 'package:chat_application/services/auth/controller_class.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
 WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(

  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
debugShowCheckedModeBanner: false,
     initialRoute: '/splash',
      routes: {

  '/controller': (context)=> ControllerClass(),
        '/splash': (context)=> SplashScreenPage(),
  '/login': (context)=> LoginPage(),
        '/signup': (context)=> CreateAccountPage(),
        '/home': (context)=> HomePage(),
    },
    );
  }
}

