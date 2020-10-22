import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:location_tracker/map_location.dart';
import 'package:location_tracker/utils/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';


class SelectUser extends StatefulWidget {
  static const String id = 'select_user';
  @override
  _SelectUserState createState() => _SelectUserState();
}

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class _SelectUserState extends State<SelectUser> {
  bool showSpinner = false;
  String email = 'nelly@gmail.com';
  String password = '222222';

  @override
  void initState(){
    super.initState();
    setState(() {
      showSpinner = true;
    });

    Firebase.initializeApp().whenComplete(() async{
      final _auth = FirebaseAuth.instance;
      try {
        final newUser = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        if (newUser != null) {
          // Navigator.pushNamed(context, ChatScreen.id);
          print(newUser);
        }

        setState(() {
          showSpinner = false;
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
        setState(() {showSpinner = false;});
      } catch (e) {//e is the error message like 'The email address is already in use by another account.'
        print(e);
        setState(() {showSpinner = false;});
      }

      await _auth.authStateChanges()
          .listen((User user) {
        if (user == null) {
          print('User is currently signed out!');
        } else {
          print('User is signed in!');//user.email
          // _auth.signOut();//to sign ouy
          loggedInUser = user;
          print(loggedInUser);
        }
      });

      // try {
      //   final user = _auth.currentUser;
      //   if (user != null) {
      //     loggedInUser = user;
      //     print(loggedInUser);
      //   }
      // } catch (e) {
      //   print(e);
      // }

      _firestore.collection('location').add({
        'email': loggedInUser.email,
        'latitude': '4567890iuhgg',
        'longitude': 'dfghjk9876efghjklkj',
      });

      // _firestore.collection('location')
      //     .where('email', isEqualTo: loggedInUser.email)
      //     .limit(10)
      //     .get()
      //     .then((value){
      //   for(var item in value.docs){
      //     print(item.data());
      //   }
      // });

      // CollectionReference users = FirebaseFirestore.instance.collection('users');
      // Future<void> updateUser() {
      //   return users
      //       .doc(loggedInUser.email)//id to update
      //       .update({'company': 'Stokes and Sons'})
      //       .then((value) => print("User Updated"))
      //       .catchError((error) => print("Failed to update user: $error"));
      // }

      _firestore.collection('location')
          .where('email', isEqualTo: loggedInUser.email)
          .limit(10)
          .snapshots().forEach((element) {
        for(var item in element.docs){
          print(item.data());
        }
      });


      // var items = await _firestore.collection('location').get();
      // for(var item in items.docs){
      //   print(item.data());
      // }


      // await for(var items in _firestore.collection('location').snapshots()){
      //   for(var item in items.docs){
      //     print(item.data());
      //   }
      // }
    });




  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      // appBar: AppBar(title: Text('Welcome!'),),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 70.0, left: 20,bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: (){
                        Navigator.pushNamed(context, MapLocation.id);
                        Navigator.pushNamed(
                            context,
                            MapLocation.id,
                            arguments: {
                              'arg1': 'val1',
                              'arg2': 'val2',
                              'exampleArgument': 'exampleArgument  ====   exampleArgument  ====   exampleArgument  ====   exampleArgument  ====   exampleArgument  ====   '
                            }
                        );
                      },
                      child: CircleAvatar(
                        child: Icon(Icons.list,size: 30, color: Colors.lightBlueAccent,),
                        backgroundColor: Colors.white,
                        radius: 30,
                      ),
                    ),
                    SizedBox(height: 10,),
                    Text('Hi, User',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 20.0,
                      ),),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Meet a New Friend Today',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          // fontWeight: FontWeight.w700,
                          fontWeight: FontWeight.bold
                      ),),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0),topRight: Radius.circular(20.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('Choose a friend to meet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          // fontWeight: FontWeight.bold
                        ),
                      ),

                      SizedBox(
                        height: 20.0,
                        width: 150.0,
                        child: Divider(
                          color: Colors.teal.shade50,
                          thickness: 2,
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Text('1.',
                                // style: TextStyle(fontSize: 50),),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(top: 8, left: 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Emeka Paul',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                          ),),
                                        Text('1.3km from you',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                          ),),
                                      ],
                                    ),
                                  ),
                                ),
                                CircleAvatar(
                                  child: Icon(Icons.arrow_forward_ios, color: Colors.white54,),
                                  backgroundColor: Colors.blueGrey,
                                ),
                                SizedBox(width: 15,)
                              ],
                            ),
                            SizedBox(
                              height: 20,
                              child: Divider(
                                thickness: 1,
                                color: Colors.black12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.0,
                          vertical: 5.0,
                        ),
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: countryArray.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Card(
                                  color: Colors.blue,
                                  child: Container(
                                    child: Center(
                                        child: Text(
                                          countryArray[index].toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 36.0,
                                          ),
                                        )),
                                  ),
                                ),
                              );
                            }),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.0,
                          vertical: 5.0,
                        ),
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: ListView.builder(
                          // scrollDirection: Axis.horizontal,
                          // itemCount: 2,
                          itemBuilder: (context, index) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Title $index',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Text('subtitle'),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Title',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Text('subtitle'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
