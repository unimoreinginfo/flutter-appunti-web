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

  void searchDebounced(String q) async {
    if (q == query) return;
    if (q.length < 2)
      setState(() {
        if (timer != null) {
          timer.cancel();
          timer = null;
        }
        query = null;
      });
    else {
      if (timer != null) timer.cancel();
      timer = Timer(Duration(seconds: 1), () async {
        setState(() {
          query = q;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(context) {
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
                  onChanged: (value) {
                    setState(() {
                      _chosenSubject = value;
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
        if (_searchController.text != "")
          FutureBuilder<Tuple2<int, List<backend.Note>>>(
              future: backend.searchFirstPage(query),
              builder: (context, bigSnapshot) {
                if (bigSnapshot.connectionState == ConnectionState.waiting)
                  return Container(
                      height: 30.0,
                      width: 30.0,
                      child: Center(child: CircularProgressIndicator()));
                return Expanded(
                  child: DraggableScrollbar(
                    controller: _controller,
                    backgroundColor: Colors.black,
                    scrollThumbBuilder: (
                      Color backgroundColor,
                      Animation<double> thumbAnimation,
                      Animation<double> labelAnimation,
                      double height, {
                      labelConstraints,
                      Text labelText,
                    }) {
                      return Image.network(
                        "/img/scrollbar.jpg",
                        height: height,
                        repeat: ImageRepeat.repeatY,
                        width: 30.0,
                      );
                    },
                    child: ListView.builder(
                        controller: _controller,
                        itemCount: bigSnapshot.data.item1,
                        itemBuilder: (context, i) => FutureBuilder(
                              future: i == 0
                                  ? Future.value(bigSnapshot.data.item2)
                                  : backend.search(query, i + 1),
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
        else
          FutureBuilder<Tuple2<int, List<backend.Note>>>(
              future: backend.getNotesFirstPage(
                  subjectId: _chosenSubject == -1 ? null : _chosenSubject),
              builder: (context, bigSnapshot) {
                if (bigSnapshot.connectionState == ConnectionState.waiting)
                  return Container(
                      height: 30.0,
                      width: 30.0,
                      child: Center(child: CircularProgressIndicator()));
                return Expanded(
                  child: DraggableScrollbar(
                    controller: _controller,
                    backgroundColor: Colors.black,
                    scrollThumbBuilder: (
                      Color backgroundColor,
                      Animation<double> thumbAnimation,
                      Animation<double> labelAnimation,
                      double height, {
                      labelConstraints,
                      Text labelText,
                    }) {
                      return Image.network(
                        "/img/scrollbar.jpg",
                        height: height,
                        repeat: ImageRepeat.repeatY,
                        width: 30.0,
                      );
                    },
                    child: ListView.builder(
                        controller: _controller,
                        itemCount: bigSnapshot.data.item1,
                        itemBuilder: (context, i) {
                          return FutureBuilder(
                            future: i == 0
                                ? Future.value(bigSnapshot.data.item2)
                                : backend.getNotes(i + 1,
                                    subjectId: _chosenSubject != -1
                                        ? _chosenSubject
                                        : null),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                showDialog(
                                    context: context,
                                    child: AlertDialog(
                                      title: Text("Si è verificato un errore"),
                                      content:
                                          SelectableText("${snapshot.error}"),
                                    ));
                                return SelectableText("errore");
                              }
                              // TODO:implementare pagine

                              if (!snapshot.hasData)
                                return CircularProgressIndicator();
                              return DisplayNotes(
                                  snapshot.data, widget.subjects);
                            },
                          );
                        }),
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
      future: backend.getUser(id),
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
