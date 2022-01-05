import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TradeStatePage extends StatefulWidget {
  const TradeStatePage({Key key}) : super(key: key);

  @override
  _TradeStatePageState createState() => _TradeStatePageState();
}

class _TradeStatePageState extends State<TradeStatePage> {
  var _isChecked=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TradeState and Default Setting'),
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    CollectionReference _tradeStream = FirebaseFirestore.instance.collection('trade_state');

    return Column(
      children: [
        StreamBuilder<DocumentSnapshot>(
            stream: _tradeStream.doc('open').snapshots(),
            builder: (context, snapshot){
              Map<String, dynamic> trade_data = snapshot.data?.data()??{'open':false};
              if(snapshot.hasError){
                return Text('ERROR');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              _isChecked=trade_data['open'];
              return Center(
                child: Column(
                  children: [
                    Text('Trade State', style: TextStyle(fontSize: 20),),
                    trade_data['open']?
                    Text('거래가능',
                    style: TextStyle(fontSize: 30, color: Colors.indigoAccent),
                    ):
                    Text('거래불가능',
                      style: TextStyle(fontSize: 30, color: Colors.redAccent),
                    ),
                    Switch(
                        value: _isChecked,
                        activeColor: Colors.greenAccent,
                        onChanged: (value){
                          setState(() {
                            _isChecked=value;
                            _tradeStream.doc('open').update({
                              'open':_isChecked
                            });
                          });
                        }
                    ),


                  ],
                ),
              );
            }
        ),
        Padding(
          padding: EdgeInsets.only(left: 6.0, right: 6, bottom: 4),
          child: Container(
            child: Divider(color: Colors.black, thickness: 1,),
          ),
        ),
        StreamBuilder<DocumentSnapshot>(
            stream: _tradeStream.doc('basic_assets').snapshots(),
            builder: (context, snapshot){
              if(snapshot.hasError){
                return Text('ERROR');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              Map<String, dynamic> basic_data = snapshot.data?.data()??{'money':0, 'stocks':0};
              return Center(
                child: Column(
                  children: [
                    Text('Start Money : ${basic_data['money']}',style: TextStyle(fontSize: 25),),
                    Text('Start Stock : ${basic_data['stocks']}',style: TextStyle(fontSize: 25),),
                  ],
                ),
              );
            }
        )
      ],
    );
  }
}