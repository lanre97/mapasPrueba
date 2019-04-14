import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:prueba_gps/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main()=>runApp(new AppGPS());

class AppGPS extends StatefulWidget {
  @override
  _AppGPSState createState() => _AppGPSState();
}

class _AppGPSState extends State<AppGPS> {

  final  mainReference  =FirebaseDatabase.instance.reference();
  final String userKeySP='localUserKey';
  String userKey;
  List<User> users=new List<User>();
  Position currentPosition;

  void add(User user){
    DatabaseReference push=mainReference.push();
    String key=push.key;
    push.set(user.toJson()).whenComplete(() async{
      print("added");
      final SharedPreferences prefs=await SharedPreferences.getInstance();
      prefs.setString(userKeySP, key);
    }).catchError((e)=>print(e));

  }

  void read(){
    mainReference.onChildAdded.listen((event){
      setState(() {
        users.add(new User.fromSnapshot(event.snapshot));
      });
    });
  }
  
  void update(User user){
    mainReference.child(user.key).set(user.toJson());
    User oldUser;
    users.forEach((item){
      if(item.key==user.key)oldUser=item;
    });
    users[users.indexOf(oldUser)]=user;
  }

  void obtainKey() async{
    final SharedPreferences prefs=await SharedPreferences.getInstance();
    setState(() {
      this.userKey=prefs.getString(userKeySP);
    });
  }

  _AppGPSState(){
    read();
  }



  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: new AppBar(title: new Text('PruebaGPS'),),
        floatingActionButton: FloatingActionButton(
          child: new Icon(Icons.add),
          onPressed: (){
            Geolocator().getCurrentPosition().then((Position currPos){
              setState(() {
                currentPosition=currPos;
                if(userKey==null){
                  add(new User('user2',currentPosition.latitude,currentPosition.longitude));
                  obtainKey();
                }else{
                  update(User.whitKey(userKey,'user2Updated',currentPosition.latitude,currentPosition.longitude));
                }
              });
            });
          },
        ),
        body: Container(
          child: Center(
            child: new ListView.builder(
                itemCount: users.length,
                itemBuilder: (context,index){
                  final user=users[index];
                  return GestureDetector(
                    child: Column(
                      children: <Widget>[
                        Text('name: '+user.name),
                        Text('latitude: '+user.latitude.toString()),
                        Text('longitude: '+user.longitude.toString() )
                      ],
                    ),
                    onTap: (){
                      setState(() {
                        update(new User.whitKey(user.key, 'userUpdated', user.latitude, user.longitude));
                      });
                    },
                  );
                },
            ),
          ),
        )
      ),
    );
  }
}

