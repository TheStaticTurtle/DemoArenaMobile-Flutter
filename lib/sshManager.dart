import 'package:ssh/ssh.dart';


class SSHManager {
  SSHClient client;

  void connect(String username, String password) async {
    this.client = new SSHClient(
      host: "belfort.tugler.fr",
      port: 22,
      username: username,
      passwordOrKey: password,
    );
    await this.client.connect();
  }

  Future<String> execute(String comand) async{
    return await this.client.execute("ls /");
  }

  void disconnect() async{
    await this.client.disconnect();
  }
}

