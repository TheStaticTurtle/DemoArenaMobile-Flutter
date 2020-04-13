import 'package:flutter/cupertino.dart';
import 'package:ssh/ssh.dart';


class SSHManager {
  SSHClient client;

  void init(String username, String password) {
    this.client = new SSHClient(
      host: "gate-info.iut-bm.univ-fcomte.fr",
      port: 22,
      username: username,
      passwordOrKey: password,
    );
  }

  Future<void> connect() async {
    await this.client.connect();
  }

  Future<String> execute(String command) async{
    return await client.execute(command);
  }

  void disconnect() async{
    await this.client.disconnect();
  }
}

