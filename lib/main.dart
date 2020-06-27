import 'dart:convert';
import 'dart:typed_data';
import 'package:demoarenamobile_flutter_port/DemoArenaUtils.dart';
import 'package:demoarenamobile_flutter_port/GithubUpdateChecker.dart';
import 'package:demoarenamobile_flutter_port/Utils.dart';
import 'package:flutter/foundation.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'DemoArenaClasses.dart';
import 'SSHManager.dart';
import 'Utils.dart';
import 'Translation.dart';

void main() => runApp(MyApp());

var language = new LanguageManager(Locale.FR);
var ssh = new SSHManager();
var demoarena = new DemoArenaUtils(ssh);
var github = new GithubUpdateChecker("TheStaticTurtle/DemoArenaMobile-Flutter","V1.4");

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final storage = new FlutterSecureStorage();
    return FutureBuilder<Map<String, String>>(
      future: storage.readAll(),
      builder: (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
        if (snapshot.hasData) {
          language = new LanguageManager(Locale.findByCode(snapshot.data["language"]));
          return MaterialApp(
              title: language.app_name,
              theme: ThemeData(
                primarySwatch: Colors.red,
              ),
              home: LoginPage(title: language.app_name),
          );
        } else {
          language = new LanguageManager(Locale.FR);
          return MaterialApp(
              title: language.app_name,
              theme: ThemeData(
                primarySwatch: Colors.red,
              ),
              home: LoginPage(title: language.app_name),
          );
        }
      },
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
  String statusText = language.status_text_please_login;
  String formValidationButtonText = language.login_connect;
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
          title: new Text(language.error),
          content: new Text(err.error.toString()),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(language.tooltips_report),
              onPressed: () => openUrl("https://github.com/TurtleForGaming/DemoArenaMobile/issues/new/choose"),
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
                          child: new Text(language.tooltips_close),
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
              child: new Text(language.tooltips_close),
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
          text = language.toast_captcha_invalid;
          break;
        case ReturnState.SemesterINEInvalid:
          text = language.toast_ine_invalid;
          break;
        case ReturnState.GateInfoUnknownError:
          if(err.error.toString().contains("Auth fail")) {
            text = language.toast_login_incorrect;
          } else {
            renderUnkownError(err);
            return;
          }
          break;
        case ReturnState.NoInternetError:
        // TODO: Handle this case.
          break;
        case ReturnState.DemoarenaNoAMIGUS:
          text =language.toast_login_incorrect;
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
  LoginScreenState _loginScreenState = LoginScreenState.Login;
  updateStatus(LoginScreenState st) {
    _loginScreenState = st;
    setState(() {
      if (st == LoginScreenState.Login) {
        iutLogo = "assets/images/info_iut_still.gif";
        formValidationButtonText = language.login_connect;
        statusText = language.login_please_connect;
        showCaptcha = false;
      } else if (st == LoginScreenState.Login_in) {
        iutLogo = "assets/images/info_iut.gif";
        formValidationButtonText = language.login_connect;
        statusText = language.status_text_connection_gteinfo;
        showCaptcha = false;
      } else if (st == LoginScreenState.Logged_in) {
        iutLogo = "assets/images/info_iut.gif";
        formValidationButtonText = language.login_connect;
        statusText = language.status_text_connected_gteinfo;
        showCaptcha = false;
      } else if (st == LoginScreenState.LoadingCaptcha) {
        iutLogo = "assets/images/info_iut.gif";
        formValidationButtonText = language.login_connect;
        statusText = language.status_text_connection_dmoaren;
        showCaptcha = false;
      }  else if (st == LoginScreenState.EnterCaptcha) {
        iutLogo = "assets/images/info_iut_still.gif";
        formValidationButtonText = language.login_validate;
        statusText = language.status_text_enter_captcha;
        showCaptcha = true;
      } else if (st == LoginScreenState.ValidatingCaptcha) {
        iutLogo = "assets/images/info_iut.gif";
        formValidationButtonText = language.login_validate;
        statusText = language.status_text_enter_validcaptcha;
        showCaptcha = true;
      }
    });
  }

  noInternetPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(language.error),
          content: new Text(language.no_internet),
          actions: <Widget>[
            new FlatButton(
              child: new Text(language.tooltips_close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  updateAvailablePopup(String latestTag) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Information"),
          content: new Text(language.update_available.replaceAll(":latest", latestTag).replaceAll(":current", github.currentVersionTag)),
          actions: <Widget>[
            new FlatButton(
              child: new Text(language.tooltips_download),
              onPressed: () => openUrl("https://github.com/"+github.repoUrl+"/releases/latest"),
            ),
            new FlatButton(
              child: new Text(language.tooltips_close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> connectToGateInfo(BuildContext ctx, String username, String password) async {
    updateStatus(LoginScreenState.Login_in);
    bool hasInternet = await github.checkForInternetConnection();
    if(!hasInternet) {
      noInternetPopup();
      updateStatus(LoginScreenState.Login);
      return;
    }

    String tag = await github.getLatestReleaseTag();
    if(tag.toLowerCase() != github.currentVersionTag.toLowerCase() && tag != "error" && tag != "notag") {
      updateAvailablePopup(tag);
    }


    demoarena.updateCredentials(username,password);
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
  Future<void> validateCaptcha(BuildContext ctx, String ine, String captcha) async {
    //final storage = new FlutterSecureStorage();
    //Map<String, String> allValues = await storage.readAll();
    updateStatus(LoginScreenState.ValidatingCaptcha);

    Response captchaValidationAndCurrentSemesterCallback = await demoarena.validateCaptchaAndGetCurrentSemester(captcha,ine);
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
    await saveCredentials();

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DisplayPage(
          )
      ),
    );
  }
  Future<void> saveCredentials() async {
    final storage = new FlutterSecureStorage();
    storage.write(key: "username",  value: intputController_username.text);
    storage.write(key: "ine",       value: intputController_INE.text);
    storage.write(key: "save_pass", value: switchController_savePassword.toString());
    if(switchController_savePassword) {
      storage.write(key: "password", value: intputController_password.text);
    } else {
      storage.write(key: "password", value: "");
    }
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
    final storage = new FlutterSecureStorage();
    return FutureBuilder<Map<String, String>>(
        future: storage.readAll(),
        builder: (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
          Widget children;
          if (snapshot.hasData) {

            //TODO: Load ONLY for first load and not for any state update
            if(_loginScreenState == LoginScreenState.Login) {
              String _username = snapshot.data["username"] ?? "";
              String _password = snapshot.data["password"] ?? "";
              String _ine = snapshot.data["ine"] ?? "";

              if(snapshot.data["save_pass"] != null) {
                switchController_savePassword = snapshot.data["save_pass"] == "true";
              } else {
                switchController_savePassword = true;
              }

              intputController_username.text = _username;
              intputController_password.text = _password;
              intputController_INE.text = _ine;
            }

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
                                    child: Text(language.login_username),
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: TextFormField(
                                      controller: intputController_username,
                                      validator: (String value) {
                                        if(value.isEmpty) return language.login_format_empty;
                                        return null;
                                      },
                                    ),
                                  ),
                                ]),
                                TableRow(children: [
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Text(language.login_password),
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: TextFormField(
                                      obscureText: true,
                                      controller: intputController_password,
                                      validator: (String value) {
                                        if(value.isEmpty) return language.login_format_empty;
                                        return null;
                                      },
                                    ),
                                  ),
                                ]),
                                TableRow(children: [
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Text(language.login_ine),
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: TextFormField(
                                      controller: intputController_INE,
                                      validator: (String value) {
                                        if(value.length != 8) return language.login_format_ine_len;
                                        if(!isNumeric(value)) return language.login_format_ine_nan;
                                        if( value.contains("Infinity") || value.contains("+") || value.contains("-") ) return language.login_format_donotmesswithme;
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
                                                  child: Text(language.login_captcha),
                                                ),
                                                TextFormField(
                                                  controller: intputController_captcha,
                                                  validator: (String value) {
                                                    if(value.length != 6) return language.login_format_captcha;
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
                                  onPressed: () async => {
                                    if (_formKey.currentState.validate()) {
                                      if(!showCaptcha) {
                                       connectToGateInfo(context,intputController_username.text,intputController_password.text)
                                      } else {
                                       validateCaptcha(context,intputController_INE.text, intputController_captcha.text)
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
                                      Checkbox(
                                        value: switchController_savePassword,
                                        onChanged: (value) async {
                                          await storage.write(key: "save_pass", value: value.toString());
                                          //await storage.write(key: "username",  value: intputController_username.text);
                                          //await storage.write(key: "ine",       value: intputController_INE.text);
                                          /*if(switchController_savePassword) {
                                            await storage.write(key: "password", value: intputController_password.text);
                                          } else {
                                            await storage.write(key: "password", value: "");
                                          }*/
                                          setState(() {
                                            switchController_savePassword = value;
                                          });
                                        },
                                      ),
                                      TableCell(
                                        verticalAlignment: TableCellVerticalAlignment.middle,
                                        child: Text(language.login_savepwd),
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
                    tooltip: language.tooltips_report,
                    onPressed: () => openUrl("https://github.com/"+github.repoUrl+"/issues/new/choose"),
                  ),
                  PopupMenuButton<Locale>(
                    onSelected: (locale) async => {
                      await storage.write(key: "language", value: locale.languageCode),
                      language = new LanguageManager(locale),
                      updateStatus(_loginScreenState),
                      Fluttertoast.showToast(
                        msg: language.restart_required,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black87,
                        textColor: Colors.white,
                        fontSize: 14.0
                      )
                    },
                    icon: Icon(Icons.language),
                    itemBuilder: (BuildContext context) {
                      return Locale.getAllLocales().map((Locale locale) {
                        return PopupMenuItem<Locale>(
                          value: locale,
                          child: Text(locale.language),
                        );
                      }).toList();
                    },
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
          title: new Text(language.error),
          content: new Text(err.error.toString()),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(language.tooltips_report),
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
                            child: new Text(language.tooltips_close),
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
              child: new Text(language.tooltips_close),
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
          text = language.toast_captcha_invalid;
          break;
        case ReturnState.SemesterINEInvalid:
          text = language.toast_ine_invalid;
          break;
        case ReturnState.GateInfoUnknownError:
          if(err.error.toString().contains("Auth fail")) {
            text = language.toast_login_incorrect;
          } else {
            renderUnkownError(err);
            return;
          }
          break;
        case ReturnState.NoInternetError:
        // TODO: Handle this case.
          break;
        case ReturnState.DemoarenaNoAMIGUS:
          text = language.toast_login_incorrect;
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

  Semester _semesterDropDownSelected = null;
  User currentUser = null;

  DisplayScreenState state = DisplayScreenState.Grades;

  List<Tab> tabList = List();
  TabController _tabController;

  @override
  void initState() {
    tabList.add(new Tab(text:language.display_grades,));
    tabList.add(new Tab(text:language.display_absences,));
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
    setState( () {
      currentUser = demoarena.parseUserFormHTML();
      state = DisplayScreenState.Grades;
    });
  }
  Future<void> changeSemester(BuildContext ctx, String semId) async {
    Response semesterCallback = await demoarena.getSemester(semId);
    if(semesterCallback.return_state == ReturnState.Success) {
      setState( () {
        currentUser = demoarena.parseUserFormHTML();
        state = DisplayScreenState.Grades;

        tabList.clear();
        tabList.add(new Tab(text:language.display_grades,));
        if(!currentUser.semesters[0].done) {
          tabList.add(new Tab(text:language.display_absences,));
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
    final storage = new FlutterSecureStorage();
    return FutureBuilder<Map<String, String>>(
        future: storage.readAll(),
        builder: (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
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
                                        child: Text(language.display_absences_from,
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
                                        child: Text(language.display_absences_to,
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
                                        child: Text(language.display_absences_reason),
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
                                int index) => Container()
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
                                    language.display_loading,
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
                                  language.display_empty,
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
              title: Text(language.app_name),
              actions: <Widget>[
                // action button
                IconButton(
                  icon: Icon(Icons.error),
                  tooltip: language.tooltips_report,
                  onPressed: () => openUrl("https://github.com/TurtleForGaming/DemoArenaMobile/issues/new/choose"),
                ),
                PopupMenuButton<Locale>(
                  onSelected: (locale) async => {
                    await storage.write(key: "language", value: locale.languageCode),
                    language = new LanguageManager(locale),
                    //updateStatus(_loginScreenState),
                    Fluttertoast.showToast(
                        msg: language.restart_required,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black87,
                        textColor: Colors.white,
                        fontSize: 14.0
                    )
                  },
                  icon: Icon(Icons.language),
                  itemBuilder: (BuildContext context) {
                    return Locale.getAllLocales().map((Locale locale) {
                      return PopupMenuItem<Locale>(
                        value: locale,
                        child: Text(locale.language),
                      );
                    }).toList();
                  },
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