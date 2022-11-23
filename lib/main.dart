import 'dart:async';
//import 'package:google_directions_api/google_directions_api.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

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


  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "";
  Map<PolylineId, Polyline> polylines = {};

  LatLng startLocation = LatLng(40.82994117,140.7688488);
  LatLng endLocation = LatLng(40.8274858,140.7665709);


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
    getDirections();
    //_markercolor();
    //main();
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


  // void main() {
  //   DirectionsService.init('自分のAPIキー');
  //
  //   final directionsService = DirectionsService();
  //
  //   final request = DirectionsRequest(
  //     origin: 'New York',
  //     destination: 'San Francisco',
  //     travelMode: TravelMode.driving,
  //   );
  // }

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

  void getDirections() async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(startLocation.latitude, startLocation.longitude),
      PointLatLng(endLocation.latitude, endLocation.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      print(result.errorMessage);
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }
    _addPolyLine(polylineCoordinates);
  }

  _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 4,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('青森県トイレマップ'),
          backgroundColor: Colors.orange,
        // actions: [
        //   IconButton(
        //       icon: Icon(Icons.more_vert),
        //       onPressed: () {},
        //   )
        // ],
      ),
      endDrawer: Drawer(
        width: 210,
        child: ListView(
          children:  [
            Container(
              height: 35,
              width: double.infinity,
              color: Colors.blueAccent,
              alignment: Alignment.center,
              child:  Text("メニュー一覧",style: TextStyle(color:Colors.white, fontSize: 16)),
            ),
            ListTile(
                title: Text("アプリの使い方"),
                onTap: () {
                  print('ontap');
                },
            ),
            ListTile(
              title: Text("トイレ情報修正案"),
              subtitle: Text("（Google Forms）"),
              onTap: () async {
                  final url = Uri.parse(
                    'https://docs.google.com/forms/d/e/1FAIpQLSczt2P7yPl4FXtT-qYfXxHPoC3Y5-mcmeffyrtmWByZRISCXA/viewform',
                  );
                  if (await canLaunchUrl(url)) {
                    launchUrl(url);
                  } else {
                  // ignore: avoid_print
                    print("Can't launch $url");
                  }
                },
            ),
            ListTile(
              title: Text("アプリの評価"),
              subtitle: Text("（Google Forms）"),
              onTap: () async {
                final url = Uri.parse(
                  'https://docs.google.com/forms/d/e/1FAIpQLScuUDQ81k8TPi2w15trgbMQeUhq_fFTafpPZZF86vfldDPt0g/viewform',
                );
                if (await canLaunchUrl(url)) {
                  launchUrl(url);
                } else {
                  // ignore: avoid_print
                  print("Can't launch $url");
                }
              },
            ),
          ],
        ),
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
                  OutlinedButton(
                    onPressed: () async {

                      //   final request = DirectionsRequest(
                      //     origin: LatLng(40.82786796872886, 140.76960330877847),
                      //     destination: LatLng(documents['ido'],documents['keido']),
                      //     travelMode: TravelMode.driving,
                      //   );
                      // request;
                    },
                    child: Text('ルート検索'),
                  ),
                  line,
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
      polylines: Set<Polyline>.of(polylines.values),
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
