import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map',
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

  List<DocumentSnapshot> documentList = [];
  List<String> name = [];
  List<double> ido = [];
  List<double> keido = [];
  List<GeoPoint> idokeido = [];

  Position? currentPosition;
  late GoogleMapController _controller;
  late StreamSubscription<Position> positionStream;
  late LatLng _initialPosition;
  late bool _loading;

  GeoPoint pos = const GeoPoint(0.0, 0.0);

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high, //正確性:highはAndroid(0-100m),iOS(10m)
    distanceFilter: 100,
  );

  @override
  void initState() {
    super.initState();
    _loading = true;
    _getUserLocation();
  }

  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _loading = false;
      print(position);
    });
  }

  //現在位置を更新し続ける
  void positionstrem() {
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
          currentPosition = position;
          print(position == null
              ? 'Unknown'
              : '${position.latitude.toString()}, ${position.longitude
              .toString()}');
        });
  }

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
            //pos = elem.get('idokeido');
          });
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 17,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            markers: documentList
              .map((documents) => Marker(
                markerId: MarkerId(documents['name']),
                position: LatLng(documents['ido'],documents['keido']),
              ))
              .toSet(),
            onTap: (LatLng latLang) {
              print('Clicked: $latLang');
            },
            myLocationEnabled: true,
          );
        },
      ),
    );
  }

  Future<void> initialize() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('toire').get();
    documentList = snapshot.docs;
    GeoPoint pos_con = const GeoPoint(0.0, 0.0);

    // LocationPermission permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.denied) {
    //   await Geolocator.requestPermission();

      print(
          "##################################################### initialize()");
      documentList.forEach((elem) {
        print(elem.get('name'));
        print(elem.get('ido'));
        print(elem.get('keido'));
        pos_con = elem.get('idokeido');
        print(pos_con.latitude.toString() + ',' + pos.longitude.toString());
      });
      print(
          "##################################################### initialize()");
    }
  }
//}