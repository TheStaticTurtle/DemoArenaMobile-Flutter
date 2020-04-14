import 'dart:convert';
import 'dart:typed_data';

import 'package:demoarenamobile_flutter_port/DemoArenaUtils.dart';
import 'package:demoarenamobile_flutter_port/Utils.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'DemoArenaClasses.dart';
import 'SSHManager.dart';
import 'Utils.dart';

void main() => runApp(MyApp());

var ssh = new SSHManager();
var demoarena = new DemoArenaUtils(ssh);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DemoArena',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: LoginPage(title: 'DemoArena'),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPage createState() => _LoginPage();
}
class _LoginPage extends State<LoginPage> {
  String iutLogo = "assets/images/info_iut_still.gif";
  String statusText = "Please login";
  String formValidationButtonText = "Login";
  bool   showCaptcha = false;
  String base64CapchaImage;

  final intputController_username = TextEditingController();
  final intputController_password = TextEditingController();
  final intputController_INE      = TextEditingController();
  final intputController_captcha  = TextEditingController();
  bool  switchController_savePassword = true;

  renderUnkownError(Error err) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("The application has enccouterd an error"),
          content: new Text(err.error.toString()),
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
                        child: new Text(err.stacktrace.toString()),
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
  renderError(ReturnState rt, Error err) {
    if(rt == ReturnState.DemoarenaUnknownError || rt == ReturnState.SemesterUnknownError) {
      renderUnkownError(err);
    } else {
      String text = "";
      switch(rt) {
        case ReturnState.SemesterCaptchaInvalid:
          text = "Captcha invalide";
          break;
        case ReturnState.SemesterINEInvalid:
          text = "Numero etudiant invalide";
          break;
        case ReturnState.GateInfoUnknownError:
          if(err.error.toString().contains("Auth fail")) {
            text = "Identifiants incorrects";
          } else {
            renderUnkownError(err);
            return;
          }
          break;
        case ReturnState.NoInternetError:
        // TODO: Handle this case.
          break;
        case ReturnState.DemoarenaNoAMIGUS:
          text = "Identifiants incorrects";
          break;
        case ReturnState.DemoarenaScriptError:
          renderUnkownError(err);
          return;
        case ReturnState.DemoarenaNoLT:
          renderUnkownError(err);
          return;
        default:
          break;
      }
      Fluttertoast.showToast(
          msg: text,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 14.0
      );
    }
  }
  updateStatus(LoginScreenState st) {
    setState(() {
      if (st == LoginScreenState.Login) {
        iutLogo = "assets/images/info_iut_still.gif";
        formValidationButtonText = "Login";
        statusText = "Please login";
        showCaptcha = false;
      } else if (st == LoginScreenState.Login_in) {
        iutLogo = "assets/images/info_iut.gif";
        formValidationButtonText = "Login";
        statusText = "Connecting to gate-info";
        showCaptcha = false;
      } else if (st == LoginScreenState.Logged_in) {
        iutLogo = "assets/images/info_iut.gif";
        formValidationButtonText = "Login";
        statusText = "Connected to gate-info";
        showCaptcha = false;
      } else if (st == LoginScreenState.LoadingCaptcha) {
        iutLogo = "assets/images/info_iut.gif";
        formValidationButtonText = "Login";
        statusText = "Trying to connect to demoarena";
        showCaptcha = false;
      }  else if (st == LoginScreenState.EnterCaptcha) {
        iutLogo = "assets/images/info_iut_still.gif";
        formValidationButtonText = "Validate";
        statusText = "Enter the captcha";
        showCaptcha = true;
      } else if (st == LoginScreenState.ValidatingCaptcha) {
        iutLogo = "assets/images/info_iut.gif";
        formValidationButtonText = "Validate";
        statusText = "Try-ing to validate the captcha";
        showCaptcha = true;
      }
    });
  }

  Future<void> connectToGateInfo(BuildContext ctx) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    updateStatus(LoginScreenState.Login_in);

