import 'package:flutter/material.dart';
import 'io.dart';
import 'platform.dart' as platform;

class EditPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getToken(platform.tokenStorage),
      builder: (context, snapshot)  {
        if(!snapshot.hasData) return CircularProgressIndicator();
        final String token = snapshot.data;
        if(snapshot.hasError) {
          Navigator.pushReplacementNamed(context, '/login');
        }        
        return FutureBuilder<bool>(
          future: isMod(token),
          builder: (context, snapshot) {
            final bool mod = snapshot.data;
            if(!snapshot.hasData) return CircularProgressIndicator();
            return Scaffold(
              appBar: AppBar(title: Text(mod ? "Aggiungi o modera i contenuti" : "Mandaci i tuoi appunti!"),),
              body: Scaffold(
                body: mod ? ModPage(token) : PlebPage(token),
              ),
            );
          }
        );
      }
    );
  }
}

class PlebPage extends StatelessWidget {
  PlebPage(this.jwt);

  final String jwt;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class ModPage extends StatelessWidget {
  ModPage(this.jwt);

  final String jwt;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}