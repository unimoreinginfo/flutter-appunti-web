import 'package:appunti_web_frontend/note.dart' show ProvidedArg;
import 'package:flutter/material.dart';

import 'utils.dart';
import 'platform.dart';
import 'io.dart';
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
      locale: Locale('it', 'IT'),
      theme: ThemeData(
          primaryColor: Color(0xff6246ea),
          textTheme: TextTheme(
              bodyText2: TextStyle(
                  letterSpacing: 0,
                  wordSpacing: -1,
                  height: 1.3,
                  fontSize: 17.0),
              headline4:
                  TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
              headline3: TextStyle(
                  height: 1.4,
                  fontWeight: FontWeight.w900,
                  color: Colors.black),
              button: TextStyle(color: Colors.white))),
      routes: {
        "/edit": (context) {
          return FutureBuilder(
              future: refreshTokenStillValid(tokenStorage),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  goToRouteAsap(context, '/login');
                }
                if (!snapshot.hasData) return CircularProgressIndicator();
                if (snapshot.data == false) goToRouteAsap(context, '/login');
                return FutureBuilder(
                    future: getToken(tokenStorage),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        goToRouteAsap(context, '/login');
                        showDialog(
                            context: context,
                            child:
                                AlertDialog(title: Text("${snapshot.error}")));
                      }
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      return EditPage(isMod(snapshot.data), snapshot.data);
                    });
              });
        },
        "/login": (context) => LoginPage(),
        "/signup": (context) => SignupPage(),
        "/": (context) => HomePage(),
        "/subjects": (context) => SubjectsPage(),
        "/profile": (context) {
          List args = ModalRoute.of(context).settings.arguments;
          if (args[0] == ProvidedArg.id) {
            String uid = args[1];
            return ProfilePage(uid);
          } else
            return ProfilePage(args[1]["id"], userData: args[1]);
        },
        "/editProfile": (context) {
          List args = ModalRoute.of(context).settings.arguments;
          Map userData = args[0];
          String jwt = args[1];
          return EditProfile(userData, jwt);
        }
      },
      initialRoute: '/',
    );
  }
}