    demoarena.updateCredentials(pref.getString("username"),pref.getString("password"));
    Response gateinfoConnectionCallback = await demoarena.connectToGateInfo();
    if(gateinfoConnectionCallback.return_state == ReturnState.Success) {
      updateStatus(LoginScreenState.Logged_in);
    } else {
      updateStatus(LoginScreenState.Login);
      renderError(gateinfoConnectionCallback.return_state, gateinfoConnectionCallback.err);
      return;
    }
    await connectToDemoarena(ctx);
  }
  Future<void> connectToDemoarena(BuildContext ctx) async {
    updateStatus(LoginScreenState.LoadingCaptcha);
    intputController_captcha.text = "";
    Response demoarenaLoadingCallback = await demoarena.authenticateCASDemoarena();
    if(demoarenaLoadingCallback.return_state == ReturnState.Success) {
      setState(() {base64CapchaImage = demoarenaLoadingCallback.data;});
      updateStatus(LoginScreenState.EnterCaptcha);
    } else {
      updateStatus(LoginScreenState.Login);
      renderError(demoarenaLoadingCallback.return_state, demoarenaLoadingCallback.err);
      return;
    }
  }
  Future<void> validateCaptcha(BuildContext ctx) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    updateStatus(LoginScreenState.ValidatingCaptcha);

    Response captchaValidationAndCurrentSemesterCallback = await demoarena.validateCaptchaAndGetCurrentSemester(intputController_captcha.text,pref.getString("ine"));
    if(captchaValidationAndCurrentSemesterCallback.return_state == ReturnState.Success) {
    } else {
      if( captchaValidationAndCurrentSemesterCallback.return_state == ReturnState.SemesterINEInvalid ||
          captchaValidationAndCurrentSemesterCallback.return_state == ReturnState.SemesterCaptchaInvalid ) {
        await connectToDemoarena(ctx);
        renderError(captchaValidationAndCurrentSemesterCallback.return_state,null);
      } else {
        renderError(captchaValidationAndCurrentSemesterCallback.return_state,captchaValidationAndCurrentSemesterCallback.err);
      }
      return;
    }
    updateStatus(LoginScreenState.Login);

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DisplayPage(
          )
      ),
    );

    //updateStatus(LoginScreenState.Login);
    //ssh.disconnect();
    //setState(() {
    //  iutLogo = "assets/images/info_iut_still.gif";
    //  statusText = "Done";
    //});

    /*Fluttertoast.showToast(
        msg: captchaValidationAndCurrentSemesterCallback.data,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );*/

  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    intputController_username.dispose();
    intputController_password.dispose();
    intputController_INE.dispose();
    intputController_captcha.dispose();
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

            switchController_savePassword = snapshot.data.getBool("save_pass") ?? true;

            intputController_username.text = _username;
            intputController_password.text = _password;
            intputController_INE.text = _ine;

            children = Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: FittedBox(
                    child: Image.asset('$iutLogo'),
                    fit: BoxFit.fill,
                  ),
                  padding: EdgeInsets.only(top: 15.0,bottom: 30.0,left: 90.0,right:90.0),
                ),
                Text(
                  '$statusText',
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
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Text( "Enter your username: " ),
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: TextFormField(
                                      controller: intputController_username,
                                      validator: (String value) {
                                        if(value.isEmpty) return "Shouldn't be empty";
                                        return null;
                                      },
                                    ),
                                  ),
                                ]),
                                TableRow(children: [
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Text( "Enter your password: " ),
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: TextFormField(
                                      obscureText: true,
                                      controller: intputController_password,
                                      validator: (String value) {
                                        if(value.isEmpty) return "Shouldn't be empty";
                                        return null;
                                      },
                                    ),
                                  ),
                                ]),
                                TableRow(children: [
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Text( "Enter your INE number: " ),
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: TextFormField(
                                      controller: intputController_INE,
                                      validator: (String value) {
                                        if(value.length != 8) return "Ine format invalid (len!=8)";
                                        if(!isNumeric(value)) return "Ine format invalid (not numeric)";
                                        if( value.contains("Infinity") || value.contains("+") || value.contains("-") ) return "Do not try to mess with me";
                                        return null;
                                      },
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 0,bottom: 0,left: 20.0,right: 20.0),
                            child: Builder(
                                builder: (context) {
                                  if (showCaptcha == true) {
                                    return Table(
                                        columnWidths: {0: FractionColumnWidth(.4)},
                                        children: [
                                          TableRow(
                                              children: [
                                                TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                                  child: Text( "Enter the captcha: " ),
                                                ),
                                                TextFormField(
                                                  controller: intputController_captcha,
                                                  validator: (String value) {
                                                    if(value.length != 6) return "Chapcha format invalid (len!=6)";
                                                    return null;
                                                  },
                                                ),
                                                Image.memory(base64Decode(base64CapchaImage)),
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
                                      snapshot.data.setString("username", intputController_username.text),
                                      snapshot.data.setString("ine", intputController_INE.text),
                                      snapshot.data.setBool("save_pass", switchController_savePassword),
                                      if(switchController_savePassword) {
                                        snapshot.data.setString("password", intputController_password.text),
                                      } else {
                                        snapshot.data.setString("password", ""),
                                      },
                                      if(!showCaptcha) {
                                        connectToGateInfo(context)
                                      } else {
                                        validateCaptcha(context)
                                      }
                                    }
                                  },
                                  child: Text('$formValidationButtonText'),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 0,bottom: 0,left: 10.0,right: 20.0),
                              child: Table(
                                columnWidths: {0: FractionColumnWidth(.15)},
                                children: [
                                  TableRow(
                                    children: [
                                      Switch(
                                        value: switchController_savePassword,
                                        onChanged: (value) {
                                          print(value);
                                          setState(() {
                                            switchController_savePassword = false;
                                          });
                                        },
                                      ),
                                      TableCell(
                                        verticalAlignment: TableCellVerticalAlignment.middle,
                                        child: Text( "Save password" ),
                                      ),
                                    ]
                                  )
                                ]
                              ),
                          ),
                      ]
                    )
                )
              ],
            );

          } else if (snapshot.hasError) {
            renderUnkownError(new Error(snapshot.error, snapshot.error));
          } else {
          }

          return Scaffold(
              appBar: AppBar(
                title: Text(widget.title),
                actions: <Widget>[
                  // action button
                  IconButton(
                    icon: Icon(Icons.error),
                    tooltip: 'Report a bug',
                    onPressed: () => openUrl("https://github.com/TurtleForGaming/DemoArenaMobile/issues/new/choose"),
                  ),
                  IconButton(
                    icon: Icon(Icons.language),
                    tooltip: 'Change language',
                    onPressed: null,
                  ),
                ],
              ),
              body:SingleChildScrollView(
                child: children
              ),
          );
        }
    );
  }
}

