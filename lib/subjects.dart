import 'dart:async';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:string_trimmer/string_trimmer.dart';
import 'package:tuple/tuple.dart';

import 'platform.dart' as platform;
import 'utils.dart';
import 'backend.dart' as backend;
import 'edit.dart' show LogoutButton;
import 'io.dart';

class UsersSingleton {
  static final UsersSingleton _singleton = UsersSingleton._internal();

  factory UsersSingleton() {
    return _singleton;
  }

  Map users = {};

  Future<backend.User> getUser(String id) {
    if (users[id] != null)
      return users[id];
    else {
      users[id] = backend.getUser(id);
      return users[id];
    }
  }

  UsersSingleton._internal();
}

class SubjectsPage extends StatelessWidget {
  final String name = "Ingegneria informatica";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: SelectableText("Appunti di $name"),
            actions: getUserIdOrNull(platform.tokenStorage) == null
                ? null
                : [LogoutButton()]),
        body: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            width: 900.0,
            child: FutureBuilder(
                future: backend.getSubjects(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print("${snapshot.error}");
                    doItAsap(
                        context,
                        (context) => showDialog(
                            context: context,
                            child: AlertDialog(
                              title: SelectableText(
                                  "Si è verificato un errore durante l'accesso alle materie"),
                              content: SelectableText("${snapshot.error}"),
                            )));
                    return SelectableText("si è verificato un errore");
                  }
                  if (!snapshot.hasData)
                    return SizedBox(
                        width: 100.0,
                        height: 100.0,
                        child: Center(child: CircularProgressIndicator()));
                  return SubjectsPageContents(snapshot.data);
                }),
          ),
        ));
  }
}

class SubjectsPageContents extends StatefulWidget {
  SubjectsPageContents(this.subjects);

  final List<backend.Subject> subjects;

  @override
  _SubjectsPageContentsState createState() => _SubjectsPageContentsState();
}

class _SubjectsPageContentsState extends State<SubjectsPageContents> {
  TextEditingController _searchController = TextEditingController();
  ScrollController _controller = ScrollController();
  int _chosenSubject = -1;
  String query = null;
  Timer timer = null;
  Future<Tuple2<int, List<backend.Note>>> defaultFirstPage;
  List<Future<List<backend.Note>>> defaultOtherPages = [];
  Future<Tuple2<int, List<backend.Note>>> firstPage = null;
  List<Future<List<backend.Note>>> otherPages = null;

  void searchDebounced(String q) async {
    if (q == query) return;
    if (q.length < 2) {
      if (timer != null) {
        timer.cancel();
      }
      timer = Timer(Duration(milliseconds: 1000), () async {
        var dfp = await defaultFirstPage;
        setState(() {
          _chosenSubject = -1;
          firstPage = Future.value(Tuple2(dfp.item1, List.from(dfp.item2)));
          otherPages = List.from(defaultOtherPages);
          query = null;
        });
      });
    } else {
      if (timer != null) timer.cancel();
      timer = Timer(Duration(milliseconds: 1500), () async {
        otherPages.clear();
        firstPage = backend.searchFirstPage(q);
        int pageNumber = (await firstPage).item1;
        setState(() {
          _chosenSubject = -1;
          query = q;

          for (int i = 1; i < pageNumber; i++) {
            otherPages.add(backend.search(q, i + 1));
          }
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    defaultFirstPage = backend.getNotesFirstPage()
      ..then((value) {
        for (int i = 1; i < value.item1; i++) {
          defaultOtherPages.add(backend.getNotes(i + 1));
        }

        setState(() {
          firstPage = Future.value(Tuple2(value.item1, List.from(value.item2)));
          otherPages = List.from(defaultOtherPages);
        });
      });
  }

  @override
  Widget build(context) {
    if (otherPages == [] || firstPage == null)
      return Center(
        child: CircularProgressIndicator(),
      );
    return Column(
      children: [
        SizedBox(height: 15.0),
        SelectableText(
          "Cerca appunti",
          style: Theme.of(context).textTheme.headline4,
        ),
        SizedBox(height: 15.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 59.0,
              color: Color(0xFFEEEEEE),
              child: DropdownButton(
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 34,
                  value: _chosenSubject,
                  items: [
                        DropdownMenuItem(
                            value: -1, child: SelectableText("Tutte"))
                      ] +
                      (widget.subjects
                          .map((subject) => DropdownMenuItem(
                              value: subject.id,
                              child: SelectableText(trim(
                                  subject.name,
                                  MediaQuery.of(context).size.width > 700.00
                                      ? 25
                                      : 20,
                                  lastChars: 4))))
                          .toList()),
                  onChanged: (value) async {
                    firstPage = Future.value(Tuple2(0, []));
                    _searchController.text = "";
                    otherPages.clear();
                    if (value == -1) {
                      var dfp = await defaultFirstPage;
                      setState(() {
                        _chosenSubject = -1;
                        firstPage = Future.value(
                            Tuple2(dfp.item1, List.from(dfp.item2)));
                        otherPages = List.from(defaultOtherPages);
                      });
                      return;
                    }
                    firstPage = backend.getNotesFirstPage(subjectId: value);
                    int pageNumber = (await firstPage).item1;
                    setState(() {
                      _chosenSubject = value;

                      for (int i = 1; i < pageNumber; i++) {
                        otherPages
                            .add(backend.getNotes(i + 1, subjectId: value));
                      }
                    });
                  }),
            ),
            Expanded(
              flex: 3,
              child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    fillColor: Color(0xFFEEEEEE),
                    filled: true,
                    labelText: "Cerca",
                  ),
                  controller: _searchController,
                  onChanged: searchDebounced),
            ),
          ],
        ),
        SizedBox(height: 15.0),
        SelectableText("Ultimi risultati"),
        SizedBox(height: 15.0),
        FutureBuilder<Tuple2<int, List<backend.Note>>>(
            future: firstPage,
            builder: (context, bigSnapshot) {
              if (bigSnapshot.connectionState == ConnectionState.waiting)
                return Container(
                    height: 30.0,
                    width: 30.0,
                    child: Center(child: CircularProgressIndicator()));
              return Expanded(
                child: DraggableScrollbar.arrows(
                  backgroundColor: Colors.black,
                  controller: _controller,
                  heightScrollThumb: 100.0,
                  child: ListView.builder(
                      controller: _controller,
                      itemCount: bigSnapshot.data.item1,
                      itemBuilder: (context, i) => FutureBuilder(
                            future: i == 0
                                ? Future.value(bigSnapshot.data.item2)
                                : otherPages[i - 1],
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return CircularProgressIndicator();
                              else
                                return DisplayNotes(
                                    snapshot.data, widget.subjects);
                            },
                          )),
                ),
              );
            })
      ],
    );
  }
}

