import 'package:flutter/material.dart';
import 'io.dart';
import 'platform.dart' as platform;

class EditPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if(!isLoggedIn(platform.tokenStorage)) {
      Navigator.pushReplacementNamed(context, '/login');
    }
    return Scaffold(
      appBar: AppBar(title: Text("Aggiungi o modera i contenuti"),),
      body: Scaffold(
        body: Text("non c'è ancora niente"),
      ),
    );
  }
}