class DisplayPage extends StatefulWidget {
  DisplayPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DiplayPage createState() => _DiplayPage();
}
class _DiplayPage extends State<DisplayPage> with TickerProviderStateMixin{
  renderUnkownError(Error err) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("The application has enccouterd an error"),
          content: new Text(err.error.toString()),
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
                          child: new Text(err.stacktrace.toString()),
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
  renderError(ReturnState rt, Error err) {
    if(rt == ReturnState.DemoarenaUnknownError || rt == ReturnState.SemesterUnknownError) {
      renderUnkownError(err);
    } else {
      String text = "";
      switch(rt) {
        case ReturnState.SemesterCaptchaInvalid:
          text = "Captcha invalide";
          break;
        case ReturnState.SemesterINEInvalid:
          text = "Numero etudiant invalide";
          break;
        case ReturnState.GateInfoUnknownError:
          if(err.error.toString().contains("Auth fail")) {
            text = "Identifiants incorrects";
          } else {
            renderUnkownError(err);
            return;
          }
          break;
        case ReturnState.NoInternetError:
        // TODO: Handle this case.
          break;
        case ReturnState.DemoarenaNoAMIGUS:
          text = "Identifiants incorrects";
          break;
        case ReturnState.DemoarenaScriptError:
          renderUnkownError(err);
          return;
        case ReturnState.DemoarenaNoLT:
          renderUnkownError(err);
          return;
        default:
          break;
      }
      Fluttertoast.showToast(
          msg: text,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 14.0
      );
    }
  }
  /*updateStatus(LoginScreenState st) {
    setState(() {
      if (st == LoginScreenState.Login) {
        iutLogo = "assets/images/info_iut_still.gif";
        formValidationButtonText = "Login";
        statusText = "Please login";
        showCaptcha = false;
      } else if (st == LoginScreenState.Login_in) {
        iutLogo = "assets/images/info_iut.gif";
        formValidationButtonText = "Login";
        statusText = "Connecting to gate-info";
        showCaptcha = false;
      } else if (st == LoginScreenState.Logged_in) {
        iutLogo = "assets/images/info_iut.gif";
        formValidationButtonText = "Login";
        statusText = "Connected to gate-info";
        showCaptcha = false;
      } else if (st == LoginScreenState.LoadingCaptcha) {
        iutLogo = "assets/images/info_iut.gif";
        formValidationButtonText = "Login";
        statusText = "Trying to connect to demoarena";
        showCaptcha = false;
      }  else if (st == LoginScreenState.EnterCaptcha) {
        iutLogo = "assets/images/info_iut_still.gif";
        formValidationButtonText = "Validate";
        statusText = "Enter the captcha";
        showCaptcha = true;
      } else if (st == LoginScreenState.ValidatingCaptcha) {
        iutLogo = "assets/images/info_iut.gif";
        formValidationButtonText = "Validate";
        statusText = "Try-ing to validate the captcha";
        showCaptcha = true;
      }
    });
  }

  Future<void> connectToGateInfo(BuildContext ctx) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    updateStatus(LoginScreenState.Login_in);

    demoarena.updateCredentials(pref.getString("username"),pref.getString("password"));
    Response gateinfoConnectionCallback = await demoarena.connectToGateInfo();
    if(gateinfoConnectionCallback.return_state == ReturnState.Success) {
      updateStatus(LoginScreenState.Logged_in);
    } else {
      updateStatus(LoginScreenState.Login);
      renderError(gateinfoConnectionCallback.return_state, gateinfoConnectionCallback.err);
      return;
    }
    await connectToDemoarena(ctx);
  }
  Future<void> connectToDemoarena(BuildContext ctx) async {
    updateStatus(LoginScreenState.LoadingCaptcha);
    intputController_captcha.text = "";
    Response demoarenaLoadingCallback = await demoarena.authenticateCASDemoarena();
    if(demoarenaLoadingCallback.return_state == ReturnState.Success) {
      setState(() {base64CapchaImage = demoarenaLoadingCallback.data;});
      updateStatus(LoginScreenState.EnterCaptcha);
    } else {
      updateStatus(LoginScreenState.Login);
      renderError(demoarenaLoadingCallback.return_state, demoarenaLoadingCallback.err);
      return;
    }
  }
  Future<void> validateCaptcha(BuildContext ctx) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    updateStatus(LoginScreenState.ValidatingCaptcha);

    demoarena.updateCredentials(pref.getString("username"),pref.getString("password"));
    Response captchaValidationAndCurrentSemesterCallback = await demoarena.validateCaptchaAndGetCurrentSemester(intputController_captcha.text,pref.getString("ine"));
    if(captchaValidationAndCurrentSemesterCallback.return_state == ReturnState.Success) {
    } else {
      if( captchaValidationAndCurrentSemesterCallback.return_state == ReturnState.SemesterINEInvalid ||
          captchaValidationAndCurrentSemesterCallback.return_state == ReturnState.SemesterCaptchaInvalid ) {
        await connectToDemoarena(ctx);
        renderError(captchaValidationAndCurrentSemesterCallback.return_state,null);
      } else {
        renderError(captchaValidationAndCurrentSemesterCallback.return_state,captchaValidationAndCurrentSemesterCallback.err);
      }
      return;
    }

    updateStatus(LoginScreenState.Login);

    ssh.disconnect();

    setState(() {
      iutLogo = "assets/images/info_iut_still.gif";
      statusText = "Done";
    });

    Fluttertoast.showToast(
        msg: captchaValidationAndCurrentSemesterCallback.data,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );

  }
*/

