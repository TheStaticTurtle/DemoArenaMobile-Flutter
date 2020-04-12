import 'package:ssh/ssh.dart';


class SSHManager {
  SSHClient client;

  void init(String username, String password) {
    this.client = new SSHClient(
      host: "belfort.tugler.fr",
      port: 22,
      username: username,
      passwordOrKey: password,
    );
  }

  Future<void> connect() async {
    await this.client.connect();
  }

  Future<String> execute(String comand) async{
    return await this.client.execute("ls /");
  }

  void disconnect() async{
    await this.client.disconnect();
  }
}

