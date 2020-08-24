import 'package:appunti_web_frontend/note.dart' show ProvidedArg;
import 'package:flutter/material.dart';

import 'home.dart';
import 'login.dart';
import 'subjects.dart';
import 'edit.dart';
import 'profile.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appunti Web',
      theme: ThemeData(
        primaryColor: Color(0xff6246ea),
        textTheme: TextTheme(
          bodyText2: TextStyle(
             letterSpacing: 0,
            wordSpacing: -1,
            height: 1.3,
            fontSize: 17.0
          ),
          headline4: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black
          ),
          headline3: TextStyle(
            height: 1.4,
            fontWeight: FontWeight.w900,
            color: Colors.black
          ),
          button: TextStyle(
            color: Colors.white
          )
        )
      ),
      routes: {
        "/edit": (context) => EditPage(), 
        "/login": (context) => LoginPage(),
        "/signup": (context) => SignupPage(),
        "/": (context) => HomePage(),
        "/subjects": (context) => SubjectsPage(),
        "/profile": (context)  {
          List args = ModalRoute.of(context).settings.arguments;
          if(args[0] == ProvidedArg.id) {
            int uid = args[1];
            return ProfilePage(uid);
          } else return ProfilePage(args[1]["id"], userData: args[1]);
        }
      },
      initialRoute: '/',
    );
  }
}