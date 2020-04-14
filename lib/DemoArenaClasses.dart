import 'package:demoarenamobile_flutter_port/LoginScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class User {
  String name;
  String formation;
  List<Semester> semesters = new List<Semester>();
}

class Semester {
  String id;
  String name;
  List<UE> ues = new List<UE>();
  List<Grade> uesMoy = new List<Grade>();
  Grade moyGen;
  List<Absence> absences = new List<Absence>();
  bool done = false;

  Semester(String s, String t) {
    id = s;
    name = t;
  }

  List<Grade> compactAll() {
    List<Grade> list = new  List<Grade>();
    if(this.moyGen != null) {
      list.add(this.moyGen);
    }
    for(Grade ue in this.uesMoy) {
      list.add(ue);
    }
    for(UE ue in this.ues) {
      list.add(ue);
      for(Course course in ue.courses) {
        list.add(course);
        for(Grade grade in course.grades) {
          list.add(grade);
        }
      }
    }
    return list;
  }
}

class Grade {
  String id;
  String name;
  double grade = 0;
  double outof = 20;
  double min_grade = 0;
  double max_grade = 0;
  double coeff = 0;
  String type = "GRADE";
  bool showId = true;

  Map<String,Color> colorsForType =  {
    "GRADE": Color.fromARGB(6,60,255,0),
    "COURSE": Color.fromARGB(13,255,210,0),
    "UE": Color.fromARGB(20, 255,40,0),
    "BONUS": Color.fromARGB(20,25,170,245),
    "MOY": Color.fromARGB(20,25,170,245),
    "MOYGEN": Color.fromARGB(33,27,171,246),
  };

  Map<String,EdgeInsets> paddingForType =  {
    "GRADE": EdgeInsets.only(left: 30,bottom: 10,top: 10,right: 16),
    "COURSE": EdgeInsets.only(left: 20,bottom: 10,top: 10,right: 16),
    "UE": EdgeInsets.only(left: 10,bottom: 10,top: 10,right: 16),
    "BONUS": EdgeInsets.only(left: 20,bottom: 10,top: 10,right: 16),
    "MOY": EdgeInsets.only(left: 20,bottom: 10,top: 10,right: 16),
    "MOYGEN": EdgeInsets.only(left: 10,bottom: 10,top: 10,right: 16),
  };

  Widget buildRender() {
    return Container(
      constraints: new BoxConstraints(
        minHeight: 70,
      ),
      color: colorsForType[this.type],
      child: Padding(
        padding: paddingForType[this.type],
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment:MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                (this.showId ? this.id+ ": " : "")  + this.name,
                style: TextStyle(
                  fontSize: 19
                ),
              ),
              Table(
                columnWidths: {0: FractionColumnWidth(.4)},
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child: Text(
                          " "+(this.grade>=0 ? "Note: "+this.grade.toString()+(this.outof != -1 ? "/"+this.outof.toString() : "") : "Non noter"),
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Text(
                          " "+(this.min_grade >=0 ? "Min" : "") + (this.max_grade >=0 ? "/Max/" : "") + (this.coeff >=0 ? "Coeff" : "") + " " +
                            (this.min_grade >=0 ? this.min_grade.toString()+"" : "") + (this.max_grade >=0 ? "/"+this.max_grade.toString()+"/" : "") + (this.coeff >=0 ? this.coeff.toString() : ""),
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.black45,
                          ),
                        ),
                      )
                    ]
                  )
                ],
              )
            ],
          )
        )
      )
    );
  }
}

class UE extends Grade {
  List<Course> courses = new  List<Course>();
  UE() {
    this.type = "UE";
  }
}

class Course extends Grade {
  List<Grade> grades = new List<Grade>();
  Course() {
    this.type = "COURSE";
  }
}

class Absence {
  String from;
  String to;
  bool justified;
  String cause;
}

/*
Container(
child: Table(
columnWidths: {0: FractionColumnWidth(.18)},
children: [
TableRow(children: [
TableCell(
verticalAlignment: TableCellVerticalAlignment
    .middle,
child: Text("De: ",
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold
),
),
),
]),
],
),
);
*/