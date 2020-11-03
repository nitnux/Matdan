import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/svg.dart';
import 'package:e_voting/Cam.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';

class Register extends StatefulWidget{
  @override
  _RegisterState createState() => _RegisterState();
}
class _RegisterState extends State<Register>{
  final _formKey = GlobalKey<FormState>();
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  String _email = '';

  String _video ='';
  String _voter='';
  String _aadhar='';
  String _phone='';
  String _password='';
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
  String validatePhone(String value) {
    if (value.isEmpty) {
      return 'Please enter phone no';
    }

    Pattern pattern =
        r'^(?=.*\d).{10}$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid 10 digit mobile no.';
    else
      return null;
  }
  String validateVoter(String value) {
    if (value.isEmpty) {
      return 'Please enter voter id';
    }

    Pattern pattern =
        r'^(?=.*\d)(?=.*[a-zA-Z]).{10}$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid 10 digit ';
    else
      return null;
  }
  String validateAadhar(String value) {
    if (value.isEmpty) {
      return 'Please enter aadhar no';
    }

    Pattern pattern =
        r'^(?=.*\d).{12}$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid 12 digit';
    else
      return null;
  }
  Dio post(){
    Dio dio = new Dio();
    dio.options.baseUrl = "http://localhost:3000/";
    dio.interceptors.add(LogInterceptor());
    (dio.httpClientAdapter as DefaultHttpClientAdapter ).onHttpClientCreate  = (client) {
      SecurityContext sc = new SecurityContext();
      String file='';
      //file is the path of certificate
      sc.setTrustedCertificates(file);
      HttpClient httpClient = new HttpClient(context: sc);
      return httpClient;
    };

    return dio;

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
    final Widget emailField = TextFormField(
      obscureText: false,
      validator: validateEmail,
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
    final _controller = TextEditingController();
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
        onSaved: (value){
          setState(() {
            _password = value;

          });
        }
    );
    final phoneNoField=TextFormField(

      validator: validatePhone,
      keyboardType: TextInputType.phone,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "phone no",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
        onSaved: (value){
          setState(() {
            _phone = value;

          });
        }
    );

    final voterIdField = TextFormField(

      validator: validateVoter,
      keyboardType: TextInputType.text,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "voter id",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
        onSaved: (value){
          setState(() {
            _voter = value;

          });
        }
    );

    final aadharIdField = TextFormField(

      validator: validateAadhar,
      keyboardType: TextInputType.text,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "aadhar id",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
        onSaved: (value){
          setState(() {
            _aadhar = value;

          });
        }
    );
    String path='';
    final videoField = TextFormField(
      obscureText: true,
      controller: _controller,


      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "your video",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      onTap: ()async{
        cam();
          path = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CameraExampleHome(cameras)),
        );



        _controller.text =path;
      },
      onSaved: (value){
        setState(() {
          _video = value;

        });
      },

    );
    final submitButon=Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: ()async {
          if (_formKey.currentState.validate()) {
            // If the form is valid, display a Snackbar.
            _formKey.currentState.save();
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Processing Data')));
            Response response;
            Dio dio=post();
            FormData formData = FormData.fromMap({
              "email": _email,
              "password":_password,
              "phone":_phone,
              "voter":_voter,
              "aadhar":_aadhar,

              "file": await MultipartFile.fromFile(
                _video,
                filename: "video",
              )
            });

            // Send FormData
            response = await dio.post("/test", data: formData);
            print(response);



          Navigator.pop(context);
          }},
        child: Text("Submit",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: size.height * 0.03),
            Text(
              "SIGNUP",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.03),
            svg,
            Form(
                key:_formKey,
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    emailField,
                    SizedBox(height: size.height * 0.03),
                    passwordField,
                    SizedBox(height: size.height * 0.03),
                    phoneNoField,
                    SizedBox(height: size.height * 0.03),
                    voterIdField,
                    SizedBox(height: size.height * 0.03),
                    aadharIdField,
                    SizedBox(height: size.height * 0.03),
                    videoField,
                    SizedBox(height: size.height * 0.03),

                    submitButon,
                    SizedBox(height: size.height * 0.03),
                  ],
                ))

          ],
        ),
      ),

    );
  }

}