class DisplayNotes extends StatelessWidget {
  DisplayNotes(this.data, this.subjects);

  final List<backend.Subject> subjects;
  final List<backend.Note> data;

  backend.Subject getSubject(int id) {
    return subjects.where((sub) => sub.id == id).first;
  }

  @override
  Widget build(BuildContext context) {
    bool containsMoreInfo = data.length > 0 && data[0].author_id != null;
    return Column(
        children: List.generate(
            data.length,
            (i) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width > 500.0
                        ? 450.0
                        : MediaQuery.of(context).size.width,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(4.0)),
                    child: DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodyText2,
                      child: Card(
                        elevation: 0.0,
                        color: Color(0xfff5f6fa),
                        child: DefaultTextStyle(
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.bodyText1,
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SelectableText(
                                  getSubject(data[i].subject_id).name,
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                if (MediaQuery.of(context).size.width > 700.00)
                                  SizedBox(
                                    height: 7.5,
                                  ),
                                SelectableText("Titolo: ${data[i].title}"),
                                if (containsMoreInfo)
                                  DateText(data[i].uploaded_at),
                                if (containsMoreInfo)
                                  AuthorInfo(data[i].author_id),
                                if (MediaQuery.of(context).size.width > 700.00)
                                  SizedBox(
                                    height: 7.5,
                                  ),
                                FlatButton(
                                    color: Theme.of(context).primaryColor,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      Navigator.pushNamed(context,
                                          '/notes/${data[i].subject_id}/${data[i].note_id}');
                                    },
                                    child: Text(
                                        "Vai ai file contenuti in questo appunto"))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )));
  }
}

class DateText extends StatelessWidget {
  DateText(this.dateString);

  final String dateString;

  @override
  Widget build(BuildContext context) {
    var date = DateTime.parse(dateString).toLocal();
    var day = date.day;
    var month = date.month;
    var year = date.year;
    var hour = date.hour;
    var minute = date.minute;
    return SelectableText("Caricato il $day/$month/$year alle $hour:$minute");
  }
}

class AuthorInfo extends StatelessWidget {
  AuthorInfo(this.id);

  final String id;

  @override
  Widget build(context) {
    return FutureBuilder(
      future: UsersSingleton().getUser(id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        var name = snapshot.data.name;
        var surname = snapshot.data.surname;
        return InkWell(
          child: Text("Autore: $name $surname"),
          onTap: () {
            Navigator.pushNamed(context, "/users/$id");
          },
        );
      },
    );
  }
}
