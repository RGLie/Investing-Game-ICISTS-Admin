import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:investing_game_admin/analyze_page.dart';
import 'package:investing_game_admin/others_page.dart';
import 'package:investing_game_admin/startup_page.dart';
import 'package:investing_game_admin/trade_page.dart';
import 'package:investing_game_admin/trade_state_page.dart';
import 'package:investing_game_admin/user_page.dart';

class HomePage extends StatefulWidget {
  final User user;
  HomePage(this.user);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference _tradeStream = FirebaseFirestore.instance.collection('trade_state');
  List title=[
    'Trade State',
    'Users',
    'Trades',
    'Startup',
    'Analyze',
    'Others'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ADMIN'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
        height:1000,
        child: ListView.separated(
            itemBuilder: (BuildContext context, int index){
              return InkWell(
                onTap: () {

                  if(index==0){
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return TradeStatePage();
                    }));
                  }
                  if(index==1){
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return UserPage();
                    }));
                  }
                  if(index==2){
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return TradePage();
                    }));
                  }
                  if(index==3){
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return StartupPage();
                    }));
                  }
                  if(index==4){
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return AnalyzePage();
                    }));
                  }
                  if(index==5){
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return OthersPage();
                    }));
                  }
                },
                child: Container(
                    height: 60,
                    child: Center(child: Text('${title[index]}'))
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) => const Divider(),
            itemCount: 6
        )
    );
  }

}