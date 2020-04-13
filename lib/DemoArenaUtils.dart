import 'dart:ffi';
import 'dart:convert';

import 'package:demoarenamobile_flutter_port/SSHManager.dart';
import 'package:flutter/cupertino.dart';

import 'Utils.dart';

class BasicResponce {
  String message = "The opperation didn't suceded";
  bool success = false;
  dynamic err_obj;
  dynamic err_stacktrace;
  BasicResponce(String message, bool success, dynamic err_obj, dynamic err_stacktrace) {
    this.message = message;
    this.success = success;
    this.err_obj = err_obj;
    this.err_stacktrace = err_stacktrace;
  }
}

class AuthetificationResponse {
  String message = "The opperation didn't suceded";
  bool success = false;
  String b64capcha ="";
  dynamic err_obj;
  dynamic err_stacktrace;
  AuthetificationResponse(String message, bool success, String b64capcha,  dynamic err_obj,dynamic err_stacktrace) {
    this.message = message;
    this.success = success;
    this.b64capcha = b64capcha;
    this.err_obj = err_obj;
    this.err_stacktrace = err_stacktrace;
  }
}

class DemoArenaUtils {
  static const String _DEMOARENA_CasAuth_COMMAND = "python -c 'import requests,re,base64,pickle;CAS = \"https://cas.univ-fcomte.fr/cas/login\";session = requests.Session();resp = session.get(CAS, verify=False, allow_redirects=True);lt = re.findall(r\"(LT-.+.-cas\\.univ-fcomte\\.fr)\",resp.text);assert len(lt)==1;print(\"OK\");session.post(CAS, data={\"username\":base64.b64decode(\"##INSERT-USER-HERE##\"), \"password\":base64.b64decode(\"##INSERT-PASS-HERE##\"), \"lt\":lt[0], \"_eventId\":\"submit\",\"execution\":\"e1s1\" } , verify=False, allow_redirects=False);resp = session.get(\"https://demoarena.iut-bm.univ-fcomte.fr/entree.php\", verify=False, allow_redirects=True);resp = session.get(\"https://demoarena.iut-bm.univ-fcomte.fr/securimage/securimage_show.php\", verify=False, allow_redirects=True);print({\"cookies\":session.cookies.get_dict(),\"image\":base64.b64encode(resp.content)});f = open(\".demoarena-cookies\", \"wb\");pickle.dump(session.cookies, f);f.close()' 2> .demoarena-logs";
  static const String _DEMOARENA_DemoarenaSelect_COMMAND = "python -c 'import requests,base64,pickle;f = open(\".demoarena-cookies\", \"rb\");session = requests.Session();session.cookies.update(pickle.load(f));f.close();print(base64.b64encode(session.post(\"https://demoarena.iut-bm.univ-fcomte.fr/traitement.php\", data={\"nip_VAL\":base64.b64decode(\"##INSERT-INE-HERE##\"), \"capt_Code\":base64.b64decode(\"##INSERT-CAPTCHA-HERE##\")}, verify=False, allow_redirects=True).text.encode(\"UTF-8\")))' 2>> .demoarena-logs";
  static const String _DEMOARENA_DemoarenaCustomSelect_COMMAND = "python -c 'import requests,base64,pickle;f = open(\".demoarena-cookies\", \"rb\");session = requests.Session();session.cookies.update(pickle.load(f));f.close();print(base64.b64encode(session.post(\"https://demoarena.iut-bm.univ-fcomte.fr/traitement.php\", data={\"semestre\":base64.b64decode(\"##INSERT-ID-HERE##\")}, verify=False, allow_redirects=True).text.encode(\"UTF-8\")))' 2>> .demoarena-logs";

  SSHManager _sshManager;
  String _user_username;
  String _user_password;

  DemoArenaUtils(SSHManager man) {
    this._sshManager = man;
    this._user_username = "unknown";
    this._user_password = "unknown";
    this._sshManager.init("unknown","unknown");
  }

  void updateCredentials(String username, String password) {
    this._user_username = username;
    this._user_password = password;
  }

  Future<BasicResponce> connectToGateInfo({Function(BasicResponce) callback}) async {
    this._sshManager.init(this._user_username,this._user_password);
    try {
      await this._sshManager.connect();
    } catch(e, stacktrace) {
      return new BasicResponce("Failed to connec to gate-info",false, e,stacktrace);
    }
    return new BasicResponce("Connected to gate-info !",true, null, null);
  }

  Future<AuthetificationResponse> authenticateCASDemoarena({Function(BasicResponce) callback}) async {
    try {
      String command = DemoArenaUtils._DEMOARENA_CasAuth_COMMAND;
      command = command.replaceAll("##INSERT-USER-HERE##", base64Encode(utf8.encode(this._user_username)));
      command = command.replaceAll("##INSERT-PASS-HERE##", base64Encode(utf8.encode(this._user_password)));
      command = command.replaceAll("\n","").replaceAll("\r","");
      String authResult = await this._sshManager.execute(command);
      if(authResult.contains("OK")) {
        List<String> rawData = authResult.split("\n");
        if(rawData.length == 3) {
          Map<String, dynamic> data = jsonDecode(rawData[1].replaceAll("\'", "\""));
          if(data.containsKey("cookies")) {
            return AuthetificationResponse("Demoarena loaded!",true,data["image"],null,rawData);
          } else {
            dynamic e = new ResultParseError("Erreur, cookie AGIMUS non present: Mot de passe ou utilisateur incorrect");
            return AuthetificationResponse("User or password incorrect (Could also be a server failure)",false,"",e,e.cause);
          }
        } else {
          dynamic e = new ResultParseError("Erreur, la commande a retourner plus que 3 lignes (Erreur de l'application voir .demoarena.log)");
          return AuthetificationResponse("Failed at demoarena loading",false,"",e,e.cause);
        }
      } else {
        dynamic e = new ResultParseError("Erreur, impossible de lire le tag LT. (Deux problemes possible: Seveur CAS down ou erreur de l'application voir .demoarena-log)");
        return AuthetificationResponse("Failed at demoarena loading",false,"",e,e.cause);
      }
    } catch(e, stacktrace) {
      return AuthetificationResponse("Failed at demoarena loading",false,"",e,stacktrace);
    }
  }
}
