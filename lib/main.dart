import 'package:dio/adapter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:device_apps/device_apps.dart';
import 'package:e_voting/voting.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:e_voting/Register.dart';
import 'package:e_voting/Cam.dart';
import 'package:camera/camera.dart';
import 'package:flutter_install_app_plugin/flutter_install_app_plugin.dart';
import 'package:flutter_appavailability/flutter_appavailability.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-voting ',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {



  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  List<Map<String, String>> installedApps;
  List<Map<String, String>> iOSApps = [
    {
      "app_name": "Calendar",
      "package_name": "calshow://"
    },
    {
      "app_name": "Facebook",
      "package_name": "fb://"
    },
    {
      "app_name": "Whatsapp",
      "package_name": "whatsapp://"
    }
  ];


  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  final _formKey = GlobalKey<FormState>();
  String _email = '';
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }
  List<CameraDescription> cameras = [];

  Future<void> cam() async {
    // Fetch the available cameras before initializing the app.
    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();
    } on CameraException catch (e) {
      logError(e.code, e.description);
    }

  }
  Future<void> getApps() async {
    List<Map<String, String>> _installedApps;

    if (Platform.isAndroid) {

      _installedApps = await AppAvailability.getInstalledApps();

     // print(await AppAvailability.checkAvailability("com.wireguard.android"));
      // Returns: Map<String, String>{app_name: Chrome, package_name: com.android.chrome, versionCode: null, version_name: 55.0.2883.91}

     // print(await AppAvailability.isAppEnabled("com.wireguard.android"));
      // Returns: true

    }
    else if (Platform.isIOS) {
      // iOS doesn't allow to get installed apps.
      _installedApps = iOSApps;

      print(await AppAvailability.checkAvailability("calshow://"));
      // Returns: Map<String, String>{app_name: , package_name: calshow://, versionCode: , version_name: }

    }

    setState(() {
      installedApps = _installedApps;
    });

  }
  String validateEmail(String value) {
    if (value.isEmpty) {
      return 'Please enter mail';
    }

    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }
  String validatePasswd(String value) {
    if (value.isEmpty) {
      return 'Please enter passwd';
    }

    Pattern pattern =
        r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid 8 digit passwd combination with \na digit\na small character\na capital character';
    else
      return null;
  }
  void getConfig()async
  {

    Dio dio = new Dio();
    dio.interceptors.add(LogInterceptor());
    (dio.httpClientAdapter as DefaultHttpClientAdapter ).onHttpClientCreate  = (client) {
      SecurityContext sc = new SecurityContext();
      String file='';
      //file is the path of certificate
      sc.setTrustedCertificates(file);
      HttpClient httpClient = new HttpClient(context: sc);
      return httpClient;
    };
    var url =
        "";
    CancelToken cancelToken = CancelToken();
    try {
      await dio.download(url, "./wireguard.config",
          onReceiveProgress: (received, total) {
            if (total != -1) {
              print((received / total * 100).toStringAsFixed(0) + "%");
            }
          }, cancelToken: cancelToken);
    } catch (e) {
      print(e);
    }

  }

  void wireguardRun(){
    if (installedApps == null)
      getApps();
    else {
      var app = AppSet()
        ..iosAppId = 300915900
        ..androidPackageName = 'com.wireguard.android';
      FlutterInstallAppPlugin.installApp(app);
      getConfig();

      setState(() {
        DeviceApps.openApp('com.wireguard.android');


      });
    }
  }

  @override
  Widget build(BuildContext context) {


    final String assetName = 'assets/launcher/icon.svg';
    final Widget svg = SvgPicture.asset(
        assetName,
        width:200,
        height:200,

        semanticsLabel: 'logo'
    );
    final emailField = TextFormField(
      obscureText: false,
      validator: validateEmail,
      onTap: (){
        //wireguardRun();
      },
      onSaved: (value) {
        setState(() {
          _email = value;
        });
      },
      keyboardType: TextInputType.emailAddress,

      style: style,

      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final passwordField = TextFormField(
      obscureText: true,
      validator: validatePasswd,
      keyboardType: TextInputType.text,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: ()async {

          if (_formKey.currentState.validate()) {
          // If the form is valid, display a Snackbar.
            setState(() async {
              await cam();
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Processing Data')));

              bool value= await
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CameraExampleHome(cameras)),
              );
              if (value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => voting()),
                );
              }

            });

        }},
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    final registerButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Register()),
          );
        },
        child: Text("register",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );


    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: Center(

        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      RaisedButton(
                        child: Text("VPN", style: TextStyle(fontSize: 15),),
                        onPressed: (){
                          wireguardRun();

                        },
                        color: Colors.red,
                        textColor: Colors.yellow,

                        splashColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                          side: BorderSide(color: Colors.black),
                        ) ,
                      )

                    ],
                  )

                )
                ,
                SizedBox(
                  height: 155.0,
                  child: svg,
                ),
                SizedBox(height: 25.0),
                Form(
                  key:_formKey,
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      emailField,
                      SizedBox(height: 15.0),
                      passwordField,
                      SizedBox(
                        height: 15.0,
                      ),
                      loginButon,
                      SizedBox(
                        height: 15.0,
                      ),
                      registerButon,
                      SizedBox(
                        height: 15.0,
                      ),
                    ],
                  ))

              ],
            ),
          ),
        ),
      ),
    );

  }
}
