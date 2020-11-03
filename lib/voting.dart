import 'package:flutter/material.dart';
class voting extends StatefulWidget {

  @override
  _votingState createState() => _votingState();

}
class _votingState extends State<voting>{

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body:
           ListView(
               children: <Widget>[
                 ListTile(
                   leading: Icon(Icons.wb_sunny),
                   title: Text('BJP'),
                 ),
                 ListTile(
                   leading: Icon(Icons.brightness_3),
                   title: Text('INC'),
                 ),
                 ListTile(
                   leading: Icon(Icons.star),
                   title: Text('RJD'),
                 ),
               ],
          )
    );}
}