import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'splash_screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


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
              child: Image.asset('images/lm_two_user.jpg'),
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
