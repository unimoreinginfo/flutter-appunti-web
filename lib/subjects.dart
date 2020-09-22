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
                                    "Si è verificato un errore durante l'accesso alle materie"))));
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
  // TODO: rework note fetching by subj, this will not be feasible with many subjects and notes

  // TODO: what if this fails?
  Future<List> getNotesFuture(int id) => backend.getNotes(subjectId: id);
  int selectedSubject = -1;
  List<Future<List>> notesFuture;
  List<Map<String, Object>> data = null;
  Timer timer = null;
  ScrollController _subjectsScrollController = ScrollController();

  void searchDebounced(String q) async {
    List<Map<String, Object>> res;
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
    notesFuture = widget.subjects
        .map((subject) => getNotesFuture(subject["id"]))
        .toList();
  }

  @override
  Widget build(context) {
    return Column(
      children: [
        SizedBox(height: 15.0),
        if (selectedSubject < 0)
          Column(
            children: [
              Text(
                "Cerca",
                style: Theme.of(context).textTheme.headline4,
              ),
              TextField(onChanged: searchDebounced),
            ],
          ),
        if (data == null)
          Column(children: [
            if (selectedSubject < 0)
              Text("oppure")
            else
              FlatButton(
                child: Text("RESET"),
                onPressed: () {
                  setState(() {
                    selectedSubject = -1;
                  });
                },
              ),
            Text(
              "Scegli una materia",
              style: Theme.of(context).textTheme.headline4,
            ),
            Row(
              children: [
                IconButton(
                    icon: Icon(Icons.arrow_left_outlined),
                    onPressed: () {
                      _subjectsScrollController.animateTo(
                          _subjectsScrollController.offset - 80.0,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.linear);
                    }),
                Container(
                  height: 100.0,
                  width: MediaQuery.of(context).size.width < 900.0
                      ? MediaQuery.of(context).size.width * 75 / 100
                      : 700,
                  padding: EdgeInsets.all(16.0),
                  child: ListView.builder(
                      controller: _subjectsScrollController,
                      itemCount: widget.subjects.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, i) => FlatButton(
                            child: Card(
                                margin: selectedSubject == i
                                    ? EdgeInsets.all(5.0)
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Center(
                                      child: Text(
                                    widget.subjects[i]["name"],
                                  )),
                                )),
                            onPressed: () => setState(() {
                              selectedSubject = i;
                            }),
                          )),
                ),
                IconButton(
                    icon: Icon(Icons.arrow_right_outlined),
                    onPressed: () {
                      _subjectsScrollController.animateTo(
                          _subjectsScrollController.offset + 80.0,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.linear);
                    })
              ],
            ),
          ]),
        if (data != null) SearchedNotes(data),
        if (data == null && selectedSubject >= 0)
          SubjectNotes(
              widget.subjects[selectedSubject], notesFuture[selectedSubject])
      ],
    );
  }
}

class SubjectNotes extends StatelessWidget {
  SubjectNotes(this.subject, this.notesFuture);

  final Map<String, Object> subject;
  final Future<List> notesFuture;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(children: [
        Text(subject["name"], style: Theme.of(context).textTheme.headline4),
        Text(
            "Prof. ${subject['professor_name']} ${subject['professor_surname']}"),
        FutureBuilder(
            future: notesFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                // TODO: better error handling
                print("notes: ${snapshot.data}");
                print("${snapshot.error}");
                doItAsap(
                    context,
                    (context) => showDialog(
                        context: context,
                        child: AlertDialog(
                            title: Text(
                                "Si è verificato un errore durante l'accesso agli appunti di ${subject["name"]}"))));
                return Text("Si è verificato un errore");
              }
              if (snapshot.connectionState == ConnectionState.waiting)
                return CircularProgressIndicator();
              final List<Map> notes = snapshot.data;
              print("notes: $notes");
              if (notes.length == 0)
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Non ci sono appunti per questa materia",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                );
              return Container(
                height: MediaQuery.of(context).size.height * 60 / 100,
                padding: EdgeInsets.all(16.0),
                child: ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, i) {
                      DateTime date = DateTime.parse(notes[i]["uploaded_at"]);
                      return FutureBuilder(
                          future: backend.getUser(notes[i]["author_id"]),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return CircularProgressIndicator();
                            var user = snapshot.data;
                            print(
                                "user name: ${user["name"]} ${user["surname"]}");
                            print("note title: ${notes[i]["title"]}");
                            return ListTile(
                                leading: Icon(Icons.note),
                                trailing: Text(
                                    "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}"),
                                title: Text("${notes[i]["title"]}"),
                                subtitle: InkWell(
                                  child: Text(
                                      "${user["name"]} ${user["surname"]}"),
                                  onTap: () => Navigator.pushNamed(
                                      context, "/users/${user['id']}"),
                                ),
                                onTap: () => Navigator.pushNamed(context,
                                    '/notes/${notes[i]["subject_id"]}/${notes[i]["note_id"]}'));
                          });
                    }),
              );
            })
      ]),
    );
  }
}

class SearchedNotes extends StatelessWidget {
  SearchedNotes(this.data);

  final List<Map<String, Object>> data;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 60 / 100,
      padding: EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, i) {
          return ListTile(
            leading: Icon(Icons.note),
            title: Text(data[i]["title"]),
            onTap: () {
              Navigator.pushNamed(
                  context, '/notes/${data[i]["subject_id"]}/${data[i]["id"]}');
            },
          );
        },
      ),
    );
  }
}
