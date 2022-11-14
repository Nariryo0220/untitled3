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

  List<double> ido = [];
  List<double> keido = [];
  List<String> kubun =[];
  List<String> namae = [];
  List<String> zyouhou1 = [];
  List<String> zyouhou2 = [];
  List<String> zyouhou3 = [];
  List<String> zyouhou4 = [];
  List<String> zyuusyo = [];


  Position? currentPosition;
  late GoogleMapController _controller;
  late StreamSubscription<Position> positionStream;
  late LatLng _initialPosition;
  late bool _loading;
  late GoogleMap gm;
  late Divider line;
  late Icon coloricon;



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
    _loading = true;
    _getUserLocation();

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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('青森県トイレマップ'),backgroundColor: Colors.orange,),
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
      });
      print("##################################################### initialize()");
      initialize2();
    }

  Future<void> initialize2() async {
    line =  Divider(
      color: Colors.black54,
      thickness: 1,
      height: 4,
      indent: 10,
      endIndent: 10,
    );

    // coloricon = Icon(if (documents['kubun'] == 'コンビニ'){
    //   BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    // }else if (documents['kubun'] == 'スーパー・生協'){
    //   BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.huepink);
    // }else{
    //   BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.huered);
    // });

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
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: LatLng(documents['ido'],documents['keido']),
        onTap: () {
          showModalBottomSheet(
            isScrollControlled: true,
            isDismissible: true,
            context: context,
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            // ),
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



  // Future<void> initialize3() async {
  //   //現在地の許可
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     await Geolocator.requestPermission();
  //   }
  // }

}
