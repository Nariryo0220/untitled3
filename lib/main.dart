import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

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
      theme: ThemeData(
        textTheme: GoogleFonts.zenMaruGothicTextTheme(
          Theme.of(context).textTheme
        ),
      ),
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

  //List<BitmapDescriptor> colorList = [];

  List<double> ido = [];
  List<double> keido = [];
  List<String> kubun =[];
  List<String> namae = [];
  List<String> zyouhou1 = [];
  List<String> zyouhou2 = [];
  List<String> zyouhou3 = [];
  List<String> zyouhou4 = [];
  List<String> zyuusyo = [];
  List<String> color = [];


  Position? currentPosition;
  late GoogleMapController _controller;
  late StreamSubscription<Position> positionStream;
  late LatLng _initialPosition;
  late bool _loading;
  late GoogleMap gm;
  //GoogleMap?  gm;
  late Divider line;
  //late BitmapDescriptor markercolor;

  //String markerkubun = "";


  GeoPoint pos = const GeoPoint(0.0, 0.0);

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high, //正確性:highはAndroid(0-100m),iOS(10m)
    distanceFilter: 100,
  );



  @override
  void initState() {
    super.initState();
    // Future(() async {
    //
    //   }
    // });
    // gm = GoogleMap(
    //   initialCameraPosition: CameraPosition(
    //     target: ,
    //   ),
    // );

    // gm = GoogleMap(initialCameraPosition:
    // CameraPosition (
    //     target: LatLng(40,140)
    // ),
    // );
    _loading = true;
    _getUserLocation();
    //_markercolor();

  }

  //現在地を取得する
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

  // void _markercolor(){
  //   documentList.forEach((elem) {
  //      markerkubun = elem.get('kubun');
  //   });
  //   for (int count = 0;  markerkubun.length < count; count++){
  //     if (markerkubun[count] == 'コンビニ'){
  //       //BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  //       colorList[count] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  //     }else if (markerkubun[count] == 'スーパー・生協'){
  //       //BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  //       colorList[count] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
  //     }else if (markerkubun[count] == '公衆トイレ'){
  //       //BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  //       colorList[count] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  //     }
  //   }
  // }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('青森県トイレマップ'),
          backgroundColor: Colors.orange,
        actions: [
          IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {},
          )
        ],
      ),
      body: FutureBuilder(
        future: initialize1(),
        builder: (context, snapshot) {
          documentList.forEach((elem) {
            ido.add(elem.get('ido'));
            keido.add(elem.get('keido'));
            kubun.add(elem.get('kubun'));
            namae.add(elem.get('namae'));
            zyouhou1.add(elem.get('zyouhou1'));
            zyouhou2.add(elem.get('zyouhou2'));
            zyouhou3.add(elem.get('zyouhou3'));
            zyouhou3.add(elem.get('zyouhou4'));
            zyuusyo.add(elem.get('zyuusyo'));
            color.add(elem.get('color'));
          });
          return gm;


        },
      ),
    );
  }



  Future<void> initialize1() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('toire').get();
    documentList = snapshot.docs;

      print("##################################################### initialize()");
      documentList.forEach((elem) {
        print(elem.get('ido'));
        print(elem.get('keido'));
        print(elem.get('kubun'));
        print(elem.get('namae'));
        print(elem.get('zyouhou1'));
        print(elem.get('zyouhou2'));
        print(elem.get('zyouhou3'));
        print(elem.get('zyouhou4'));
        print(elem.get('zyuusyo'));
        print(elem.get('color'));
      });
      print("##################################################### initialize()");
      initialize2();
    }

  Future<void> initialize2() async {

    initialize3();

    line =  Divider(
      color: Colors.black54,
      thickness: 1,
      height: 4,
      indent: 10,
      endIndent: 10,
    );


    gm = await GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _initialPosition,
        zoom: 17,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
      },
      markers: documentList
          .map((documents) => Marker(
        markerId: MarkerId(documents['namae']),
        // icon: BitmapDescriptor.defaultMarkerWithHue(
        //   documents['color']
        // ),
        //icon: colorList,
        //icon: markercolor,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        //icon: markercolor,
        position: LatLng(documents['ido'],documents['keido']),
        onTap: () {
          showModalBottomSheet(
            isScrollControlled: true,
            isDismissible: true,
            context: context,
            builder: (BuildContext context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    height: 35,
                    width: double.infinity,
                    color: Colors.blueAccent,
                    alignment: Alignment.center,
                    child: Text(documents['namae'],style: TextStyle(color:Colors.white, fontSize: 13)),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.place),
                        color: Colors.black54,
                      ),
                      Text(documents['zyuusyo']),
                    ],
                  ),
                  line,
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.local_phone),
                        color: Colors.black54,
                      ),
                      Text(documents['zyouhou1']),
                    ],
                  ),
                  line,
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.local_parking),
                        color: Colors.black54,
                      ),
                      Text(documents['zyouhou2']),
                    ],
                  ),
                  line,
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.accessible_outlined),
                        color: Colors.black54,
                      ),
                      Text(documents['zyouhou3']),
                    ],
                  ),
                  line,
                       Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.other_houses),
                            color: Colors.black54,
                          ),
                          Flexible(
                            child: Container(
                              padding:  EdgeInsets.only(right: 10.0),
                              child:  Text(documents['zyouhou4']),
                              ),
                            ),
                          // Text(documents['zyouhou4'],),
                        ],
                      ),

                ],
              );
            },
          );
        },
      ))
          .toSet(),
      myLocationEnabled: true,
    );
  }



  Future<void> initialize3() async {
    //現在地の許可
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

}
