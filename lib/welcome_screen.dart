import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Container(
              child: Image.asset('assets/map.png'),
              padding: EdgeInsets.all(20.0),
            ),
          ),
          Container(
            child: Text('Map Locator',
            style: TextStyle(
              color: Colors.black,
              wordSpacing: 20.0,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),),
          )
        ],
      ),
    );
  }
}
