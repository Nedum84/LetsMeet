import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'file:///C:/Users/NEDUM/AndroidStudioProjects/location_tracker/lib/screens/select_user.dart';
import 'screens/track_user.dart';
import 'screens/splash_screen.dart';

void main() {//async
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Let\'s Meet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // canvasColor: Colors.transparent,
      ),
      // home: WelcomeScreen(),
      initialRoute: SelectUser.id,
      routes: {
        SplashScreen.id: (context)=> SplashScreen(),
        SelectUser.id: (context)=> SelectUser(),
        TrackUser.id: (context) => TrackUser(title: "Track User",),
      },
    );
  }
}

