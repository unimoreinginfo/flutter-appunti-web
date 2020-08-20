import 'package:flutter/material.dart';
import 'io.dart';
import 'platform.dart' as platform;

class EditPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if(!isLoggedIn(platform.tokenStorage)) {
      Navigator.pushReplacementNamed(context, '/login');
    }
    final mod = isMod(platform.tokenStorage);

    return Scaffold(
      appBar: AppBar(title: Text(mod ? "Aggiungi o modera i contenuti" : "Mandaci i tuoi appunti!"),),
      body: Scaffold(
        body: mod ? ModPage() : PlebPage(),
      ),
    );
  }
}

class PlebPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class ModPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}