  Semester _semesterDropDownSelected = null;
  User currentUser = null;

  DisplayScreenState state = DisplayScreenState.Grades;

  List<Tab> tabList = List();
  TabController _tabController;

  @override
  void initState() {
    tabList.add(new Tab(text:'Grades',));
    tabList.add(new Tab(text:'Absences',));
    _tabController = new TabController(vsync: this, length: tabList.length);
    _tabController.addListener(() => {
      setState(() {
        if(_tabController.index == 0) {
          state = DisplayScreenState.Grades;
        }else {
          state = DisplayScreenState.Misses;
        }
      })
    });
    super.initState();
  }

  Future<void> loadPage(BuildContext ctx) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState( () {
      currentUser = demoarena.parseUserFormHTML();
      state = DisplayScreenState.Grades;
    });
  }
  Future<void> changeSemester(BuildContext ctx, String semId) async {
    Response semesterCallback = await demoarena.getSemester(semId);
    SharedPreferences pref = await SharedPreferences.getInstance();
    if(semesterCallback.return_state == ReturnState.Success) {
      setState( () {
        currentUser = demoarena.parseUserFormHTML();
        state = DisplayScreenState.Grades;

        tabList.clear();
        tabList.add(new Tab(text:'Grades',));
        if(!currentUser.semesters[0].done) {
          tabList.add(new Tab(text:'Absences',));
        }
        _tabController = new TabController(vsync: this, length: tabList.length);
        _tabController.addListener(() => {
          setState(() {
            if(_tabController.index == 0) {
              state = DisplayScreenState.Grades;
            }else {
              state = DisplayScreenState.Misses;
            }
          })
        });

      });
    } else {
      renderError(semesterCallback.return_state, semesterCallback.err);
    }


  }


  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    if(currentUser == null) {
      currentUser = demoarena.parseUserFormHTML();
    }
    return FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
          Widget children;

          if (snapshot.hasData) {
            children = Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 5,bottom: 0,left: 10.0,right: 5.0),
                  child:
                  Text(
                    currentUser.name,
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.black87
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5,bottom: 0,left: 10.0,right: 10.0),
                  child: DropdownButton<Semester>(
                    hint: _semesterDropDownSelected == null
                        ? Text(currentUser.semesters[0].name)
                        : Text(
                      _semesterDropDownSelected.name,
                      style: TextStyle(color: Colors.red),
                    ),
                    items: currentUser.semesters.map((value) {
                      return new DropdownMenuItem<Semester>(
                        value: value,
                        child: new Text(
                            value.name,
                            style: TextStyle(color: Colors.redAccent),
                      ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState( () {
                        if(state != DisplayScreenState.Loading) {
                          state = DisplayScreenState.Loading;
                          changeSemester(context,val.id);
                          _semesterDropDownSelected = val;
                        }
                      });
                    },
                    isExpanded: true,
                  )
                ),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: new Column(
                    children: <Widget>[
                      new Container(
                        decoration: new BoxDecoration(),
                        child: new TabBar(
                          controller: _tabController,
                          labelColor: Colors.black,
                          indicatorColor: Colors.pink,
                          indicatorSize: TabBarIndicatorSize.tab,
                          tabs: tabList,
                        ),
                      ),
                    ],
                  ),
                ),
                Builder(
                    builder: (context) {
                      if(state == DisplayScreenState.Misses) {
                        if (currentUser.semesters[0].absences.length > 0) {
                          return ListView.separated(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(8),
                            itemCount: currentUser.semesters[0].absences.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                child: Table(
                                  columnWidths: {0: FractionColumnWidth(.18)},
                                  children: [
                                    TableRow(children: [
                                      TableCell(
                                        verticalAlignment: TableCellVerticalAlignment
                                            .middle,
                                        child: Text("De: ",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        verticalAlignment: TableCellVerticalAlignment
                                            .middle,
                                        child: Text(
                                          currentUser.semesters[0] .absences[index].from,
                                          style: TextStyle(
                                              color: currentUser.semesters[0]
                                                  .absences[index].justified
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                        verticalAlignment: TableCellVerticalAlignment
                                            .middle,
                                        child: Text("A: ",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        verticalAlignment: TableCellVerticalAlignment
                                            .middle,
                                        child: Text(
                                          currentUser.semesters[0]
                                              .absences[index].to,
                                          style: TextStyle(
                                              color: currentUser.semesters[0]
                                                  .absences[index].justified
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                        verticalAlignment: TableCellVerticalAlignment
                                            .middle,
                                        child: Text("Raison: "),
                                      ),
                                      TableCell(
                                        verticalAlignment: TableCellVerticalAlignment
                                            .middle,
                                        child: Text(
                                          currentUser.semesters[0]
                                              .absences[index].cause != ""
                                              ? currentUser.semesters[0]
                                              .absences[index].cause
                                              : "Inconnue",
                                          style: TextStyle(
                                            color: currentUser.semesters[0]
                                                .absences[index].justified
                                                ? Colors.green
                                                : Colors.red,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (BuildContext context,
                                int index) => const Divider(),
                          );
                        }
                      }
                      if(state == DisplayScreenState.Grades) {
                        List<Grade> grades = currentUser.semesters[0].compactAll();
                        if (grades.length > 0) {
                          return ListView.separated(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            padding: const EdgeInsets.all(0),
                            itemCount: grades.length,
                            itemBuilder: (BuildContext context, int index) {
                              return grades[index].buildRender();
                            },
                            separatorBuilder: (BuildContext context,
                                int index) => const Divider(
                              height: 1,
                              thickness: 1,
                            ),
                          );
                        }
                      }
                      if(state == DisplayScreenState.Loading) {
                        return SizedBox(
                            width: double.infinity, // set this
                            height: 500,
                            child: Center(
                              //crossAxisAlignment: CrossAxisAlignment.center,
                              //mainAxisAlignment: MainAxisAlignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("assets/images/info_iut.gif", width: 250,),
                                  Text(
                                    "Loading...",
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.lightBlue,
                                    ),
                                  )
                                ],
                              ),
                            )
                        );
                      }
                      return SizedBox(
                          width: double.infinity, // set this
                          height: 500,
                          child: Center(
                            //crossAxisAlignment: CrossAxisAlignment.center,
                            //mainAxisAlignment: MainAxisAlignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset("assets/images/empty.png"),
                                Text(
                                  "Wow. Such empty!",
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.grey,
                                  ),
                                )
                              ],
                            ),
                          )
                      );
                    }
                ),
              ],
            );

          } else if (snapshot.hasError) {
            renderUnkownError(new Error(snapshot.error, snapshot.error));
          } else {
          }

          return Scaffold(
            appBar: AppBar(
              title: Text("DemoArena"),
              actions: <Widget>[
                // action button
                IconButton(
                  icon: Icon(Icons.error),
                  tooltip: 'Report a bug',
                  onPressed: () => openUrl("https://github.com/TurtleForGaming/DemoArenaMobile/issues/new/choose"),
                ),
                IconButton(
                  icon: Icon(Icons.language),
                  tooltip: 'Change language',
                  onPressed: null,
                ),
              ],
            ),
            body: SingleChildScrollView(
                child: children
            ),
          );
        }
    );
  }
}