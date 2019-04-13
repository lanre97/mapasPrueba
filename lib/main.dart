import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main(){

  final DocumentReference=Firestore.instance.collection("posiciones").document("prueba");
  Position currentPosition=new Position(151.0,15989.0);


}

class Position {
  double latitude;
  double longitude;
  Position(this.longitude,this.latitude);
}

void add(Position position, DocumentReference documentReference){
  Map<String, String>data=<String, String>{
    "latitude":position.latitude.toString(),
    "longitude":position.longitude.toString()
  };
  documentReference.setData(data).whenComplete((){
    print("print added");
  }).catchError((e)=>print(e));
}

