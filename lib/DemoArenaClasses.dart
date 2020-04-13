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