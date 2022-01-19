import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnalyzePage extends StatefulWidget {
  const AnalyzePage({Key key}) : super(key: key);

  @override
  _AnalyzePageState createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  CollectionReference prices = FirebaseFirestore.instance.collection('price');

  var userdoc;
  var user_data = Map<String, dynamic>();
  var asset = Map<String, int>();

  var real_doc=Map<String, dynamic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analyze'),
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return new StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").orderBy('money', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return new Text(" ");
          userdoc = snapshot.data.docs;



          return StreamBuilder<DocumentSnapshot>(
              stream: prices.doc('price').snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Text(' ');
                }
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator());
                }
                Map<String, dynamic> price_data = snap.data.data();
                List<dynamic> asset_order = [];
                List<dynamic> asset_order_uid = [];

                int realasset;
                userdoc.forEach((users) {
                  var uidd = users.get('uid');
                  var moneyy = users.get('money');
                  var start1 = users.get('startup_1_stocks');
                  var start2 = users.get('startup_2_stocks');
                  var start3 = users.get('startup_3_stocks');
                  var start4 = users.get('startup_4_stocks');
                  var start5 = users.get('startup_5_stocks');
                  var start6 = users.get('startup_6_stocks');
                  var start7 = users.get('startup_7_stocks');
                  var start8 = users.get('startup_8_stocks');

                  realasset = price_data['1'] * start1 +
                      price_data['2'] * start2 +
                      price_data['3'] * start3 +
                      price_data['4'] * start4 +
                      price_data['5'] * start5 +
                      price_data['6'] * start6 +
                      price_data['7'] * start7 +
                      price_data['8'] * start8 +
                      moneyy;

                  asset[uidd] = realasset;
                  asset_order.add(realasset);
                  asset_order.sort();
                  asset_order = asset_order.reversed.toList();
                  //List<dynamic> asset_list = [];
                  //asset_list.add(realasset);
                  //asset_list.add(users.get('uid'));
                  //asset_order.add(asset_list);
                  user_data[uidd] = {
                    'money': moneyy,
                    '1': start1,
                    '2': start2,
                    '3': start3,
                    '4': start4,
                    '5': start5,
                    '6': start6,
                    '7': start7,
                    '8': start8,
                    'asset': realasset,
                    'nick_name': users.get('nick_name'),
                    'full_name': users.get('full_name'),
                    'team': users.get('team')
                  };





                });

                //print(asset_order_uid);


                user_data.forEach((key, value) {
                  asset_order_uid.add(" ");
                  for (int i = 0; i < asset_order.length; i++) {
                    if (asset_order[i] == value['asset']) {
                      user_data[key]['rank'] = i + 1;
                    }
                  }
                });


                user_data.forEach((key, value) {
                  asset_order_uid[value['rank'] - 1] = key;
                });


                print(user_data);

                print(asset_order_uid);
                return ListView(children: _listBuilder(user_data),);
              }
          );
        }
    );
  }

  List<Widget> _listBuilder(Map<String, dynamic> team_count) {
    List<Widget> l = [];
    team_count.forEach((k,v) => l.add(ListTile(
      title: Text('${v['team']}  ', style: TextStyle(fontWeight: FontWeight.bold),),
      subtitle: Text('${v['asset']}  '),

    )));
    return l;
  }

}