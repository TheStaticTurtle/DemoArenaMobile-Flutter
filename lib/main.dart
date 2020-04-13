import 'dart:convert';
import 'dart:typed_data';

import 'package:demoarenamobile_flutter_port/DemoArenaUtils.dart';
import 'package:demoarenamobile_flutter_port/Utils.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'SSHManager.dart';

void main() => runApp(MyApp());

var ssh = new SSHManager();
var demoarena = new DemoArenaUtils(ssh);

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
  String _statusText = "Please login";
  String _buttonText = "Login";
  bool _showCaptcha = false;
  String _base64;

  renderApplicationError(dynamic err, dynamic stack) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("The application has enccouterd an error"),
          content: new Text(err.toString()),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Report"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            new FlatButton(
              child: new Text("Stacktrace"),
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                  // return object of type Dialog
                    return AlertDialog(
                      title: new Text("StackTrace:"),
                      content: SingleChildScrollView(
                        child: new Text(stack.toString()),
                      ),
                      actions: <Widget>[
                        // usually buttons at the bottom of the dialog
                        new FlatButton(
                          child: new Text("Close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ]
                    );
                  },
                );
              },
            ),
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> connect(BuildContext ctx) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() { _image = "assets/images/info_iut.gif"; });

    demoarena.updateCredentials(pref.getString("username"),pref.getString("password"));
    BasicResponce gateinfoConnectionCallback = await demoarena.connectToGateInfo();
    if(gateinfoConnectionCallback.success) {
      setState(() {
        _showCaptcha = false;
        _statusText = gateinfoConnectionCallback.message;
        _buttonText = "Login";
      });
    } else {
      setState(() {
        _image = "assets/images/info_iut_still.gif";
        _statusText = gateinfoConnectionCallback.message;
      });
      renderApplicationError(gateinfoConnectionCallback.err_obj,gateinfoConnectionCallback.err_stacktrace);
      return;
    }

    AuthetificationResponse demoarenaLoadingCallback = await demoarena.authenticateCASDemoarena();
    if(demoarenaLoadingCallback.success) {
      setState(() {
        _showCaptcha = true;
        _buttonText = "Validate";
        _base64 = demoarenaLoadingCallback.b64capcha;
        _statusText = demoarenaLoadingCallback.message;
      });
    } else {
      setState(() {
        _image = "assets/images/info_iut_still.gif";
        _statusText = demoarenaLoadingCallback.message;
      });
      renderApplicationError(demoarenaLoadingCallback.err_obj,demoarenaLoadingCallback.err_stacktrace);
      return;
    }

    String result = await ssh.execute("ls .demo*");
    debugPrint(result);
    await ssh.disconnect();

    setState(() {
      _image = "assets/images/info_iut_still.gif";
      _statusText = "Done";
    });

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

  final inputUserameController = TextEditingController();
  final inputPasswordController = TextEditingController();
  final inputINEController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    inputUserameController.dispose();
    inputPasswordController.dispose();
    inputINEController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
          Widget children;

          if (snapshot.hasData) {
            String _username = snapshot.data.getString("username") ?? "";
            String _password = snapshot.data.getString("password") ?? "";
            String _ine = snapshot.data.getString("ine") ?? "";

            inputUserameController.text = _username;
            inputPasswordController.text = _password;
            inputINEController.text = _ine;

            children = Column(
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
                  '$_statusText',
                ),
                Form(
                    key: _formKey,
                    child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 15.0,bottom: 0,left: 20.0,right: 20.0),
                            child: Table(
                              columnWidths: {1: FractionColumnWidth(.6)},
                              children: [
                                TableRow(children: [
                                  Text( "Enter your username: " ),
                                  TextFormField(
                                    controller: inputUserameController,
                                    validator: (String value) {
                                      if(value.isEmpty) return "Shouldn't be empty";
                                      return null;
                                    },
                                  ),
                                ]),
                                TableRow(children: [
                                  Text( "Enter your password: " ),
                                  TextFormField(
                                    controller: inputPasswordController,
                                    validator: (String value) {
                                      if(value.isEmpty) return "Shouldn't be empty";
                                      return null;
                                    },
                                  ),
                                ]),
                                TableRow(children: [
                                  Text( "Enter your INE number: " ),
                                  TextFormField(
                                    controller: inputINEController,
                                    validator: (String value) {
                                      if(value.length != 8) return "Ine format invalid (len!=8)";
                                      if(!isNumeric(value)) return "Ine format invalid (not numeric)";
                                      if( value.contains("Infinity") || value.contains("+") || value.contains("-") ) return "Do not try to mess with me";
                                      return null;
                                    },
                                  ),
                                ]),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 0,bottom: 0,left: 20.0,right: 20.0),
                            child: Builder(
                                builder: (context) {
                                  if (_showCaptcha == true) {
                                    return Table(
                                        columnWidths: {0: FractionColumnWidth(.4)},
                                        children: [
                                          TableRow(
                                              children: [
                                                Text( "Enter the captcha: " ),
                                                TextFormField(
                                                  controller: null,
                                                  validator: (String value) {
                                                    if(value.length != 6) return "Chapcha format invalid (len!=6)";
                                                    return null;
                                                  },
                                                ),
                                                Image.memory(base64Decode(_base64)),
                                              ]
                                          )
                                        ]
                                    );
                                  } else {
                                    return Container();
                                  }
                                }
                            )
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
                                  onPressed: () => {
                                    if (_formKey.currentState.validate()) {
                                      snapshot.data.setString("username", inputUserameController.text),
                                      snapshot.data.setString("password", inputPasswordController.text),
                                      snapshot.data.setString("ine", inputINEController.text),
                                      connect(context)
                                    }
                                  },
                                  child: Text('$_buttonText'),
                                ),
                              ),
                            ),
                          ),
                        ]
                    )
                )
              ],
            );

          } else if (snapshot.hasError) {
            renderApplicationError(snapshot.error, snapshot.error);
          } else {
            children = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Awaiting result...'),
                )
              ]
            );
          }

          return Scaffold(
              appBar: AppBar(
                title: Text(widget.title),
              ),
              body:SingleChildScrollView(
                child: children
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => _openUrl("https://github.com/TurtleForGaming/DemoArenaMobile/issues/new/choose"),
                tooltip: 'Report a bug',
                child: Icon(Icons.error),
              ), // This trailing comma makes auto-formatting nicer for build methods.
          );
        }
    );
