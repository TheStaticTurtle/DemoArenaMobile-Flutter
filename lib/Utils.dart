
import 'package:url_launcher/url_launcher.dart';
bool isNumeric(String s) {
    if(s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
}

void printWrapped(String text) {
  final pattern = RegExp('.{1,1000}'); // 1000 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

void openUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class Error {
  dynamic error;
  dynamic stacktrace;
  Error(dynamic error,dynamic stacktrace) {
    this.error = error;
    this.stacktrace = stacktrace;
  }
}

enum LoginScreenState {
  Login,
  Login_in,
  Logged_in,
  LoadingCaptcha,
  EnterCaptcha,
  ValidatingCaptcha,
}
enum DisplayScreenState {
  Loading,
  Empty,
  Grades,
  Misses
}

enum ReturnState {
  Success,
  NoInternetError,
  GateInfoUnknownError,
  DemoarenaNoAMIGUS,
  DemoarenaScriptError,
  DemoarenaNoLT,
  DemoarenaUnknownError,
  SemesterCaptchaInvalid,
  SemesterINEInvalid,
  SemesterUnknownError
}

class Response {
  String message = "The opperation didn't suceded";
  Error err;
  ReturnState return_state;
  String data ="";
  Response(String message, String data, ReturnState return_state, Error err) {
    this.message = message;
    this.return_state = return_state;
    this.data = data;
    this.err = err;
  }
}
