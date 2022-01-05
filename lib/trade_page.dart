import 'package:flutter/material.dart';
import 'package:investing_game_admin/trade_manage_page.dart';

class TradePage extends StatefulWidget {
  const TradePage({Key key}) : super(key: key);

  @override
  _TradePageState createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  List title=[
    'startup1',
    'startup2',
    'startup3',
    'startup4',
    'startup5',
    'startup6',
    'startup7',
    'startup8',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trade'),
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return Container(
      height: 1000,
      child: ListView.separated(
        itemBuilder: (BuildContext context, int index){
          return InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return TradeManagePage(index+1);
              }));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text('${title[index]}')),
            ),
          );
        },
          separatorBuilder: (BuildContext context, int index) => const Divider(),
          itemCount: 8
      ),
    );
  }
}