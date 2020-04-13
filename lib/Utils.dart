
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

class ResultParseError implements Exception {
  String cause;
  ResultParseError(this.cause);
}

void openUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}