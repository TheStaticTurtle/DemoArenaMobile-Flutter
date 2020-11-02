import 'dart:convert';
import 'dart:developer';
import 'package:demoarenamobile_flutter_port/SSHManager.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'Utils.dart';
import 'DemoArenaClasses.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class DemoArenaUtils {
  static const String _DEMOARENA_CasAuth_COMMAND = "python -c 'import requests,re,base64,pickle,urllib3;urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning);CAS = \"https://cas.univ-fcomte.fr/cas/login\";session = requests.Session();resp = session.get(CAS, verify=False, allow_redirects=True);lt = re.findall(r\"(LT-.+.-cas\\.univ-fcomte\\.fr)\",resp.text);assert len(lt)==1;print(\"OK\");session.post(CAS, data={\"username\":base64.b64decode(\"##INSERT-USER-HERE##\"), \"password\":base64.b64decode(\"##INSERT-PASS-HERE##\"), \"lt\":lt[0], \"_eventId\":\"submit\",\"execution\":\"e1s1\" } , verify=False, allow_redirects=False);resp = session.get(\"https://demoarena.iut-bm.univ-fcomte.fr/entree.php\", verify=False, allow_redirects=True);resp = session.get(\"https://demoarena.iut-bm.univ-fcomte.fr/securimage/securimage_show.php\", verify=False, allow_redirects=True);print({\"cookies\":session.cookies.get_dict(),\"image\":base64.b64encode(resp.content)});f = open(\".demoarena-cookies\", \"wb\");pickle.dump(session.cookies, f);f.close()' 2> .demoarena-logs";
  static const String _DEMOARENA_DemoarenaSelect_COMMAND = "python -c 'import requests,base64,pickle,urllib3;urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning);f = open(\".demoarena-cookies\", \"rb\");session = requests.Session();session.cookies.update(pickle.load(f));f.close();print(base64.b64encode(session.post(\"https://demoarena.iut-bm.univ-fcomte.fr/traitement.php\", data={\"nip_VAL\":base64.b64decode(\"##INSERT-INE-HERE##\"), \"capt_Code\":base64.b64decode(\"##INSERT-CAPTCHA-HERE##\")}, verify=False, allow_redirects=True).text.encode(\"UTF-8\")))' 2>> .demoarena-logs";
  static const String _DEMOARENA_DemoarenaCustomSelect_COMMAND = "python -c 'import requests,base64,pickle,urllib3;urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning);f = open(\".demoarena-cookies\", \"rb\");session = requests.Session();session.cookies.update(pickle.load(f));f.close();print(base64.b64encode(session.post(\"https://demoarena.iut-bm.univ-fcomte.fr/traitement.php\", data={\"semestre\":base64.b64decode(\"##INSERT-ID-HERE##\")}, verify=False, allow_redirects=True).text.encode(\"UTF-8\")))' 2>> .demoarena-logs";

  bool _enable_debug = false;

  SSHManager _sshManager;
  String _user_username;
  String _user_password;

  String last_html;

  DemoArenaUtils(SSHManager man, bool enable_debug) {
    this._sshManager = man;
    this._user_username = "unknown";
    this._user_password = "unknown";
    this._sshManager.init("unknown", "unknown");
    this._enable_debug = enable_debug;
  }

  void updateCredentials(String username, String password) {
    this._user_username = username;
    this._user_password = password;
  }

  Future<Response> connectToGateInfo() async {
    this._sshManager.init(this._user_username, this._user_password);
    try {
      await this._sshManager.connect();
    } catch (e, stacktrace) {
      return new Response("Failed to connec to gate-info", null,
          ReturnState.GateInfoUnknownError, new Error(e, stacktrace));
    }
    return new Response(
        "Connected to gate-info", null, ReturnState.Success, null);
  }

  Future<Response> authenticateCASDemoarena() async {
    try {
      String command = DemoArenaUtils._DEMOARENA_CasAuth_COMMAND;
      command = command.replaceAll("##INSERT-USER-HERE##",
          base64Encode(utf8.encode(this._user_username)));
      command = command.replaceAll("##INSERT-PASS-HERE##",
          base64Encode(utf8.encode(this._user_password)));
      command = command.replaceAll("\n", "").replaceAll("\r", "");
      String authResult = await this._sshManager.execute(command);
      if(this._enable_debug) {
        log("[DAU] authResut = "+authResult);
      }
      if (authResult.contains("OK")) {
        List<String> rawData = authResult.split("\n");
        if (rawData.length == 3) {
          Map<String, dynamic> data = jsonDecode(
              rawData[1].replaceAll("\'", "\""));
          if (data.containsKey("cookies")) {
            return new Response(
                "Demoarena loaded!", data["image"], ReturnState.Success, null);
          } else {
            return new Response("User or password incorrect", null,
                ReturnState.DemoarenaNoAMIGUS, new Error("See stacktrace",
                    "Erreur, cookie AGIMUS non present: Mot de passe ou utilisateur incorrect"));
          }
        } else {
          return new Response("Failed at demoarena loading", null,
              ReturnState.DemoarenaScriptError, new Error("See stacktrace",
                  "Erreur, la commande a retourner plus que 3 lignes (Erreur de l'application voir .demoarena.log)"));
        }
      } else {
        return new Response(
            "Failed at demoarena loading", null, ReturnState.DemoarenaNoLT,
            new Error("See stacktrace",
                "Erreur, impossible de lire le tag LT. (Deux problemes possible: Seveur CAS down ou erreur de l'application voir .demoarena-log)"));
      }
    } catch (e, stacktrace) {
      return new Response("Failed at demoarena loading", null,
          ReturnState.DemoarenaUnknownError, new Error(e, stacktrace));
    }
  }

  Future<Response> validateCaptchaAndGetCurrentSemester(String captcha,
      String ine) async {
    try {
      String command = DemoArenaUtils._DEMOARENA_DemoarenaSelect_COMMAND;
      command = command.replaceAll(
          "##INSERT-CAPTCHA-HERE##", base64Encode(utf8.encode(captcha)));
      command = command.replaceAll(
          "##INSERT-INE-HERE##", base64Encode(utf8.encode(ine)));
      command = command.replaceAll("\n", "").replaceAll("\r", "");
      String result = await this._sshManager.execute(command);
      if(this._enable_debug) {
        log("[DAU] validateCaptchaAndGetCurrentSemester = "+result);
      }
      result = utf8.decode(
          base64Decode(result.replaceAll("\n", "").replaceAll("\r", "")));

      if (result.contains("La valeur du captcha")) {
        return new Response(
            "Captcha invalide", null, ReturnState.SemesterCaptchaInvalid,
            new Error("Captcha invalide", "Captcha invalide"));
      }
      if (result.contains("Utilisateur non authenti")) {
        var text = "Une licorne sauvage a casser l'application, essaye de la relancer";
        return new Response(
            "Numero etudiant incorrect", null, ReturnState.SemesterUnknownError,
            new Error(text, text));
      }
      if (result.contains("Num") && result.contains("tudiant(e) inconnu")) {
        return new Response(
            "Numero etudiant incorrect", null, ReturnState.SemesterINEInvalid,
            new Error(
                "Numero etudiant incorrect", "Numero etudiant incorrect"));
      }
      this.last_html = result;
      return new Response(
          "Connection reussie", result, ReturnState.Success, null);
    } catch (e, stacktrace) {
      return new Response(
          "Failed at captcha", null, ReturnState.SemesterUnknownError,
          new Error(e, stacktrace));
    }
  }

  Future<Response> getSemester(String semID) async {
    try {
      String command = DemoArenaUtils._DEMOARENA_DemoarenaCustomSelect_COMMAND;
      command = command.replaceAll( "##INSERT-ID-HERE##", base64Encode(utf8.encode(semID)));
      command = command.replaceAll("\n", "").replaceAll("\r", "");
      String result = await this._sshManager.execute(command);
      result = utf8.decode( base64Decode(result.replaceAll("\n", "").replaceAll("\r", "")));

      if(this._enable_debug) {
        log("[DAU] getSemester = "+result);
      }
      if (result.contains("La valeur du captcha")) {
        return new Response(
            "Captcha invalide", null, ReturnState.SemesterCaptchaInvalid,
            new Error("Captcha invalide", "Captcha invalide"));
      }
      if (result.contains("Utilisateur non authenti")) {
        var text = "Une licorne sauvage a casser l'application, essaye de la relancer";
        return new Response(
            "Numero etudiant incorrect", null, ReturnState.SemesterUnknownError,
            new Error(text, text));
      }
      if (result.contains("Num") && result.contains("tudiant(e) inconnu")) {
        return new Response(
            "Numero etudiant incorrect", null, ReturnState.SemesterINEInvalid,
            new Error(
                "Numero etudiant incorrect", "Numero etudiant incorrect"));
      }
      this.last_html = result;
      return new Response(
          "Connection reussie", result, ReturnState.Success, null);
    } catch (e, stacktrace) {
      return new Response(
          "Failed at captcha", null, ReturnState.SemesterUnknownError,
          new Error(e, stacktrace));
    }
  }

  User parseUserFormHTML() {
    var document = parse(this.last_html);

    User user = new User();


    Element semesterSelector = document.querySelector(
        "body > form > fieldset > p > select");

    if(document.outerHtml.contains("pas de semestre en cours")) {
      Semester sem = new Semester("NOSEM" ,"Aucun semestre en cour");
      user.semesters.add(sem);
      user.name = "";
      user.formation = "";
    }

    for (Element el in semesterSelector.children) {
      Semester sem = new Semester(el.attributes["value"] ,el.text);
      //sem.id = el.attributes["value"];
      //sem.name = el.text;
      user.semesters.add(sem);
    }

    if(document.outerHtml.contains("pas de semestre en cours")) {
      return user;
    }


    Element nameFormationSelector = document.querySelector(
        "body > div.bulletin > table > tbody > tr");
    user.name =
        nameFormationSelector.children[1].children[0].children[0].children[0]
            .text;
    user.formation =
        nameFormationSelector.children[1].children[0].children[0].children[1]
            .text;
    //user.group =
    //    nameFormationSelector.children[1].children[0].children[0].children[3]
    //        .text;
    //user.group = user.group.split(" ").length > 1 ? user.group.split(" ")[1] : user.group;

    Element absanceTable = document.querySelector("#absences");
    if (absanceTable != null) {
      int i = 0;
      for (Element el in absanceTable.getElementsByTagName("tr")) {
        if (i > 0) {
          Absence a = new Absence();
          a.from = el.getElementsByTagName("td")[0].text;
          a.to = el.getElementsByTagName("td")[1].text;
          a.justified = el.getElementsByTagName("td")[2].text == "Oui";
          a.cause = el.getElementsByTagName("td")[3].text;
          user.semesters[0].absences.add(a);
        }
        i++;
      }
    }

    user.semesters[0].done = document.outerHtml.contains(
        "Les informations contenues dans ce tableau sont définitives");

    Element gradesTable = document.querySelector(".notes_bulletin");
    if (gradesTable != null) {
      bool foundAverage = false;
      bool foundFirstUE = false;
      UE currentUE = new UE();
      Course currentCourse = new Course();

      int i = 0;
      for (Element el in gradesTable.getElementsByTagName("tr")) {
        if (i > 0) {

          if(el.innerHtml.contains("Moyenne générale")) {
            foundAverage = true;
            Grade g = new Grade();
            g.type = "MOYGEN";
            g.id = "MOYGEN";
            g.name = "Moyenne generale";
            g.coeff = -1;
            g.max_grade = -1;
            g.min_grade = -1;
            g.showId = false;

            String gradeText = el.children[1].text;
            List<String> gradesTexts = gradeText.split("/");

            try {
              g.grade = double.parse(gradesTexts[0]);
            } catch (e) {
              g.grade = -1;
            }
            try {
              g.outof = double.parse(gradesTexts[1]);
            } catch (e) {
              g.outof = -1;
            }


            RegExp exp2 = new RegExp(r"(\d+.\d+)/(\d+.\d+)");
            Iterable<RegExpMatch> matches2 = exp2.allMatches(el.outerHtml);
            if (matches2.length > 0) {
              var match = matches2.elementAt(0);
              g.min_grade = double.parse(match.group(1));
              g.max_grade = double.parse(match.group(2));
            }

            log(g.grade.toString());
            user.semesters[0].moyGen = g;

            i++;
            continue;
          }

          if (user.semesters[0].done) {
            if (el.attributes["class"] != null && el.attributes["class"].contains("notes_bulletin_row_ue")) {
              currentUE = new UE();

              RegExp exp = new RegExp(r"</span>(.*)<br>(.*)</td>");
              Iterable<RegExpMatch> matches = exp.allMatches(el.outerHtml);
              if (matches.length > 0) {
                var match = matches.elementAt(0);
                currentUE.id = match.group(1);
                currentUE.name = match.group(2);
              } else {
                currentUE.name = el.text;
              }
              currentUE.grade = double.parse(el.children[2].text);
              currentUE.coeff = double.parse(el.children[4].text);

              RegExp exp2 = new RegExp(r"(\d+.\d+)/(\d+.\d+)");
              Iterable<RegExpMatch> matches2 = exp2.allMatches(el.outerHtml);
              if (matches2.length > 0) {
                var match = matches2.elementAt(0);
                currentUE.min_grade = double.parse(match.group(1));
                currentUE.max_grade = double.parse(match.group(2));
              }

              user.semesters[0].ues.add(currentUE);
            }
            else {
              log(el.innerHtml);
              currentCourse = new Course();
              currentCourse.id = el.children[1].text;
              currentCourse.name = el.children[2].text;

              try {
                currentCourse.grade = double.parse(el.children[4].text);
              } catch (e) {
                currentCourse.grade = -1;
              }
              try {
                currentCourse.coeff = double.parse(el.children[6].text);
              } catch (e) {
                currentCourse.coeff = -1;
              }

              RegExp exp = new RegExp(r"(\\d+.\\d+)/(\\d+.\\d+)");
              Iterable<RegExpMatch> matches = exp.allMatches(el.outerHtml);
              if (matches.length > 0) {
                var match = matches.elementAt(0);
                currentCourse.min_grade = double.parse(match.group(1));
                currentCourse.max_grade = double.parse(match.group(2));
              }

              currentUE.courses.add(currentCourse);
            }
          } else {
            if (el.attributes["class"] != null && el.attributes["class"].contains("notes_bulletin_row_ue")) {
              currentUE = new UE();
              currentUE.semester = user.semesters[0];

              RegExp exp = new RegExp(r"</span>(.*)<br>(.*)</td>");
              Iterable<RegExpMatch> matches = exp.allMatches(el.outerHtml);
              if (matches.length > 0) {
                var match = matches.elementAt(0);
                currentUE.id = match.group(1);
                currentUE.name = match.group(2);
              } else {
                currentUE.name = el.text;
              }

              try {
                currentUE.grade = double.parse(el.children[2].text);
              } catch (e) {
                currentUE.grade = -1;
              }
              try {
                currentUE.coeff = double.parse(el.children[4].text);
              } catch (e) {
                currentUE.coeff = -1;
              }

              cupertino.debugPrint(currentUE.grade.toString());

              currentUE.min_grade = -1;
              currentUE.max_grade = -1;

              currentUE.semester = user.semesters[0];

              user.semesters[0].ues.add(currentUE);
            }
            else if (el.attributes["class"] != null && el.attributes["class"].contains("toggle4")) {
              Grade grade = new Grade();

              grade.name = el.children[3].text;
              grade.semester = user.semesters[0];

              String coeffText = el.children[6].text.replaceAll("(", "")
                  .replaceAll(")", "");
              if (coeffText.isEmpty) {
                grade.coeff = -1;
              } else {
                grade.coeff = double.parse(coeffText);
              }

              String gradeText = el.children[4].text;
              List<String> gradesTexts = gradeText.split("/");

              try {
                grade.grade = double.parse(gradesTexts[0]);
              } catch (e) {
                grade.grade = -1;
              }
              try {
                grade.outof = double.parse(gradesTexts[1]);
              } catch (e) {
                grade.outof = -1;
              }

              grade.max_grade = -1;
              grade.min_grade = -1;

              grade.id = "None_" + grade.name;
              grade.showId = false;
              grade.type = "GRADE";

              currentCourse.grades.add(grade);
            }
            else {
              currentCourse = new Course();
              currentCourse.semester = user.semesters[0];
              currentCourse.id = el.children[1].text;
              currentCourse.name = el.children[2].text;
              try {
                currentCourse.grade = double.parse(el.children[4].text);
              }
              catch (e) {
                currentCourse.grade = -1;
              }
              try {
                currentCourse.coeff = double.parse(el.children[6].text);
              }
              catch (e) {
                currentCourse.coeff = -1;
              }

              RegExp exp = new RegExp(r"(\d+.\d+)/(\d+.\d+)");
              Iterable<RegExpMatch> matches = exp.allMatches(el.outerHtml);
              cupertino.debugPrint(matches.toList().toString());
              if (matches.length > 0) {
                var match = matches.elementAt(0);
                try {
                  currentCourse.min_grade = double.parse(match.group(1));
                  currentCourse.max_grade = double.parse(match.group(2));
                } catch (e) {
                  currentCourse.min_grade = -1;
                  currentCourse.max_grade = -1;
                }
              }
              currentUE.courses.add(currentCourse);
            }
          }
        }
        i++;
      }if(foundFirstUE) {
        user.semesters[0].ues.add(currentUE);
      }

      for(UE ue in user.semesters[0].ues) {
        if(ue.name.toLowerCase().contains("bonus")) {
          double totalNotes = 0;
          double totalCoeff = 0;
          for(Course cr in ue.courses) {
            if(cr.grade >= 0) {
              totalNotes += cr.grade * cr.coeff;
              totalCoeff += cr.coeff;
            }
          }
          Grade moy = new Grade();
          moy.id = "BONUS";
          moy.name = ue.id;
          moy.coeff = -1;
          moy.grade = totalCoeff > 0 ? ((totalNotes / totalCoeff)*100.0).round() /100.0 : -1;
          moy.max_grade = -1;
          moy.min_grade = -1;
          moy.outof = -1;
          moy.type = "BONUS";
          moy.showId = false;
          user.semesters[0].uesMoy.add(moy);

        } else {
          double totalNotes = 0;
          double totalCoeff = 0;
          for(Course cr in ue.courses) {
            if(cr.grade >= 0) {
              totalNotes += cr.grade * cr.coeff;
              totalCoeff += cr.coeff;
            }
          }
          Grade moy = new Grade();
          moy.id = "MOY";
          moy.name = ue.name;
          moy.coeff = ue.coeff;
          moy.grade = totalCoeff > 0 ? ((totalNotes / totalCoeff)*100.0).round() /100.0 : -1;
          moy.max_grade = -1;
          moy.min_grade = -1;
          moy.type = "MOY";
          moy.showId = false;
          user.semesters[0].uesMoy.add(moy);
        }
      }

      if(!foundAverage) {
        double totalNotes = 0.0;
        double totalCoeff = 0.0;
        double noteOffset = 0.0;
        for(Grade gr in user.semesters[0].uesMoy) {
          if(gr.grade != -1) {
            if(gr.type == "MOY") {
              totalNotes += gr.grade * gr.coeff;
              totalCoeff += gr.coeff;
            }
            if(gr.type == "BONUS") {
              noteOffset += gr.grade;
            }
          }
        }
        Grade g = new Grade();
        g.type = "MOYGEN";
        g.id = "MOYGEN";
        g.name = "Moyenne generale";
        g.coeff = -1;
        g.max_grade = -1;
        g.min_grade = -1;
        g.grade = totalCoeff > 0 ? ((totalNotes / totalCoeff)*100.0).round() /100.0 : -1;
        g.grade += noteOffset;
        g.showId = false;
        user.semesters[0].moyGen = g;
      }
    }

    return user;
  }
}
