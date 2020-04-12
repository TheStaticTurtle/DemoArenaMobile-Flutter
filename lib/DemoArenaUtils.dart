import 'dart:ffi';

import 'package:demoarenamobile_flutter_port/SSHManager.dart';

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

class DemoArenaUtils {
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

}