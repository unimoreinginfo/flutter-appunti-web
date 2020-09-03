import 'package:flutter/material.dart';


import 'note.dart';
import 'platform.dart' as platform;
import 'utils.dart';
import 'backend.dart' as backend;
import 'io.dart';


class SubjectsPage extends StatelessWidget {

  final String name = "Ingegneria informatica";

  // TODO: what if this fails?
  Future<List<Map>> get subjectsFuture => backend.getSubjects(platform.httpClient);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Appunti di $name"),
        actions: [
          if(getUserIdOrNull(platform.tokenStorage) != null)
            IconButton(
              onPressed: () {LoginManager.logOut(platform.tokenStorage); Navigator.pushNamed(context, '/');},
              icon: Icon(Icons.logout)
            )
        ],
      ),
      body: FutureBuilder(
        future: subjectsFuture,
        builder: (context, snapshot) {
          if(snapshot.hasError) {
            doItAsap(context, (context) =>
              showDialog(
                context: context,
                child: AlertDialog(
                  title: Text("Si è verificato un errore durante l'accesso alle materie")
                )
              )
            );
            return Text("si è verificato un errore");
          }
          if(!snapshot.hasData) return CircularProgressIndicator();
          return SubjectsPageContents(snapshot.data);
        }
      )
    );
  }
}

class SubjectsPageContents extends StatefulWidget {
  SubjectsPageContents(this.subjects);

  final List<Map<String, Object>> subjects;

  @override
  _SubjectsPageContentsState createState() => _SubjectsPageContentsState();
}


class _SubjectsPageContentsState extends State<SubjectsPageContents> {

  // TODO: what if this fails?
  Future<List> getNotesFuture(int id) => backend.getNotes(platform.httpClient, subjectId: id);
  int selectedSubject = -1;
  List<Future<List>> notesFuture;

  @override
  void initState() {
    super.initState();
    notesFuture = widget.subjects.map(
      (subject) => getNotesFuture(subject["id"])
    ).toList();
  }

  @override
  Widget build(context) {
    return Column(
      children: [
        Text("Scegli una materia", style: Theme.of(context).textTheme.headline5,),
        Container(
          height: 100.0,
          child: ListView.builder(
            itemCount: widget.subjects.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, i) =>
              FlatButton(
                child: Card(
                  margin: selectedSubject == i ? EdgeInsets.all(5.0) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(child: Text(widget.subjects[i]["name"],)),
                  )
                ),
                onPressed:() => setState(() {
                  selectedSubject = i;
                }),
              )
          ),
        ),
        if(selectedSubject >= 0)
          SubjectNotes(widget.subjects[selectedSubject], notesFuture[selectedSubject])
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
    // TODO: make responsive, just like the home and login page
    print("Trying to build subjectnotes");
    return Column(
      children: [
        Text(subject["name"], style: Theme.of(context).textTheme.headline4),
        Text("Prof. ${subject['professor_name']} ${subject['professor_surname']}"),
        FutureBuilder(
          future: notesFuture,
          builder: (context, snapshot) {
            if(snapshot.hasError) {
              print("notes: ${snapshot.data}");
              doItAsap(context, (context) =>
                showDialog(
                  context: context,
                  child: AlertDialog(
                    title: Text("Si è verificato un errore durante l'accesso agli appunti di ${subject["name"]}")
                  )
                )
              );
              return Text("Si è verificato un errore");
            }
            if(snapshot.connectionState == ConnectionState.waiting) return CircularProgressIndicator();
            final List<Map> notes = snapshot.data;
            print("notes: $notes");
            if(notes.length == 0) return Text("Non ci sono appunti per questa materia", style: Theme.of(context).textTheme.headline5,);
            return Container(
              height: MediaQuery.of(context).size.height*70/100,
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, i) {
                  return FutureBuilder(
                    future: backend.getUser(notes[i]["author_id"], platform.httpClient),
                    builder: (context, snapshot) {
                      print("user: ${snapshot.data}");
                      print("note: ${notes[i]}");
                      if(!snapshot.hasData) return CircularProgressIndicator();
                      var user = snapshot.data;
                      print("user name: ${user["name"]} ${user["surname"]}");
                      print("note title: ${notes[i]["title"]}");
                      return ListTile(
                        leading: Icon(Icons.note),
                        title: Text("${notes[i]["title"]}"),
                        subtitle: FlatButton(
                          child: Text("${user["name"]} ${user["surname"]}"),
                          onPressed: () => Navigator.pushNamed(context, '/profile', arguments: [ProvidedArg.data, user]),
                        ),                        
                        onTap:() => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NotePage(noteDataFuture: backend.getNote(notes[i]["subject_id"], notes[i]["note_id"], platform.httpClient)))
                        ),
                      );
                    }
                  );
                }
              ),
            );
          }
        )
      ]
    ); 
  }
}