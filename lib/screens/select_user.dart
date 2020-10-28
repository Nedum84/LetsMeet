import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_tracker/utils/gen_new_user.dart' as nUser;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:location_tracker/utils/firebase_transaction.dart';
import 'track_user.dart';



class SelectUser extends StatefulWidget {
  static const String id = 'select_user';
  @override
  _SelectUserState createState() => _SelectUserState();
}

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class _SelectUserState extends State<SelectUser> {
  String _myAddress = 'No address';
  String _myName = '';
  String _myEmail;
  List<nUser.User> users = [];
  bool showSpinner = false;



  @override
  void initState(){
    super.initState();
    setState(() {
      showSpinner = true;
    });
    
    Firebase.initializeApp().whenComplete(() async{
      final _auth = FirebaseAuth.instance;

      _auth.authStateChanges().listen((User user) async{
        if (user == null) {
          print('User is currently signed out! or not logged IN');
          try {
            var user = nUser.GenNewUser().newUser();//From my Local User model class
            final newUser = await _auth.createUserWithEmailAndPassword(email: user.email, password: user.password);
            if (newUser != null) {
              addNewUserToDb(user.email);
              // print(newUser);
            }
          } on FirebaseAuthException catch (e) {
            if (e.code == 'weak-password') {
              print('The password provided is too weak.');
            } else if (e.code == 'email-already-in-use') {
              print('The account already exists for that email.');
            }
          } catch (e) {//e is the error message like 'The email address is already in use by another account.'
            print(e);
          }
        } else {
          print('User is signed in!');//user.email
          loggedInUser = user;


          addNewUserToDb(user.email);//update db with your current location
          print(loggedInUser);
        }
      });
    });




  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      // appBar: AppBar(title: Text('Welcome!'),),
      body: ModalProgressHUD(
        opacity: .5,
        inAsyncCall: showSpinner,
        color: Colors.black,
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
                        // FirebaseAuth.instance.signOut();
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.all(Radius.circular(100.00)),
                        ),
                        child: Image.asset('images/logo.png'),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Text('Hi, $_myName',
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
                        fontSize: 23.0,
                        fontWeight: FontWeight.bold
                      ),),
                    Row(
                      children: [
                        Icon(Icons.location_on,size: 14,color: Colors.white,),
                        Text(' $_myAddress',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                          ),),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 20),
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
                          fontSize: 20.0,
                          // fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        child: Divider(
                          color: Colors.blueGrey.shade100,
                          thickness: 1,
                        ),
                      ),

                      Expanded(
                        child: Container(
                          child: ListView.builder(
                            // scrollDirection: Axis.horizontal,
                            itemCount: users!=null?users.length:0,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: (){
                                  Navigator.pushNamed(
                                      context,
                                      TrackUser.id,
                                      arguments: {
                                        'name': users[index].name,
                                        'email': users[index].email,
                                        'address': users[index].address,
                                        'latitude': users[index].latitude,
                                        'longitude': users[index].longitude,
                                        'my_name': _myName,
                                        'my_address': _myAddress,
                                        'my_email': _myEmail
                                      }
                                  );
                                },
                                child: Container(
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
                                                    Text(users[index].name,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.w500,
                                                      ),),
                                                    Text('${users[index].address}',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.blueGrey
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
                              );
                            },
                          ),
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

  void getUsers() async{
    await _firestore.collection('location')
    // .where('email', isEqualTo: loggedInUser.email)
    //     .limit(10)
        .snapshots().forEach((element) {
      for(var item in element.docs){
        if(_myEmail == item.data()['email']) continue;//skipp my own...
        if(users.length!=0 && users.where((element) => element.email==item.data()['email']).length!=0) continue;//skipp if already added...

        var name = nUser.GenNewUser.users.where((element) => element.email==item.data()['email']).first.name;

        setState(() {
          users.add(
              nUser.User(
                name: name,
                email: item.data()['email'],
                address: item.data()['address'],
                latitude: item.data()['latitude'],
                longitude: item.data()['longitude'],
                id: item.id
              )
          );
        });


      }
    });
  }

  void addNewUserToDb(String email) async{
    _myEmail = email;
    setState(() {
      _myName = nUser.GenNewUser.users.where((element) => element.email==email).first.name;
    });

    await getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) async {
      final coordinates = Coordinates(position.latitude, position.longitude);// From coordinates
      var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;

      setState(() {_myAddress = first.addressLine;});

      await FirebaseTransaction.addUserToDb(position, email, first.addressLine).then((value) {
        getUsers();
      }).catchError((e) { print(e); });


      setState(() {showSpinner = false; });
    }).catchError((e) {
      print(e);
    });
  }
}
