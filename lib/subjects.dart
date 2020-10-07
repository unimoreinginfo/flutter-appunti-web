import 'dart:async';

import 'package:flutter/material.dart';

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
            title: Text("Appunti di $name"),
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
                              title: Text(
                                  "Si è verificato un errore durante l'accesso alle materie"),
                              content: Text("${snapshot.error}"),
                            )));
                    return Text("si è verificato un errore");
                  }
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return SubjectsPageContents(snapshot.data);
                }),
          ),
        ));
  }
}

class SubjectsPageContents extends StatefulWidget {
  SubjectsPageContents(this.subjects);

  final List<Map<String, Object>> subjects;

  @override
  _SubjectsPageContentsState createState() => _SubjectsPageContentsState();
}

class _SubjectsPageContentsState extends State<SubjectsPageContents> {
  Future<List> getNotesFuture(int id) => backend.getNotes(subjectId: id);
  TextEditingController _searchController = TextEditingController();
  int _chosenSubject = -1;
  List<Map<String, Object>> data = null;
  Timer timer = null;
  String curQ = null;

  void searchDebounced(String q) async {
    List<Map<String, Object>> res;
    if (q == curQ) return;
    curQ = q;
    if (q.length < 2)
      setState(() {
        if (timer != null) {
          timer.cancel();
          timer = null;
        }
        data = null;
      });
    else {
      if (timer != null) timer.cancel();
      timer = Timer(Duration(seconds: 1), () async {
        res = await backend.search(q);
        setState(() {
          if (res.length == 0) {
            data = null;
          } else {
            data = res;
          }
          print("risultati ricerca: $data");
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
        Text(
          "Cerca appunti",
          style: Theme.of(context).textTheme.headline4,
        ),
        SizedBox(height: 15.0),
        Row(
          children: [
            Container(
              width: 150.0,
              child: DropdownButton(
                  value: _chosenSubject,
                  items: [DropdownMenuItem(value: -1, child: Text("Tutte"))] +
                      (widget.subjects
                          .map((subject) => DropdownMenuItem(
                              value: subject["id"],
                              child: Text(subject["name"])))
                          .toList()),
                  onChanged: (value) {
                    setState(() {
                      _chosenSubject = value;
                    });
                  }),
            ),
            SizedBox(
              width: 5.0,
            ),
            TextField(
                decoration: InputDecoration(labelText: "Cerca"),
                controller: _searchController,
                onChanged: searchDebounced),
            IconButton(
                onPressed: () => searchDebounced(_searchController.text),
                icon: Icon(Icons.search))
          ],
        ),
        SizedBox(height: 15.0),
        Text("Ultimi risultati"),
        SizedBox(height: 15.0),
        if (_searchController.text != "")
          DisplayNotes(data != null ? data : [], widget.subjects)
        else
          FutureBuilder(
            future: backend.getNotes(
                subjectId: _chosenSubject != -1 ? _chosenSubject : null),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                showDialog(
                    context: context,
                    child: AlertDialog(
                      title: Text("Si è verificato un errore"),
                      content: Text("${snapshot.error}"),
                    ));
                return Text("errore");
              }
              // TODO:implementare pagine

              if (!snapshot.hasData) return CircularProgressIndicator();
              return DisplayNotes(snapshot.data, widget.subjects);
            },
          )
      ],
    );
  }
}

class DisplayNotes extends StatelessWidget {
  DisplayNotes(this.data, this.subjects);

  final List<Map<String, Object>> subjects;
  final List<Map<String, Object>> data;

  final ScrollController _controller = ScrollController();

  Map getSubject(int id) {
    return subjects.where((sub) => sub["id"] == id).first;
  }

  double calculateScrollControlRatio() {
    double contentSize = _controller.position.maxScrollExtent;

    double contentToViewRatio =
        contentSize / _controller.position.viewportDimension;

    if (contentToViewRatio <= 1.0)
      return 1.0;
    else
      return 1 / contentToViewRatio;
  }

  @override
  Widget build(BuildContext context) {
    bool containsMoreInfo = data.length > 0 && data[0]["author_id"] != null;
    return Container(
      height: MediaQuery.of(context).size.height - 210.0,
      padding: EdgeInsets.all(16.0),
      child: ListView.builder(
        controller: _controller,
        itemCount: data.length,
        itemBuilder: (context, i) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Card(
                borderOnForeground: false,
                color: Colors.grey[200],
                child: DefaultTextStyle(
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodyText1,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getSubject(data[i]["subject_id"])["name"],
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        Text("Titolo: ${data[i]["title"]}"),
                        if (containsMoreInfo) DateText(data[i]["uploaded_at"]),
                        if (containsMoreInfo) AuthorInfo(data[i]["author_id"]),
                        FlatButton(
                            onPressed: () {
                              Navigator.pushNamed(context,
                                  '/notes/${data[i]["subject_id"]}/${data[i]["note_id"]}');
                            },
                            child:
                                Text("Vai ai file contenuti in questo appunto"))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
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
    return Text("Caricato il $day/$month/$year alle $hour:$minute");
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
        var name = snapshot.data["name"];
        var surname = snapshot.data["surname"];
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
