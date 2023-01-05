import 'package:flutter/material.dart';

class AppUsage extends StatefulWidget {
  @override
  _AppUsageState createState() => _AppUsageState();
}

class _AppUsageState extends State<AppUsage> {
  final _scrollController = ScrollController();

  @override
  final _deco = BoxDecoration(
    border: Border.all(
        color: Colors.black38,
        width: 2
    ),
  );

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("アプリの使い方"),
        ),
        body: Scrollbar(
          thumbVisibility: true,
          controller: _scrollController,
          child:         SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                          child: Container(
                            width: 185,
                            decoration: _deco,
                            child: Image.asset(
                              'images/アプリ画面.jpg',
                              //fit: BoxFit.cover,
                            ),
                          )
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Container(
                            width: 185,
                            decoration: _deco,
                            child: Image.asset(
                              'images/トイレ情報.jpg',
                              //fit: BoxFit.cover,
                            ),
                          )
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('① トイレのマーカー（目標地点）',
                        style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                      Text(
                          '　　タップするとトイレ情報が表示されます。（右画\n'
                          '　　像）「ルート検索」のボタンを押すとその目的地\n'
                          '　　までのルートが表示されます。\n'),
                      Text('② 現在地',
                        style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                      Text(
                          '　　今の自分の現在地です。自分が移動すればアプリ\n'
                          '　　も同時に動きます。\n'),
                      Text('③ 最短ルート検索',
                        style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                      Text(
                          '　　現在地から一番近いトイレを案内します。\n'),
                      Text('④ ルート解除',
                        style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                      Text(
                          '　　ルート検索後、ルートを解除することができるボ\n'
                          '　　タンです。\n'),
                      Text('⑤ 目的地、距離',
                        style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                      Text(
                          '　　ルート検索時に目標地点としているトイレの名前\n'
                          '　　と距離を表示します。\n'),
                      Text('⑥ メニュー一覧',
                        style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                      Text(
                          '　　メニューの内容は下画像の通りです。\n'),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                          child: Container(
                            width: 185,
                            decoration: _deco,
                            child: Image.asset(
                              'images/メニュー1.jpg',
                            ),
                          )
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Container(
                            width: 185,
                            decoration: _deco,
                            child: Image.asset(
                              'images/メニュー2.jpg',
                            ),
                          )
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('アプリの使い方',
                        style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                      Text(
                          '　　この画面です。\n'),
                      Text('アプリ情報修正案',
                        style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                      Text(
                          '　　トイレの情報が間違っている場合に修正案を送信\n'
                          '　　することができます。なるべく早く対応できるよ\n'
                          '　　う善処致します。\n'),
                      Text('アプリの評価',
                        style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                      Text(
                          '　　このアプリに対する評価を送信できます。ご協力\n'
                          '　　して頂ければ幸いです。\n'),
                      Text('最短ルート検索の設定',
                        style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                      Text(
                          '　　③最短ルート検索の設定になります。（右図）最\n'
                          '　　短ルート検索時に「公衆トイレを含んで検索する」\n'
                          '　　or「含まず検索する」を選ぶことができます。デ\n'
                          '　　フォルトでは、含まずに検索するを選んでいます。\n'),
                    ],
                  )
                ],

              )
          )
        )


    );
  }
}