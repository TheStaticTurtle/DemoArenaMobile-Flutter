import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'sshManager.dart';

void main() => runApp(MyApp());

var sshMan = new SSHManager();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'DemoArena'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _image = "assets/images/info_iut_still.gif";

  Future<void> connectSSH(BuildContext ctx) async {
    setState(() {
      _image = "assets/images/info_iut.gif";
    });
    await sshMan.connect("testuser","testuserpassword");
    setState(() {
      _image = "assets/images/info_iut_still.gif";
    });
    String result = await sshMan.execute("ls /");
    debugPrint(result);
    await sshMan.disconnect();

    Fluttertoast.showToast(
        msg: result,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );

  }

  void _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body:SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: FittedBox(
                      child: Image.asset('$_image'),
                      fit: BoxFit.fill,
                    ),
                    padding: EdgeInsets.only(top: 15.0,bottom: 30.0,left: 80.0,right: 80.0),
                  ),

                  Text(
                    'Please login!',
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15.0,bottom: 0,left: 20.0,right: 20.0),
                    child: Table(
                      columnWidths: {1: FractionColumnWidth(.6)},
                      children: [
                        TableRow(children: [
                          Text( "Enter your username: " ),
                          TextFormField(),
                        ]),
                        TableRow(children: [
                          Text( "Enter your password: " ),
                          TextFormField(),
                        ]),
                        TableRow(children: [
                          Text( "Enter your INE number: " ),
                          TextFormField(),
                        ]),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15,bottom: 0,left: 20.0,right: 20.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ButtonTheme(
                        height: 45.0,
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: Colors.redAccent,
                          onPressed: () => connectSSH(context),
                          child: Text("Login"),
                        ),
                      ),
                    ),
                  ),
              ],
            )

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openUrl("https://github.com/TurtleForGaming/DemoArenaMobile/issues/new/choose"),
        tooltip: 'Report a bug',
        child: Icon(Icons.error),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
