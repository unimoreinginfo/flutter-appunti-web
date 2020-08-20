import 'package:flutter/material.dart';
import 'io.dart';
import 'platform.dart' as platform;

class EditPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: isLoggedIn(platform.tokenStorage),
      builder: (context, snapshot)  {
        if(!snapshot.hasData) return CircularProgressIndicator();
        final bool loggedIn = snapshot.data;
        if(!loggedIn) {
          Navigator.pushReplacementNamed(context, '/login');
        }        
        return FutureBuilder<bool>(
          future: isMod(platform.tokenStorage),
          builder: (context, snapshot) {
            final bool mod = snapshot.data;
            if(!snapshot.hasData) return CircularProgressIndicator();
            return Scaffold(
              appBar: AppBar(title: Text(mod ? "Aggiungi o modera i contenuti" : "Mandaci i tuoi appunti!"),),
              body: Scaffold(
                body: mod ? ModPage() : PlebPage(),
              ),
            );
          }
        );
      }
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