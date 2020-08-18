import 'package:flutter/material.dart';

const subjects = [
  {
    "name": "Analisi matematica I",
    "id": 0
  },
  {
    "name": "Fondamenti di Informatica I",
    "id": 1
  },
  {
    "name": "Geometria",
    "id": 2
  }
];


class SubjectsPage extends StatelessWidget {

  final String name = "Ingegneria informatica";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Appunti di $name"),),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200.0),
        itemCount: subjects.length,
        itemBuilder: (context, i) =>
          InkWell(
            child: Card(child: Center(child: Text(subjects[i]["name"],))),
            onTap:() => Navigator.pushNamed(context, "/subject", arguments: subjects[i]),
          )
      )
    );
  }
}

class SubjectPage extends StatelessWidget {
  SubjectPage(this.subject);

  final Map<String, Object> subject;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(subject["name"]),),
      body: Center(
        child: Text("qui ci saranno gli appunti"),
      ),
    );
  }
}