/*
    Scaffold(
      appBar: AppBar(
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
                    '$_statusText',
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 15.0,bottom: 0,left: 20.0,right: 20.0),
                          child: Table(
                            columnWidths: {1: FractionColumnWidth(.6)},
                            children: [
                              TableRow(children: [
                                Text( "Enter your username: " ),
                                TextFormField(
                                  initialValue: '$_username',
                                  validator: (String value) {
                                    if(value.isEmpty) return "Shouldn't be empty";
                                    return null;
                                  },
                                ),
                              ]),
                              TableRow(children: [
                                Text( "Enter your password: " ),
                                TextFormField(
                                  initialValue: '$_password',
                                  validator: (String value) {
                                    if(value.isEmpty) return "Shouldn't be empty";
                                    return null;
                                  },
                                ),
                              ]),
                              TableRow(children: [
                                Text( "Enter your INE number: " ),
                                TextFormField(
                                  initialValue: '$_ine',
                                  validator: (String value) {
                                    if(value.length != 8) return "Ine format invalid (len!=8)";
                                    if(!isNumeric(value)) return "Ine format invalid (not numeric)";
                                    if( value.contains("Infinity") || value.contains("+") || value.contains("-") ) return "Do not try to mess with me";
                                    return null;
                                  },
                                ),
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
                                onPressed: () => {
                                  if (_formKey.currentState.validate()) {
                                    connect(context)
                                  }
                                },
                                child: Text("Login"),
                              ),
                            ),
                          ),
                        ),
                      ]
                    )
                  )
              ],
            )

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openUrl("https://github.com/TurtleForGaming/DemoArenaMobile/issues/new/choose"),
        tooltip: 'Report a bug',
        child: Icon(Icons.error),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
*/
  }
}
