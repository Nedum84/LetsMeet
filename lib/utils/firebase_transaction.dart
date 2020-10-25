import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';



final _firestore = FirebaseFirestore.instance;
class FirebaseTransaction{


  static Future<void> addUserToDb(Position position, String email, String address) async{
    var items = await _firestore.collection('location')
        .where('email', isEqualTo: email)
        .limit(2)
    // .orderBy('email', descending:true)
        .get();


    if(items.docs.isNotEmpty){
      _firestore.collection('location')
          .doc(items.docs[0].id)//id to update
          .update({'latitude': position.latitude, 'longitude': position.longitude, 'address': address})
          .then((value){
      }).catchError((error) => print("Failed to update user: $error"));
    }else{
      await _firestore.collection('location').add({
        'email': email,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address}).then((value) {
      }).catchError((error) => print("Failed to insert user: $error"));;
    }
  }
}

