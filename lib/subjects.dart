import 'package:flutter/material.dart';

import 'note.dart';
import 'platform.dart' as platform;
import 'utils.dart';
import 'backend.dart' as backend;
import 'io.dart';

class SubjectsPage extends StatelessWidget {
  final String name = "Ingegneria informatica";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Appunti di $name"),
          actions: [
            if (getUserIdOrNull(platform.tokenStorage) != null)
              IconButton(
                  onPressed: () {
                    LoginManager.logOut(platform.tokenStorage);
                    Navigator.pushNamed(context, '/');
                  },
                  icon: Icon(Icons.logout))
          ],
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            width: 900.0,
            child: FutureBuilder(
                future: backend.getSubjects(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
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
              TextField(
                onChanged: (q) async {
                  List<Map<String, Object>> res;
                  if (q.length == 0)
                    setState(() {
                      data = null;
                    });
                  else {
                    res = await backend.search(q);
                    setState(() {
                      if (res.length == 0) {
                        data = null;
                      } else {
                        data = res;
                      }
                      print("risultati ricerca: $data");
                    });
                  }
                },
              ),
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
            Container(
              height: 100.0,
              padding: EdgeInsets.all(16.0),
              child: ListView.builder(
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
                print("notes: ${snapshot.data}");
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
                                child:
                                    Text("${user["name"]} ${user["surname"]}"),
                                onTap: () => Navigator.pushNamed(
                                    context, '/profile',
                                    arguments: [ProvidedArg.data, user]),
                              ),
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NotePage(
                                              noteDataFuture: backend.getNote(
                                            notes[i]["subject_id"],
                                            notes[i]["note_id"],
                                          )))),
                            );
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
    // TODO: implement build
    return Container(
      height: MediaQuery.of(context).size.height * 60 / 100,
      padding: EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, i) {
          // TODO: aspettare progressi backend
          // DateTime date = DateTime.parse(data[i]["uploaded_at"]);
          return ListTile(
            leading: Icon(Icons.note),
            title: Text(data[i]["title"]),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotePage(
                              noteDataFuture: backend.getNote(
                            '${data[i]["subject_id"]}',
                            data[i]["id"],
                          ))));
            },
          );
        },
      ),
    );
  }
}
