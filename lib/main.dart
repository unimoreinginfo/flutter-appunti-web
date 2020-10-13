import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'consts.dart';
import 'utils.dart';
import 'platform.dart';
import 'io.dart';
import 'home.dart';
import 'login.dart';
import 'note.dart';
import 'subjects.dart';
import 'edit.dart';
import 'profile.dart';

void defineRoutes() {
  router.define("/",
      handler: Handler(
        handlerFunc: (context, parameters) => HomePage(),
      ));
  router.define("/users/:id", handler: Handler(
    handlerFunc: (context, parameters) {
      return ProfilePage(parameters["id"][0]);
    },
  ));
  router.define("/editProfile/:id", handler: Handler(
    handlerFunc: (context, parameters) {
      return EditProfilePage(parameters["id"][0]);
    },
  ));
  router.define("/notes/:subjectId/:noteId", handler: Handler(
    handlerFunc: (context, parameters) {
      return NotePage(parameters["subjectId"][0], parameters["noteId"][0]);
    },
  ));
  router.define("/edit", handler: Handler(
    handlerFunc: (context, parameters) {
      String token;
      try {
        token = getToken(tokenStorage);
        if (!refreshTokenStillValid(tokenStorage))
          goToRouteAsap(context, '/login');
        else {
          try {
            bool mod = isMod(token);
            return EditPage(mod, token);
          } catch (e) {
            showDialog(
                context: context,
                child: AlertDialog(title: SelectableText("$e")));
            goToRouteAsap(context, '/login');
          }
        }
      } catch (e) {
        goToRouteAsap(context, '/login');
      }
      return LoginPage();
    },
  ));
  router.define("/subjects",
      handler: Handler(
        handlerFunc: (context, parameters) => SubjectsPage(),
      ));
  router.define("/login",
      handler: Handler(
        handlerFunc: (context, parameters) => LoginPage(),
      ));
  router.define("/signup",
      handler: Handler(
        handlerFunc: (context, parameters) => SignupPage(),
      ));
}

void main() {
  defineRoutes();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: router.generator,
      title: 'Appunti Web',
      locale: Locale('it', 'IT'),
      theme: ThemeData(
          inputDecorationTheme: InputDecorationTheme(),
          primaryColor: Color(0xff6246ea),
          textTheme: TextTheme(
              bodyText2: TextStyle(
                  fontWeight: FontWeight.w100,
                  letterSpacing: 0,
                  wordSpacing: -1,
                  fontSize: 13.0),
              bodyText1: TextStyle(
                  fontWeight: FontWeight.w100,
                  letterSpacing: 0,
                  wordSpacing: -1,
                  height: 1.3,
                  fontSize: 18.0),
              headline4:
                  TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
              headline3: TextStyle(
                  height: 1.4,
                  fontWeight: FontWeight.w900,
                  color: Colors.black),
              button: TextStyle(color: Colors.white))),
      initialRoute: '/',
    );
  }
}
