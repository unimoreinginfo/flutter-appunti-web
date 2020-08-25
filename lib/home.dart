import 'package:flutter/material.dart';

const loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas congue maximus nisl, quis auctor justo lacinia id. Cras a magna a tellus dapibus dictum. Nam sed odio quis metus dictum luctus eu vel nibh. Praesent ut ultrices quam. Nulla porttitor, purus at mattis sagittis, quam urna consequat nibh, sit amet aliquet tortor augue ut nibh. Fusce finibus interdum blandit. In ut sapien vitae sem tristique sollicitudin. In eleifend odio bibendum, posuere dolor quis, interdum risus.";

class Illustration extends StatelessWidget {
  Illustration(this.name);

  final String name;

  @override
  Widget build(context) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Image.network("/img/$name.png", height: 200.0)
    );
}

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text("appunti-web"),
    ),
    drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(decoration: BoxDecoration(color: Theme.of(context).primaryColor), child: Stack(alignment: Alignment.bottomLeft,children: [Text("appunti-web", style: TextStyle(color: Colors.white),)])),
          InkWell(child: ListTile(leading: Icon(Icons.computer), title: Text("Ingegneria Informatica")), onTap: () {
            Navigator.pushNamed(context, "/subjects");
          },)
        ],
      ),
    ),
    body: Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.0),
        width: 750.0,
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyText2,
          textAlign: TextAlign.justify,
          child: ListView(
          padding: EdgeInsets.all(15.0),
          children : [
            Illustration("lesson"),
           Text("Appunti qua,\nlorem ipsum fanglerio", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline3),
            SizedBox(height: 30,),
            Text("La risorsa principale di fanglerico fanglerioso e robe fantastiche ez clap ciaooo"),
            SizedBox(height: 30,),
            MaterialButton(
              height: 50.0,
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              child: Text("Sgancia gli appunti bastardo"),
              onPressed: () {
                Navigator.pushNamed(context, "/subjects");
              },
            ),
            Divider(height: 45.0),
            Text("Appunti per tutti", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline4),
            Illustration("read"),
            Text(loremIpsum),
            SizedBox(height: 15,),
            Text("Risorse affidabili e controllate", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline4),
            Illustration("control"),
            Text(loremIpsum,),
            SizedBox(height: 15,),
            Text("E ti laurei pure, bastardo", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline4),
            Illustration("letsgo"),
            Text(loremIpsum),
            FlatButton(color: Theme.of(context).primaryColor, textColor: Colors.white, child: Text("Mandaci i tuoi appunti"), onPressed: () => Navigator.pushNamed(context, "/edit"))
          ]
        ),
        )
      ),
    ),
  );
}