import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:firebase_admob/firebase_admob.dart';



void main() => runApp( MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'お菓子検索',
      home: Scaffold(
        appBar: AppBar(
          title: Text('お菓子検索',
            style: TextStyle(
            color: Colors.black,
          ),),
            backgroundColor:Colors.yellow[100],
        ),
        body: Center(
          child: ChangeForm(),
        ),
      ),
    );
  }
}

class ChangeForm extends StatefulWidget {
  @override
  ChangeFormState createState() => ChangeFormState();
}

class ChangeFormState extends State<ChangeForm> {

  String searchText = '';
  final TextEditingController textEditingController = new TextEditingController();


  void _handleText(String e) {
    setState(() {
      searchText = e;
    });
  }

  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          children: <Widget>[
            TextField(
              enabled: true,
              // 入力数
              maxLength: 20,
              maxLengthEnforced: false,
              style: TextStyle(color: Colors.black),
              obscureText: false,
              maxLines:1 ,
              //パスワード
              onChanged: _handleText,
              controller: textEditingController,
              onSubmitted: submission,
              decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 14),
                hintText: 'キーワード(商品名など)を入力',
                suffixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.only(top: 15, right: 0, bottom: 0, left: 0),
              ),
            ),
          ],
        )
    );
  }
  void submission(String e) {
    //print(_textEditingController.text);
    setState(() {
      searchText = textEditingController.text;
    });
    textEditingController.clear();
    Navigator.push(
      context,
      new MaterialPageRoute<Null>(
        settings: const RouteSettings(name: ""),
        builder: (BuildContext context) => ResultPage(searchText),
      ),
    );
  }
}


class ResultPage extends StatefulWidget {

  String searchText = '';

  ResultPage(String text){
    this.searchText = text;
  }

  @override
  ResultPageState createState() => ResultPageState(searchText);

}


class ResultPageState extends State<ResultPage> {

  String searchText = '';

  ResultPageState(String text){
    this.searchText = text;
  }

  Future<Shop> shop;

  @override
  void initState() {
    super.initState();
    shop = fetchPost(searchText);



//    // インスタンスを初期化
//    FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-1642201121183518~7785683922');
//
//    // バナー広告を表示する
//    myBanner
//      ..load()
//      ..show(
//        // ボトムからのオフセットで表示位置を決定
//        anchorOffset: 0.0,
//        anchorType: AnchorType.bottom,
//      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          title: Text(searchText,
            style: TextStyle(
              color: Colors.black,
            ),),
          backgroundColor:Colors.yellow[100],
        ),
        body: FutureBuilder<Shop>(
            future: shop,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView(
                    children: List.generate(
                        snapshot.data.shopNameList.length, (index) {
                      return Card(
                        child: Column(
                          children: <Widget>[
                            Container(
                                margin: EdgeInsets.only(top: 20.0,
                                    right: 20.0,
                                    bottom: 20.0,
                                    left: 0.0),
                                child: ListTile(
                                    title: Text(
                                      snapshot.data.shopNameList[index] + "\n",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    leading: Image.network(snapshot.data.shopImageUrlList[index]),
                                    subtitle: Text("価格：${snapshot.data
                                        .shopOpenTimeList[index]}円\n\メーカー：${snapshot
                                        .data.shopHolidayList[index]}",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black
                                      ),
                                    ),
                                    onTap: () {
                                      print("onTap called.");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute<Null>(
                                          settings: const RouteSettings(
                                              name: ""),
                                          builder: (BuildContext context) =>
                                              ShopPage(snapshot.data
                                                  .shopUrlList[index]),
                                        ),
                                      );
                                    }
                                )
                            ),
                          ],
                        ),
                      );
                    }
                    )
                );
              }else{
                return Text("一致する情報は見つかりませんでした");
              }
            }
        )
    );
  }
}



class ShopPage extends StatelessWidget {
  String url = '';

  ShopPage(String text){
    this.url = text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(url)),
      body: Center(
        child: WebView(
          initialUrl: url,
        ),
      ),
    );
  }
}




Future<Shop> fetchPost(String searchText) async {


  final response =
  //await http.get('https://api.gnavi.co.jp/RestSearchAPI/v3/?keyid=598148e2b38d22265f7adc855fc00645&hit_per_page=50&freeword=' + searchText);
  await http.get('https://www.sysbird.jp/webapi/?apikey=guest&format=json&keyword=' + searchText + '&max=50');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    return Shop.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class Shop {
  List shopNameList;
  List shopOpenTimeList;
  List shopHolidayList;
  List shopImageUrlList;
  List shopUrlList;

  Shop(this.shopNameList,this.shopOpenTimeList,this.shopHolidayList,this.shopImageUrlList,this.shopUrlList);
  factory Shop.fromJson(dynamic json) {
    var shopNameList2 =[];
    var shopOpenTimeList2 =[];
    var shopHolidayList2 =[];
    var shopImageUrlList2 = [];
    var shopUrlList2 =[];
    //var listCount = json["total_hit_count"];

//    if (listCount > 50){
//      listCount = 50;
//    }

    for(var i=0; i < 50; i++){
      shopNameList2.add(json["item"][i]["name"]);
      shopOpenTimeList2.add(json["item"][i]["price"]);
      shopHolidayList2.add(json["item"][i]["maker"]);
      shopImageUrlList2.add(json["item"][i]["image"]);
      shopUrlList2.add(json["item"][i]["url"]);
    }

//    print(shopNameList2.length);

    return Shop(shopNameList2,shopOpenTimeList2,shopHolidayList2,shopImageUrlList2,shopUrlList2);
  }

}



// 広告ターゲット
//MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
//  keywords: <String>['flutterio', 'beautiful apps'],
//  contentUrl: 'https://flutter.io',
//  birthday: DateTime.now(),
//  childDirected: false,
//  designedForFamilies: false,
//  gender: MobileAdGender.male, // or female, unknown
//  testDevices: <String>[], // Android emulators are considered test devices
//);

//BannerAd myBanner = BannerAd(
//  // テスト用のIDを使用
//  // リリース時にはIDを置き換える必要あり
//  adUnitId: "ca-app-pub-1642201121183518/6472602254",
//  size: AdSize.smartBanner,
//  targetingInfo: targetingInfo,
//  listener: (MobileAdEvent event) {
//    // 広告の読み込みが完了
//    print("BannerAd event is $event");
//  },
//);
