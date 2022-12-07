import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_routes/google_maps_routes.dart';

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
  //Firestoreから取得したList
  List<DocumentSnapshot> documentList = [];
  //documentListから範囲制限をかけて取得したList
  List<DocumentSnapshot> DLR = [];

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
  late Divider line;

  //表示範囲制限用のLatlng
  late LatLng restriction1;
  late LatLng restriction2;
  //late BitmapDescriptor markercolor;

  //String markerkubun = "";

  //route変数
  List<LatLng> points = [];
  MapsRoutes route = new MapsRoutes();
  //push時にAPIは削除！！
  String googleApiKey = '';
  String totalDistance = '距離';
  DistanceCalculator distanceCalculator = new DistanceCalculator();

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

  //現在地を取得する
  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _loading = false;

      restriction1 = LatLng(
          _initialPosition.latitude + 0.0090133729745762,
          _initialPosition.longitude + 0.010966404715491394
      );
      restriction2 = LatLng(
          _initialPosition.latitude - 0.0090133729745762,
          _initialPosition.longitude - 0.010966404715491394
      );
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
      ),
      endDrawer: Drawer(
        width: 210,
        child: Column(
          children: [
            Expanded(
                child: ListView(
                  children:  [
                    Container(
                      height: 35,
                      width: double.infinity,
                      color: Colors.blueAccent,
                      alignment: Alignment.center,
                      child:  Text("メニュー一覧",style: TextStyle(
                          color:Colors.white,
                          fontSize: 16
                        )
                      ),
                    ),
                    ListTile(
                      title: Text("アプリの使い方"),
                      onTap: () {

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
                          print("Can't launch $url");
                        }
                      },
                    ),
                  ],
                ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('メニューを閉じる'),
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


      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 9),
            child: SizedBox(
              width: 120,
              height: 45,
              child: FloatingActionButton.extended(
                tooltip: 'Action!',
                  label: Text(totalDistance, style: TextStyle(
                      color:Colors.black38,
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  backgroundColor: Colors.white.withOpacity(0.9),
                  onPressed: null,
                ),
              ),
            ),
            SizedBox(
              width: 120,
              height: 40,
              child: FloatingActionButton.extended(
                tooltip: 'Action!',
                label: Text('ルート解除', style: TextStyle(
                    color:Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                  )
                ),
                backgroundColor: Colors.redAccent,
                onPressed: () {
                  //ルート、ルート用のList、距離の表示をクリア
                  route.routes.clear();
                  points.clear();
                  totalDistance = '距離';
                  setState(() {});
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> initialize1() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('toire').get();
    documentList = snapshot.docs;

      print("##################################################### initialize1()");
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
      print("##################################################### initialize1()");
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

    //documentListから範囲制限をかけて取得
    DLR = documentList.where((documents) {
      if ((documents['ido'] < restriction1.latitude && documents['ido'] > restriction2.latitude)
      && (documents['keido'] < restriction1.longitude && documents['keido'] > restriction2.longitude)) {
        return true;
      } else {
        return false;
      }
    }).toList();
    print('===========================================================');
    print(restriction1);
    print(restriction2);
    print('MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM');
    DLR.forEach((elem) {
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
    print('===========================================================');

    gm = await GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _initialPosition,
        zoom: 15,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
      },
      markers: DLR
          .map((documents) => Marker(
        markerId: MarkerId(documents['namae']),
        // icon: BitmapDescriptor.defaultMarkerWithHue(
        //   documents['color']
        // ),
        //icon: colorList,
        //icon: markercolor,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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
                      points.addAll(
                        [
                          LatLng(_initialPosition.latitude,_initialPosition.longitude),
                          LatLng(documents['ido'],documents['keido']),
                        ]
                      );
                         await route.drawRoute(points, 'Test routes',
                            Color.fromRGBO(0,191,255, 1.0), googleApiKey,
                            travelMode: TravelModes.walking);
                      Navigator.of(context).pop();
                      setState(() {
                        totalDistance =
                            distanceCalculator.calculateRouteDistance(points, decimals: 1);
                      });
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
      polylines: route.routes,
      myLocationEnabled: true,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      minMaxZoomPreference: MinMaxZoomPreference(8, 19),
    );
  }

  Future<void> initialize3() async {
    //現在地の許可
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
      //再描画
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => super.widget)
      );
    }

  }

}
