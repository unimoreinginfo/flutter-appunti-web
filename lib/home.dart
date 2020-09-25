import 'package:appunti_web_frontend/io.dart';
import 'package:appunti_web_frontend/platform.dart';
import 'package:flutter/material.dart';
import 'edit.dart' show LogoutButton;

const loremIpsum =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas congue maximus nisl, quis auctor justo lacinia id. Cras a magna a tellus dapibus dictum. Nam sed odio quis metus dictum luctus eu vel nibh. Praesent ut ultrices quam. Nulla porttitor, purus at mattis sagittis, quam urna consequat nibh, sit amet aliquet tortor augue ut nibh. Fusce finibus interdum blandit. In ut sapien vitae sem tristique sollicitudin. In eleifend odio bibendum, posuere dolor quis, interdum risus.";

class Illustration extends StatelessWidget {
  Illustration(this.name);

  final String name;

  @override
  Widget build(context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Image.network("/img/$name.png", height: 200.0));
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("appunti-web"),
          actions:
              getUserIdOrNull(tokenStorage) == null ? null : [LogoutButton()],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor),
                  child: Stack(alignment: Alignment.bottomLeft, children: [
                    Text(
                      "appunti-web",
                      style: TextStyle(color: Colors.white),
                    )
                  ])),
              InkWell(
                child: ListTile(
                    leading: Icon(Icons.computer),
                    title: Text("Ingegneria Informatica")),
                onTap: () {
                  Navigator.pushNamed(context, "/subjects");
                },
              )
            ],
          ),
        ),
        body: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyText2,
            textAlign: TextAlign.justify,
            child: ListView(padding: EdgeInsets.all(15.0), children: [
              Center(
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    width: 750.0,
                    child: Column(
                      children: [
                        Illustration("lesson"),
                        Text(
                            "La fonte di appunti più amata al mondo è tornata!",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline3),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                            "Sei pronto a passare da aver fatto 0 esami nei primi 2 anni a laurearti perfettamente nei tempi?"),
                        SizedBox(
                          height: 30,
                        ),
                        MaterialButton(
                          height: 50.0,
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          child: Text("Vai agli appunti"),
                          onPressed: () {
                            Navigator.pushNamed(context, "/subjects");
                          },
                        ),
                        Divider(height: 45.0),
                        Text("Appunti per tutti",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline4),
                        Illustration("read"),
                        Text(
                            "Non c'è bisogno di chiedere a qualcuno ogni volta o di scavare tra i messaggi inviati in qualche gruppo, e di certo non c'è bisogno di pagare per gli appunti: questa è la piattaforma di appunti dove chi decide di caricare qualcosa lo fa solo per aiutare gli altri, rendendo il tutto fruibile gratuitamente anche a te."),
                        Text(
                            "Non devi fare nulla, se non premere il tasto all'inizio di questa pagina e scegliere la materia di cui ti interessa avere gli appunti."),
                        Text(
                            "Se gli appunti di uno in particolare dei nostri benefattori ti interessano più degli altri, potrai cliccare sul suo nome e vedere tutti i contenuti che ha offerto alla comunità, insieme ad informazioni di contatto per incitarlo a caricare altra roba affinché tu possa riuscire a laurearti."),
                        Text("Risorse affidabili e controllate",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline4),
                        Illustration("control"),
                        Text(
                          "Il nostro team di moderazione è sempre al lavoro per controllare i file che vengono caricati e gli utenti che si registrano.",
                        ),
                        Text(
                          "Non rischierai mai di scaricare malware o contenuti protetti da copyright, in modo tale da operare sempre all'interno dei limiti esplicitamente autorizzati dai professori.",
                        ),
                        Text(
                            "Su questo sito troverai solo appunti affidabili, di qualità e al 100% legali."),
                        Text(
                          "E ti laurei pure, bastardo",
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text("Dai il tuo contributo",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline4),
                        Illustration("letsgo"),
                        Text(
                            "Se hai degli appunti fantastici da condividere con i compagni per migliorare l'esperienza di studio per l'intera comunità, crea un account e caricali!"),
                        Text("Non potrai caricare file enormi, però."),
                        FlatButton(
                            color: Theme.of(context).primaryColor,
                            textColor: Colors.white,
                            child: Text("Aggiunta appunti"),
                            onPressed: () =>
                                Navigator.pushNamed(context, "/edit"))
                      ],
                    )),
              )
            ])),
      );
}
