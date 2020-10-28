import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location_tracker/screens/select_user.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'splash_screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3),(){

      // Navigator.pushNamed(
      //   context,
      //   SelectUser.id,
      // );

      Navigator.pushReplacementNamed(context, SelectUser.id);//without back trace
      // Navigator.pushNamedAndRemoveUntil(context, SelectUser.id, (Route<dynamic> route) => false);//without back trace
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white70,
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text('Let\'s Meet',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),),
        ),
      ),
    );
  }
}
