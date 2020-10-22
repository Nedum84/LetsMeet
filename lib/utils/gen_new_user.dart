

import 'dart:math';

class GenNewUser{
  var randNo = Random().nextInt(100);

  static List<User> users = [
    User(name: 'Emeka Paul', email: 'emekapaul@gmail.com', password: '89765431'),
    User(name: 'John Doe', email: 'johndoe@gmail.com', password: '89765431'),
    User(name: 'Emma Agwali', email: 'emmaagwali@gmail.com', password: '89765431'),
    User(name: 'Apeh Celestine', email: 'apehcel@gmail.com', password: '89765431'),
    User(name: 'Joe Goodey', email: 'joegoodey@gmail.com', password: '89765431'),
    User(name: 'Cyprian Paul', email: 'cyprainpaul@gmail.com', password: '89765431'),
    User(name: 'Jack Bauer', email: 'jackbauer@gmail.com', password: '89765431'),
    User(name: 'Chloe O\'brain', email: 'chloecomputer@gmail.com', password: '89765431'),
    User(name: 'Richele Dessler', email: 'dessler@gmail.com', password: '89765431'),
    User(name: 'Tony Ameida', email: 'tonya45@gmail.com', password: '89765431'),
    User(name: 'David Palmer', email: 'palmer_dav@gmail.com', password: '89765431'),
    User(name: 'Beruz Clinton', email: 'beruz562@gmail.com', password: '89765431'),
    User(name: 'Nelson CO.', email: 'nelly@gmail.com', password: '89765431')
  ];


  User newUser(){
    // String name = (names..shuffle()).first;
    // String password = '${randNo}LetsMeet';

    return users[Random().nextInt(users.length)];;
}

}

class User{
  User({this.name,this.email,this.password,this.address,this.latitude,this.longitude});

  var name;
  var email;
  final password;
  var address;
  var latitude;
  var longitude;
}