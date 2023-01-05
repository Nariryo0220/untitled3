import 'package:flutter/material.dart';

class PrivacyPolicy extends StatefulWidget {
  @override
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  final _scrollController = ScrollController();

  @override

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("プライバシーポリシー"),
        ),
        body: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController,
            child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('取得する個人情報',
                          style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                        Text('本アプリは、お客様から「お客様の位置情報」「お客様のメールアドレス」を取得します。\n'),
                        Text('個人情報を収集・利用する目的',
                          style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                        Text(
                          '本アプリが個人情報を収集・利用する目的は，以下のとおりです。\n'
                              '1.本アプリの運営・改善のため\n'
                              '2.お客様からのお問い合わせに対応するため\n'
                              '3.青森大学ソフトウェア情報学部ソフトウェア情報学科の卒業研究のため\n'
                              '4.利用規約に違反したユーザーや，不正・不当な目的でサービスを利用しようとするユーザーの特定をし，ご利用をお断りするため\n'
                        ),
                        Text('個人情報の第三者提供',
                          style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                        Text('1.本アプリ運営者は、あらかじめユーザーの同意を得ることなく，第三者に個人情報を提供することはありません。ただし，個人情報保護法その他の法令で認められる場合を除きます。\n'),
                        Text('免責事項',
                          style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                        Text(
                            '1.本アプリに登録されている店舗は各々の店舗に直接足を運び、トイレを使用できることを確かめているわけではありません。そのため、一部の店舗のトイレは使用できない可能性があります。\n'
                            '2.本アプリ運営者は、本アプリの提供の終了、変更、または利用不能、本アプリの利用によるデータの消失または機械の故障もしくは損傷、莫大なデータ使用量、トイレを扱っている店舗とのトラブル、その他本アプリに関してユーザーが被った損害につき、賠償する責任を一切負わないものとします。\n'
                        ),
                        Text('プライバシーポリシーの変更',
                          style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                        Text(
                            '1.本ポリシーの内容は，法令その他本ポリシーに別段の定めのある事項を除いて，ユーザーに通知することなく，変更することができるものとします。\n'
                            '2.本アプリ運営者が別途定める場合を除いて，変更後のプライバシーポリシーは，本アプリに掲載したときから効力を生じるものとします。\n'
                        ),
                        Text('お問い合わせ窓口',
                          style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                        Text(
                            '本ポリシーに関するお問い合わせは，下記の窓口までお願いいたします。\n'
                            'Eメールアドレス: si19048@edu.aomori-u.ac.jp\n'
                        ),
                        Text('以上')


                      ],
                    ),
                  ],

                )
            )
        )


    );
  }
}