import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:location_tracker/ui/select_user.dart';
import 'map_location.dart';
import 'ui_map.dart';
import 'welcome_screen.dart';

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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: WelcomeScreen(),
      initialRoute: SelectUser.id,
      routes: {
        WelcomeScreen.id: (context)=> WelcomeScreen(),
        SelectUser.id: (context)=> SelectUser(),
        MapLocation.id: (context) => MapLocation(title: "Map Screen",),
        UiMap.id: (context) => UiMap(),
      },
    );
  }
}

