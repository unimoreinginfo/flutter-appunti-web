import 'package:appunti_web_frontend/io.dart';
import 'package:appunti_web_frontend/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'edit.dart' show LogoutButton;

const loremIpsum =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas congue maximus nisl, quis auctor justo lacinia id. Cras a magna a tellus dapibus dictum. Nam sed odio quis metus dictum luctus eu vel nibh. Praesent ut ultrices quam. Nulla porttitor, purus at mattis sagittis, quam urna consequat nibh, sit amet aliquet tortor augue ut nibh. Fusce finibus interdum blandit. In ut sapien vitae sem tristique sollicitudin. In eleifend odio bibendum, posuere dolor quis, interdum risus.";

class Illustration extends StatelessWidget {
  Illustration(this.name);

  final String name;

  @override
  Widget build(context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Image.network("/img/$name.png",
          height: MediaQuery.of(context).size.width > 850 ? 275.0 : 150.0));
}

class LandingContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Illustration("lesson"),
      Text("La fonte di appunti più amata al mondo è tornata!",
          textAlign: TextAlign.center,
          style: MediaQuery.of(context).size.width > 850.0
              ? Theme.of(context).textTheme.headline3
              : Theme.of(context).textTheme.headline4),
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
    ]);
  }
}

class FirstExplanation extends StatelessWidget {
  @override
  Widget build(context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Illustration("read"),
      Text("Appunti per tutti",
          textAlign: TextAlign.center,
          style: MediaQuery.of(context).size.width > 850.0
              ? Theme.of(context).textTheme.headline4
              : Theme.of(context).textTheme.headline5),
      SizedBox(
        height: 30,
      ),
      Text(
          "Non c'è bisogno di chiedere a qualcuno ogni volta o di scavare tra i messaggi inviati in qualche gruppo, e di certo non c'è bisogno di pagare per gli appunti: questa è la piattaforma di appunti dove chi decide di caricare qualcosa lo fa solo per aiutare gli altri, rendendo il tutto fruibile gratuitamente anche a te."),
      SizedBox(
        height: 7.5,
      ),
      Text(
          "Non devi fare nulla, se non premere il tasto all'inizio di questa pagina e scegliere la materia di cui ti interessa avere gli appunti."),
      SizedBox(
        height: 7.5,
      ),
      Text(
          "Se gli appunti di uno in particolare dei nostri benefattori ti interessano più degli altri, potrai cliccare sul suo nome e vedere tutti i contenuti che ha offerto alla comunità, insieme ad informazioni di contatto per incitarlo a caricare altra roba affinché tu possa riuscire a laurearti."),
    ]);
  }
}

class SecondExplanation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Illustration("control"),
      Text("Risorse affidabili e controllate",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline4),
      SizedBox(
        height: 30,
      ),
      Text(
        "Il nostro team di moderazione è sempre al lavoro per controllare i file che vengono caricati e gli utenti che si registrano.",
      ),
      SizedBox(
        height: 7.5,
      ),
      Text(
        "Non rischierai mai di scaricare malware o contenuti protetti da copyright, in modo tale da operare sempre all'interno dei limiti esplicitamente autorizzati dai professori.",
      ),
      SizedBox(
        height: 7.5,
      ),
      Text(
        "Su questo sito troverai solo appunti affidabili, di qualità e al 100% legali.",
      ),
      SizedBox(
        height: 30,
      ),
      Text(
        "E ti laurei pure, bastardo",
        textAlign: TextAlign.start,
        style:
            TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
      ),
    ]);
  }
}

class ShareYourNotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Illustration("letsgo"),
        Text("Dai il tuo contributo",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline4),
        SizedBox(
          height: 30,
        ),
        Text(
            "Se hai degli appunti fantastici da condividere con i compagni per migliorare l'esperienza di studio per l'intera comunità, crea un account e caricali!"),
        SizedBox(
          height: 7.5,
        ),
        Text(
          "Non potrai caricare file enormi, però.",
        ),
        SizedBox(
          height: 30,
        ),
        FlatButton(
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            child: Text("Accedi e mandaci i tuoi appunti"),
            onPressed: () => Navigator.pushNamed(context, "/edit"))
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage;
  PageController _controller;
  bool showArrow;

  @override
  initState() {
    super.initState();
    currentPage = 0;
    _controller = PageController(initialPage: 0);
    showArrow = true;
  }

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
            style: MediaQuery.of(context).size.width > 850.0
                ? Theme.of(context).textTheme.bodyText1
                : Theme.of(context).textTheme.bodyText2,
            textAlign: TextAlign.justify,
            child: Center(
                child: Row(
                    mainAxisAlignment: MediaQuery.of(context).size.width > 850.0
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.center,
                    mainAxisSize: MediaQuery.of(context).size.width > 850.0
                        ? MainAxisSize.max
                        : MainAxisSize.min,
                    children: [
                  Container(
                    width: MediaQuery.of(context).size.width > 850.0
                        ? (MediaQuery.of(context).size.width - 750) / 6
                        : 0.0,
                  ),
                  Container(
                    padding: EdgeInsets.all(20.0),
                    width: MediaQuery.of(context).size.width > 850.0
                        ? 750.0
                        : MediaQuery.of(context).size.width * 90 / 100,
                    child: PageView(
                      scrollDirection: Axis.vertical,
                      controller: _controller,
                      physics: HomePageScrollPhysics(),
                      onPageChanged: (page) => setState(() {
                        print("Page: $page");
                        showArrow = false;
                        currentPage = page;
                      }),
                      children: [
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              LandingContent(),
                              if (showArrow)
                                IconButton(
                                    iconSize: 50.0,
                                    icon: Icon(Icons.arrow_downward),
                                    onPressed: () {
                                      _controller.nextPage(
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.linear);
                                    })
                            ]),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FirstExplanation(),
                              if (showArrow)
                                IconButton(
                                    iconSize: 50.0,
                                    icon: Icon(Icons.arrow_downward),
                                    onPressed: () {
                                      _controller.nextPage(
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.linear);
                                    })
                            ]),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SecondExplanation(),
                              if (showArrow)
                                IconButton(
                                    iconSize: 50.0,
                                    icon: Icon(Icons.arrow_downward),
                                    onPressed: () {
                                      _controller.nextPage(
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.linear);
                                    })
                            ]),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ShareYourNotes(),
                              if (showArrow)
                                IconButton(
                                    iconSize: 50.0,
                                    icon: Icon(Icons.arrow_downward),
                                    onPressed: () {
                                      _controller.nextPage(
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.linear);
                                    })
                            ])
                      ],
                    ),
                  ),
                  if (MediaQuery.of(context).size.width > 850.0)
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [0, 1, 2, 3]
                            .map((i) => RawMaterialButton(
                                  shape: CircleBorder(),
                                  textStyle: TextStyle(
                                    color: currentPage == i
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  fillColor: currentPage == i
                                      ? Theme.of(context).primaryColor
                                      : Colors.white,
                                  onPressed: () => _controller.animateToPage(i,
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.linear),
                                ))
                            .toList())
                ]))),
      );
}

class HomePageScrollPhysics extends PageScrollPhysics {
  const HomePageScrollPhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  SpringDescription get spring =>
      SpringDescription(mass: 0.0000001, stiffness: 2.0, damping: 1.0);

  @override
  HomePageScrollPhysics applyTo(ScrollPhysics ancestor) {
    return HomePageScrollPhysics(parent: buildParent(ancestor));
  }
}
