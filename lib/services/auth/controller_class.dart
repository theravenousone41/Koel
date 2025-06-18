import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../pages/home_page.dart';
import '../../pages/login_page.dart';

class ControllerClass extends StatefulWidget {
  const ControllerClass({super.key});

  @override
  State<ControllerClass> createState() => _ControllerClassState();
}

class _ControllerClassState extends State<ControllerClass> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),


        builder: (context,snapshot) {
          if (snapshot.hasData) {
            return HomePage();
          }
          else {
            return LoginPage();
          }
        }


    );
  }
}

