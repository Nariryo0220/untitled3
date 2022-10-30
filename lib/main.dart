import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Names',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {

  List<DocumentSnapshot> documentList =[];
  List<String> name = [];
  List<double> ido = [];
  List<double> keido = [];
  List<GeoPoint> idokeido = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map')),
      body: FutureBuilder(
        future: initialize(),
        builder: (context, snapshot) {
          documentList.forEach((elem) {
            name.add(elem.get('name'));
            ido.add(elem.get('ido'));
            keido.add(elem.get('keido'));
            idokeido.add(elem.get('idokeido'));

          });
          return Column(
            children: <Widget> [
              Text(name[0] + ':' + ido[0].toString() + ':' + keido[0].toString() + '###' + idokeido[0].latitude.toString() + ':' + idokeido[0].longitude.toString()),
              Text(name[1] + ':' + ido[1].toString() + ':' + keido[1].toString() + '###' + idokeido[1].latitude.toString() + ':' + idokeido[1].longitude.toString()),
            ],
          );
        },
      ),
    );
  }

  Future<void> initialize () async {
    final snapshot =
      await FirebaseFirestore.instance.collection('toire').get();
    documentList = snapshot.docs;
    GeoPoint pos = const GeoPoint(0.0,0.0);

    print("##################################################### initialize()");
    documentList.forEach((elem) {
      print(elem.get('name'));
      print(elem.get('ido'));
      print(elem.get('keido'));
      pos = elem.get('idokeido');
      print(pos.latitude.toString() + ',' + pos.longitude.toString());
    });
    print("##################################################### initialize()");
  }

}
