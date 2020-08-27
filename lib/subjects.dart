import 'package:flutter/material.dart';

import 'dart:convert' show json;

import 'note.dart';
import 'platform.dart';
import 'consts.dart';
import 'utils.dart';



class SubjectsPage extends StatelessWidget {

  final String name = "Ingegneria informatica";

  Future<Map> get subjectsFuture async => json.decode(await httpClient.read("$baseUrl/subjects"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Appunti di $name"),),
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


  Future<List> getNotesFuture(id) async => json.decode(await httpClient.read("$baseUrl/notes?subjectId=$id"));
  int selectedSubject = -1;
  List<Future<List>> notesFuture;

  @override
  void initState() {
    super.initState();
    notesFuture = widget.subjects.map(
      (subject) => getNotesFuture(subject["id"])
    );
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
              InkWell(
                child: Card(child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(child: Text(widget.subjects[i]["name"],)),
                )),
                onTap:() => setState(() {
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
  Future<Map> getUser(id) async => json.decode(await httpClient.read("$baseUrl/users/$id"));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(subject["name"], style: Theme.of(context).textTheme.headline4),
        FutureBuilder(
          future: notesFuture,
          builder: (context, snapshot) {
            if(snapshot.hasError) {
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
            if(!snapshot.hasData) return CircularProgressIndicator();
            final List<Map> notes = snapshot.data;
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, i) {
                return FutureBuilder(
                  future: getUser(notes[i]["author_id"]),
                  builder: (context, snapshot) {
                    if(!snapshot.hasData) return CircularProgressIndicator();
                    final user = snapshot.data;
                    return Note(
                      authorName: "${user["name"]} ${user["surname"]}",
                      authorId: notes[i]["author_id"],
                      name: notes[i]["title"],
                      uploadedAt: DateTime.parse(notes[i]["uploaded_at"]),
                      downloadUrl: "$baseUrl/${notes[i]["storage_url"]}",
                      userData: user,
                      notesData: notes[i]
                    );
                  }
                );
              }
            );
          }
        )
      ]
    );
    
  }
}
