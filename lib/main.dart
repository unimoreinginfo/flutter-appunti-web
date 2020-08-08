import 'package:appunti_web_frontend/io.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/browser_client.dart' as http;

import 'home.dart';
import 'login.dart';
import 'subjects.dart';
import 'admin.dart';
import 'edit.dart';

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
      routes: {
        "/edit": (context) => EditPage(), 
        "/login": (context) => LoginPage(),
        "/": (context) => HomePage(),
        "/admin": (context) => AdminPage(),
        "/materie": (context) => SubjectsPage()
      },
      initialRoute: '/',
    );
  }
}