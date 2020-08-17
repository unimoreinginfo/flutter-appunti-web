import 'package:appunti_web_frontend/io.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/browser_client.dart' as http;

import 'home.dart';
import 'login.dart';
import 'subjects.dart';
import 'admin.dart';
import 'edit.dart';
import 'profile.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      Provider(create: (_) => http.BrowserClient()),
      Provider(create: (_) => LocalStorageTokenStorage())  // per Web vanno bene così
    ],
    child: MyApp(),
  ),);
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color(0xff6246ea),
        textTheme: TextTheme(
          bodyText2: TextStyle(
            fontWeight: FontWeight.w100,
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
        "/": (context) => HomePage(),
        "/admin": (context) => AdminPage(),
        "/materie": (context) => SubjectsPage(),
        "/profile": (context) => ProfilePage()
      },
      initialRoute: '/',
    );
  }
}