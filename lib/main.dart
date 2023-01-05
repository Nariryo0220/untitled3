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
import 'PrivacyPolicy.dart';
import 'AppUsage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '青森県トイレマップ',
      theme: ThemeData(
        textTheme:
        GoogleFonts.zenMaruGothicTextTheme(Theme.of(context).textTheme),
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
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

  //documentListに保管した値を個別に格納するList
  List<double> Llatitude = [];
  List<double> Llongitude = [];
  List<String> classification = [];
  List<String> name = [];
  List<String> phone = [];
  List<String> parking = [];
  List<String> toilets = [];
  List<String> other = [];
  List<String> address = [];

  //情報閲覧機能の線
  late Divider line;

  //GoogleMap変数
  Position? currentPosition; //現在地を更新
  late StreamSubscription<Position> positionStream;
  late LatLng initialPosition; //初期位置
  late bool loading;
  late GoogleMap gm;
  late GoogleMapController _controller;

  //表示範囲制限用のLatlng
  late LatLng restriction1;
  late LatLng restriction2;
  int Markercount = 0;

  //ルート変数
  List<LatLng> points = []; //pointsに入っている2点間をつなげてルートが引かれる
  MapsRoutes route = new MapsRoutes();
  String googleApiKey = ''; //push時にAPIは削除！！
  String totalDistance = '距離';
  String destination = '目的地';
  DistanceCalculator distanceCalculator = new DistanceCalculator(); //距離を測る

  //最短経路
  List<double> I = []; //緯度
  List<double> K = []; //経度
  List<String> N = []; //名前
  List<String> B = []; //区分
  double min = 100000.0;
  String Nmin = '';
  var Lmin = LatLng(0.0, 0.0);
  var switch1 = false;

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high, //正確性:highはAndroid(0-100m),iOS(10m)
    distanceFilter: 100,
  );

  //ボタンのON/OFFを記憶
  saveBool(String key, bool value) async {
    print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% saveBool()");
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }
  restoreValues() async {
    print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% restoreValues()");
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      switch1 = prefs.getBool('bool1') ?? false;
    });
  }

  @override
  void initState() {
    print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% initState()");
    super.initState();
    restoreValues();
    loading = true;
    return;
  }

  //現在地を取得する
  Future<void> getUserLocation() async {
    print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% _getUserLoacation()");
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print('初期現在地 $position');
    setState(() {
      initialPosition = LatLng(position.latitude, position.longitude);
      loading = false;
      restriction1 = LatLng(initialPosition.latitude + 0.0090133729745762,
          initialPosition.longitude + 0.010966404715491394);
      restriction2 = LatLng(initialPosition.latitude - 0.0090133729745762,
          initialPosition.longitude - 0.010966404715491394);
    });
  }

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
                    //PrivacyPolicy（アプリの使い方）
                    title: Text("アプリの使い方"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppUsage(),
                        ),
                      );
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
                  ListTile(
                    title: Text("プライバシーポリシー"),
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrivacyPolicy(),
                        ),
                      );
                    },
                  ),
                  ExpansionTile(
                    title: Row(
                        children:[
                          Icon(Icons.settings_applications),
                          Text(" 最短ルート検索の設定"),
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
                          value: switch1,
                          onChanged: (bool value) {
                            setState(() {
                              switch1 = value;
                              saveBool('bool1', value);
                              print("switch1");
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
        future: makeGoogleMap(),
        builder: (context, snapshot) {
          print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FutureBuilder");
          documentList.forEach((elem) {
            Llatitude.add(elem.get('Llatitude'));
            Llongitude.add(elem.get('Llongitude'));
            classification.add(elem.get('classification'));
            name.add(elem.get('name'));
            phone.add(elem.get('phone'));
            parking.add(elem.get('parking'));
            toilets.add(elem.get('toilets'));
            other.add(elem.get('other'));
            address.add(elem.get('address'));
          });
          DLR.forEach((elem) {
            N.add(elem.get('name'));
            I.add(elem.get('Llatitude'));
            K.add(elem.get('Llongitude'));
            B.add(elem.get('classification'));
          });
          //現在地ローディング
          if (loading) {
            return Center(
                child: CircularProgressIndicator()
            );
          }
          return gm;
        },
      ),
      bottomNavigationBar: SizedBox(
        height: 54,
        child: BottomAppBar(
            color: Colors.orange,
            child: Column(
              children: [
                Row(children: [
                  //目的地
                  Container(
                      margin: EdgeInsets.only(left: 5, top: 3),
                      child: SizedBox(
                        width: 280,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: null,
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                          ),
                          child: Text(destination,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                        ),
                      )),
                  //距離
                  Container(
                    margin: EdgeInsets.only(left: 5, top: 3),
                    child: SizedBox(
                      width: 63,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: null,
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Colors.white),
                        ),
                        child: Text(
                          totalDistance,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black38,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ]),
              ],
            )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8),
            child: SizedBox(
              width: 170,
              height: 18,
              child: FloatingActionButton.extended(
                tooltip: 'Action!',
                label: Text('周辺のトイレ $Markercount 件',
                    style: TextStyle(
                        color: Colors.black38,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                backgroundColor: Colors.white,
                onPressed: null,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 5),
            child: SizedBox(
              width: 170,
              height: 55,
              child: FloatingActionButton.extended(
                tooltip: 'Action!',
                label: Text('最短ルート探索',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                backgroundColor: Colors.orange,
                onPressed: () async {
                  Position position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high);
                  if (points == null) {
                  } else {
                    points.clear();
                    route.routes.clear();
                  }
                  print(
                      'distanceInMeters============================================');
                  for (int count = 0; DLR.length > count; count++) {
                    //攻守トイレを含まず検索の場合スキップする
                    print(switch1);
                    print(B[count]);
                    if ((switch1 == false) && (B[count] == '公衆トイレ')) {
                      print('公衆トイレなので×');
                      continue;
                    }
                    print(N[count]);
                    print(I[count]);
                    print(K[count]);
                    print(B[count]);
                    //distanceInMeters 2点間の距離を測る
                    double distanceInMeters = Geolocator.distanceBetween(
                      position.latitude,
                      position.longitude,
                      I[count],
                      K[count],
                    );
                    print('距離 $distanceInMeters');
                    if (min > distanceInMeters) {
                      Nmin = N[count];
                      min = distanceInMeters;
                      Lmin = LatLng(I[count], K[count]);
                    } else {}
                  }
                  print('min $Nmin');
                  print('min $min');
                  print('min $Lmin');
                  print(
                      'distanceInMeters============================================');
                  destination = Nmin;
                  points.addAll([
                    LatLng(
                        initialPosition.latitude, initialPosition.longitude),
                    LatLng(Lmin.latitude, Lmin.longitude),
                  ]);
                  await route.drawRoute(points, 'Test routes',
                      Color.fromRGBO(0, 191, 255, 1.0), googleApiKey,
                      travelMode: TravelModes.walking);
                  setState(() {
                    totalDistance = distanceCalculator
                        .calculateRouteDistance(points, decimals: 1);
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
                label: Text('ルート解除',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
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

  Future<void> getFirestore() async {
    print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% initialize1()");
    if (documentList.length == 0) {
      final snapshot = await FirebaseFirestore.instance.collection('toire').get();
      documentList = snapshot.docs;
      documentList.forEach((elem) {
        print(elem.get('Llatitude'));
        print(elem.get('Llongitude'));
        print(elem.get('classification'));
        print(elem.get('name'));
        print(elem.get('phone'));
        print(elem.get('parking'));
        print(elem.get('toilets'));
        print(elem.get('other'));
        print(elem.get('address'));
      });
      print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% initialize1().access");
    }

  }

  Future<void> makeGoogleMap() async {
    print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% initialize2()");
    await getFirestore();
    await checkPermission();
    await getUserLocation();

    line = Divider(
      color: Colors.black54,
      thickness: 1,
      height: 4,
      indent: 10,
      endIndent: 10,
    );

    //documentListから範囲制限をかけて取得
    if (DLR.length == 0){
      DLR = documentList.where((documents) {
        if ((documents['Llatitude'] < restriction1.latitude &&
            documents['Llatitude'] > restriction2.latitude) &&
            (documents['Llongitude'] < restriction1.longitude &&
                documents['Llongitude'] > restriction2.longitude)) {
          return true;
        } else {
          return false;
        }
      }).toList();
      Markercount = DLR.length;
      print('DLR===========================================================DLR');
      print(restriction1);
      print(restriction2);
      print('MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM');
      DLR.forEach((elem) {
        print(elem.get('Llatitude'));
        print(elem.get('Llongitude'));
        print(elem.get('classification'));
        print(elem.get('name'));
        print(elem.get('phone'));
        print(elem.get('parking'));
        print(elem.get('toilets'));
        print(elem.get('other'));
        print(elem.get('address'));
      });
      print('DLR===========================================================DLR');
    }


    //GoogleMap変数
    gm = await GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 16,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
      },
      markers: DLR.map((documents) => Marker(
        markerId: MarkerId(documents['name']),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed),
        position: LatLng(documents['Llatitude'], documents['Llongitude']),
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
                    child: Text(documents['name'],
                        style: TextStyle(
                            color: Colors.white, fontSize: 13)),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      if (points == null) {
                      } else {
                        points.clear();
                        route.routes.clear();
                      }
                      destination = documents['name'];
                      //Geolocator.getCurrentPosition 現在地の座標を取得する
                      Position position =
                      await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.high);
                      points.addAll([
                        LatLng(position.latitude, position.longitude),
                        LatLng(documents['Llatitude'], documents['Llongitude']),
                      ]);
                      print(points);
                      await route.drawRoute(
                          points,
                          'Test routes',
                          Color.fromRGBO(0, 191, 255, 1.0),
                          googleApiKey,
                          travelMode: TravelModes.walking);
                      setState(() {
                        totalDistance = distanceCalculator
                            .calculateRouteDistance(points,
                            decimals: 1);
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
                      Text(documents['address']),
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
                      Text(documents['phone']),
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
                      Text(documents['parking']),
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
                      Text(documents['toilets']),
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
                          padding: EdgeInsets.only(right: 10.0),
                          child: Text(documents['other']),
                        ),
                      ),
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

  Future<void> checkPermission() async {
    print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% initialize3()");
    //現在地の許可
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
      //再描画
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => super.widget));
    }
  }
}
