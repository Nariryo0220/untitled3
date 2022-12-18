import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late BitmapDescriptor markercolor;
  //String markerkubun = "";

  //documentListに保管した値を個別に格納するList
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


  Position? currentPosition;//現在地を更新
  late StreamSubscription<Position> positionStream;
  late LatLng _initialPosition;//初期位置
  late bool _loading;
  late GoogleMap gm;
  late GoogleMapController _controller;
  late Divider line;

  //表示範囲制限用のLatlng
  late LatLng restriction1;
  late LatLng restriction2;


  //route変数
  List<LatLng> points = [];//pointsに入っている2点間をつなげてルートが引かれる
  MapsRoutes route = new MapsRoutes();
  String googleApiKey = '';//push時にAPIは削除！！
  String totalDistance = '距離';
  String destination = '目的地';
  DistanceCalculator distanceCalculator = new DistanceCalculator();//距離を測る


  //GeoPoint Lmin = const GeoPoint(0.0, 0.0);

  //最短
  List<double> I = [];//緯度
  List<double> K = [];//経度
  List<String> N = [];//名前
  List<String> B = [];//区分
  double min = 100000.0;
  String Nmin = '';
  var Lmin = LatLng(0.0, 0.0);
  var _switch1 = false;

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high, //正確性:highはAndroid(0-100m),iOS(10m)
    distanceFilter: 100,
  );

  _saveBool(String key, bool value) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  _restoreValues() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      _switch1 = prefs.getBool('bool1') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    _restoreValues();
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
        width: 240,
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
                    ExpansionTile(
                      title: Row(
                        children:[
                          Icon(Icons.settings_applications),
                          Text(" 最短ルート探索の設定"),
                        ]
                      ),
                      children: [
                        SwitchListTile(
                          title: Column(
                            children: [
                              Text('公衆トイレを',style: TextStyle(fontSize: 12)),
                              Row(
                                children: [
                                  Text('含んで検索',style: TextStyle(color:Colors.red,fontSize: 12)),
                                  Text('/',style: TextStyle(fontSize: 12)),
                                  Text('含まず検索',style: TextStyle(color:Colors.blue,fontSize: 12),),
                                ],
                              )
                            ],
                          ),
                          activeColor: Colors.redAccent,
                          activeTrackColor: Colors.red,
                          inactiveThumbColor: Colors.lightBlueAccent,
                          inactiveTrackColor: Colors.blueAccent,
                          value: _switch1,
                          onChanged: (bool value) {
                              setState(() {
                                _switch1 = value;
                                _saveBool('bool1', value);
                                print("_switch1");
                              });
                          }
                      ),


                      ],
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
          DLR.forEach((elem) {
            N.add(elem.get('namae'));
            I.add(elem.get('ido'));
            K.add(elem.get('keido'));
            B.add(elem.get('kubun'));
          });

          return gm;
        },
      ),
      bottomNavigationBar: SizedBox(
        height: 54,
        child :BottomAppBar(
          color: Colors.orange,
          child: Column(
            children: [
              Row(
                  children: [
                    //目的地
                    Container(
                        margin: EdgeInsets.only(left: 5,top: 3),
                        child :SizedBox(
                          width: 280,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.white),
                            ),
                            child: Text(destination, textAlign: TextAlign.center, style: TextStyle(
                                color:Colors.black38,
                                fontSize: 13,
                                fontWeight: FontWeight.bold
                            )
                            ),

                          ),
                        )
                    ),
                    //距離
                    Container(
                      margin: EdgeInsets.only(left: 5,top: 3),
                      child: SizedBox(
                        width: 63,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: null,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.white),
                          ),
                          child: Text(totalDistance,  textAlign: TextAlign.center,style: TextStyle(
                              color:Colors.black38,
                              fontSize: 13,
                              fontWeight: FontWeight.bold
                          ),
                          ),
                        ),
                      ),
                    ),
                  ]
              ),
            ],
          )

        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 15),
            child :SizedBox(
              width: 170,
              height: 55,
              child: FloatingActionButton.extended(
                tooltip: 'Action!',
                label: Text('最短ルート探索', style: TextStyle(
                    color:Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                )
                ),
                backgroundColor: Colors.orange,
                onPressed: () async {
                  Position position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high);
                  if (points == null){
                  }else{
                    points.clear();
                    route.routes.clear();
                  }
                  print('distanceInMeters============================================');
                  for (int count=0; DLR.length > count; count++){
                    //攻守トイレを含まず検索の場合スキップする
                    print(_switch1);
                    print(B[count]);
                    if ((_switch1 == false) && (B[count] == '公衆トイレ')) {
                      print('公衆トイレなので×');
                      continue;
                    }
                    print(N[count]);
                    print(I[count]);
                    print(K[count]);
                    print(B[count]);
                    //distanceInMeters 2点間の距離を測る
                    double distanceInMeters = Geolocator.distanceBetween(
                      position.latitude, position.longitude,
                      I[count], K[count],
                    );
                    print('距離 $distanceInMeters');
                    if (min > distanceInMeters){
                      Nmin = N[count];
                      min = distanceInMeters;
                      Lmin = LatLng(I[count],K[count]);
                    } else {
                    }
                  }
                  print('min $Nmin');
                  print('min $min');
                  print('min $Lmin');
                  print('distanceInMeters============================================');
                  destination = Nmin;
                  points.addAll(
                      [LatLng(_initialPosition.latitude,_initialPosition.longitude),
                        LatLng(Lmin.latitude,Lmin.longitude),]
                  );
                  await route.drawRoute(points, 'Test routes',
                      Color.fromRGBO(0,191,255, 1.0), googleApiKey,
                      travelMode: TravelModes.walking);
                  setState(() {
                    totalDistance =
                        distanceCalculator.calculateRouteDistance(points, decimals: 1);
                  });
                },
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            child: SizedBox(
              width: 170,
              height: 38,
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
                  destination = '目的地';
                  setState(() {});
                },
              ),
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

      // print("##################################################### initialize1()");
      // documentList.forEach((elem) {
      //   print(elem.get('ido'));
      //   print(elem.get('keido'));
      //   print(elem.get('kubun'));
      //   print(elem.get('namae'));
      //   print(elem.get('zyouhou1'));
      //   print(elem.get('zyouhou2'));
      //   print(elem.get('zyouhou3'));
      //   print(elem.get('zyouhou4'));
      //   print(elem.get('zyuusyo'));
      //   print(elem.get('color'));
      // });
      // print("##################################################### initialize1()");
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
    print('DLR===========================================================DLR');
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
    print('DLR===========================================================DLR');

    //GoogleMap変数
    gm = await GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _initialPosition,
        zoom: 15,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
      },
      markers: DLR.map((documents) => Marker(
        markerId: MarkerId(documents['namae']),
        // icon: BitmapDescriptor.defaultMarkerWithHue(
        //   documents['color']
        // ),
        //icon: colorList,
        //icon: markercolor,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        // icon: BitmapDescriptor.defaultMarkerWithHue(
        //   if (documents['kubun'] = 'コンビニ'){
        //     BitmapDescriptor.hueRed
        //   }
        // ),
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
                      Navigator.of(context).pop();
                      if (points == null){
                      }else{
                        points.clear();
                        route.routes.clear();
                      }
                      destination = documents['namae'];
                      //Geolocator.getCurrentPosition 現在地の座標を取得する
                      Position position = await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.high);
                      points.addAll(
                        [LatLng(position.latitude,position.longitude),
                          LatLng(documents['ido'],documents['keido']),]
                      );
                      print(points);
                      await route.drawRoute(points, 'Test routes',
                          Color.fromRGBO(0,191,255, 1.0), googleApiKey,
                          travelMode: TravelModes.walking);
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
                        onPressed: null,
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
                        onPressed: null,
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
                        onPressed: null,
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
                        onPressed: null,
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
                            onPressed: null,
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
      )).toSet(),
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
