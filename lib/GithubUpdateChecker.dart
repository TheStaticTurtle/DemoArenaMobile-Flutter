import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GithubUpdateChecker {
  String repoUrl;
  String currentVersionTag;

  GithubUpdateChecker(String repoUrl, String currentVersionTag) {
    this.currentVersionTag = currentVersionTag;
    this.repoUrl = repoUrl;
  }

  Future<bool> checkForInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('github.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<String> getLatestReleaseTag() async {
    try {
      String api = "https://api.github.com/repos/" + this.repoUrl +
            "/releases/latest";
      http.Response r = await http.get(Uri.parse(api));

      if (r.statusCode == 200) {
        Map<String, dynamic> data = json.decode(r.body);
        if (data.containsKey("tag_name")) {
          return data["tag_name"].toString();
        }
        return "notag";
      } else {
        return "error";
      }
    } on Exception catch (_) {
      return "error";
    }
  }
}