import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class TradeManagePage extends StatefulWidget {
  int num;
  TradeManagePage(this.num);

  @override
  _TradeManagePageState createState() => _TradeManagePageState();
}

class _TradeManagePageState extends State<TradeManagePage> {
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
        title: Text('${title[widget.num-1]}'),
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('trade_${widget.num}').snapshots(),
      builder: (context, snp) {
        if (!snp.hasData) return new Text("There is no expense");
        var tradedoc=snp.data.docs;
        List<dynamic> buy_trade = [];
        List<dynamic> sell_trade = [];
        int trade_price=0;
        var user_have_amount={};
        var user_have_money={};


        tradedoc.forEach((trades) {

          if(trades.get('type')==1){
            for(int i=0;i<trades.get('stock');i++){
              Map<String, dynamic> trd = {
                'price':trades.get('price'),
                'uid':trades.get('uid'),

              };
              buy_trade.add(trd);
            }
            user_have_amount[trades.get('uid')]=trades.get('have_amount');
            user_have_money[trades.get('uid')]=trades.get('have_money');
          }
          else{
            for(int i=0;i<trades.get('stock');i++){
              Map<String, dynamic> trd = {
                'price':trades.get('price'),
                'uid':trades.get('uid')
              };
              sell_trade.add(trd);
            }
            user_have_amount[trades.get('uid')]=trades.get('have_amount');
            user_have_money[trades.get('uid')]=trades.get('have_money');
          }
        });
        var buys=Map<int, dynamic>();
        var sells=Map<int, dynamic>();
        for(var i=0; i<buy_trade.length; i++){
          if(buys.containsKey(buy_trade[i]['price'])){
            buys[buy_trade[i]['price']].add(i);
          }
          else{
            buys[buy_trade[i]['price']]=[i];
          }
        }
        for(var i=0; i<sell_trade.length; i++){
          if(sells.containsKey(sell_trade[i]['price'])){
            sells[sell_trade[i]['price']].add(i);
          }
          else{
            sells[sell_trade[i]['price']]=[i];
          }
        }
        List<int> sell_price_list=[];
        List<int> buy_price_list=[];
        buys.forEach((key, value) {
          buy_price_list.add(key);
        });
        sells.forEach((key, value) {
          sell_price_list.add(key);
        });
        sell_price_list.sort();
        buy_price_list.sort();
        buy_price_list=buy_price_list..sort((a, b) => b - a);

        List<dynamic> buy_trade_order = [];
        List<dynamic> sell_trade_order = [];

        for(var i=0; i<buy_price_list.length;i++){
          for(var j=0; j<buys[buy_price_list[i]].length; j++){
            buy_trade_order.add(buy_trade[buys[buy_price_list[i]][j]]);
          }
        }
        for(var i=0; i<sell_price_list.length;i++){
          for(var j=0; j<sells[sell_price_list[i]].length; j++){
            sell_trade_order.add(sell_trade[sells[sell_price_list[i]][j]]);
          }
        }
        print(sell_trade_order);

        for(var i=1;i<min(buy_trade_order.length, sell_trade_order.length);i++){

          if(buy_trade_order[i]['price']<sell_trade_order[i]['price']){

            trade_price=buy_trade_order[i-1]['price'];
            break;
          }
          if(i==(min(buy_trade_order.length, sell_trade_order.length)-1)){
            trade_price=((buy_trade_order[i]['price']+sell_trade_order[i]['price'])/2).round();
          }
        }


        CollectionReference _tradeStream = FirebaseFirestore.instance.collection('startup_${(widget.num).toString()}');

        return Column(
          children: [
            Padding(padding: EdgeInsets.all(10)),
            Center(
              child: Text('?????? ????????? : ${trade_price.toString()}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            ),
            Padding(padding: EdgeInsets.all(5)),
            StreamBuilder<DocumentSnapshot>(
              stream: _tradeStream.doc('price').snapshots(),
              builder: (ctx, snapshot){
                if(snapshot.hasError){
                  return Text('ERROR');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                Map<String, dynamic> price_data = snapshot.data.data();

                return OutlinedButton(
                  onPressed: () async{
                    int check=1;
                    int trade_amount=1;
                    //buy trade??? sell trade ??? ????????? ?????? ?????? ????????? ??????
                    if (min(buy_trade_order.length, sell_trade_order.length)==0) {
                      //?????? ?????? ?????? ?????? ????????????
                      for(var i=0;i<buy_trade_order.length;i++){
                        CollectionReference users=FirebaseFirestore.instance.collection('users');
                        users.doc(buy_trade_order[i]['uid']).update({
                          'money': FieldValue.increment(buy_trade_order[i]['price']),
                        });
                      }


                      for(var i=0;i<sell_trade_order.length;i++){
                        CollectionReference users=FirebaseFirestore.instance.collection('users');
                        users.doc(sell_trade_order[i]['uid']).update({
                          'startup_${(widget.num).toString()}_stocks': FieldValue.increment(1),
                        });
                      }

                    }

                    else {
                      String seller=sell_trade_order[0]['uid'];
                      String buyer=buy_trade_order[0]['uid'];

                      int buyer_amount=user_have_amount[buyer];
                      int buyer_money=user_have_money[buyer];
                      int seller_amount=user_have_amount[seller];
                      int seller_money=user_have_money[seller];

                      for(var i=1;i<min(buy_trade_order.length, sell_trade_order.length);i++){
                        //??? trade order list??? ?????? length ???????????? for??? ??????
                        check+=1;

                        //case1
                        //?????? ?????? < ?????? ?????? ??? ??????
                        //????????? ???????????????. ??? trade list??? ????????????, ?????????????????? ???????????? ??????????????? ??? ?????? ????????? ????????????
                        if(buy_trade_order[i]['price']<sell_trade_order[i]['price']){
                          //??? ?????? ????????? ??????????????? ??? ???????????? buyer, seller??? ????????? ????????????
                          CollectionReference users=FirebaseFirestore.instance.collection('users');

                          users.doc(buyer).update({
                            'money': FieldValue.increment(trade_amount*buy_trade_order[i]['price']-trade_amount*trade_price),
                            'startup_${(widget.num).toString()}_stocks': FieldValue.increment(trade_amount),
                          });
                          users.doc(seller).update({
                            'money' : FieldValue.increment(trade_amount*trade_price),
                          });
                          break;

                        }


                        //case2
                        //for??? ???????????? ???
                        //????????? ????????? ?????????. ?????? ??? ?????? ????????? ????????????? -> ??????
                        if(i==min(buy_trade_order.length, sell_trade_order.length)-1){
                          CollectionReference users=FirebaseFirestore.instance.collection('users');
                          trade_amount+=1;

                          users.doc(buyer).update({
                            'money': FieldValue.increment(trade_amount*buy_trade_order[i]['price']-trade_amount*trade_price),
                            'startup_${(widget.num).toString()}_stocks': FieldValue.increment(trade_amount),
                          });

                          users.doc(seller).update({
                            'money' : FieldValue.increment(trade_amount*trade_price),
                          });
                          print('-${trade_amount.toString()}??? - ?????? ${buyer}, ?????? ${seller}');
                          break;
                        }

                        //case3
                        //seller, buyer??? i-1?????? ???????????? ??????.
                        //?????? ???????????? ???????????? ?????? ????????????.
                        if((seller==sell_trade_order[i]['uid'])&&(buyer==buy_trade_order[i]['uid'])){
                          trade_amount+=1;
                          continue;
                        }


                        //case4
                        //?????? seller ????????? i????????? ?????????, ?????? buyer ????????? i????????? ?????????
                        //????????? ????????? ???????????? ?????? ????????? ????????????.
                        //??? ??? seller ??? buyer ????????? ????????????
                        if(seller!=sell_trade_order[i]['uid']||buyer!=buy_trade_order[i]['uid']){
                          CollectionReference users=FirebaseFirestore.instance.collection('users');
                          users.doc(buyer).update({
                            'money': FieldValue.increment(trade_amount*buy_trade_order[i]['price']-trade_amount*trade_price),
                            'startup_${(widget.num).toString()}_stocks': FieldValue.increment(trade_amount),
                          });

                          users.doc(seller).update({
                            'money' : FieldValue.increment(trade_amount*trade_price),
                          });

                          //print('${trade_amount.toString()}??? - ?????? ${buyer}, ?????? ${seller}');


                          trade_amount=1;
                          seller=sell_trade_order[i]['uid'];
                          buyer=buy_trade_order[i]['uid'];

                          buyer_amount=user_have_amount[buyer];
                          buyer_money=user_have_money[buyer];
                          seller_amount=user_have_amount[seller];
                          seller_money=user_have_money[seller];
                        }
                      }


                      //?????? check ???????????? ?????? for ??? ??????
                      //????????? ????????? ??? ?????? ?????? ???????????? ???????????? ??????
                      //buyer??? ?????? ????????? ??? ????????? ?????? ?????????.
                      //seller??? ?????? ????????? ??? ??????????????? ?????? ?????????.

                      //????????? check?????? ?????? buyer trade ??????
                      for(var i=check;i<buy_trade_order.length;i++){
                        CollectionReference users=FirebaseFirestore.instance.collection('users');
                        users.doc(buy_trade_order[i]['uid']).update({
                          'money': FieldValue.increment(buy_trade_order[i]['price']),
                        });
                      }

                      //????????? check?????? ?????? sell trade order ??????
                      for(var i=check;i<sell_trade_order.length;i++){
                        CollectionReference users=FirebaseFirestore.instance.collection('users');
                        users.doc(sell_trade_order[i]['uid']).update({
                          'startup_${(widget.num).toString()}_stocks': FieldValue.increment(1),
                        });
                      }

                    //?????? ????????? ??? ????????? ????????? ?????? ??????
                    //price??? startup price ??? ?????? ???????????? ???????????? ?????? ??????
                    int nprice=0;
                    nprice=price_data['price_now'];
                    _tradeStream.doc('price').update({
                      'price_now':trade_price,
                      'price_past':nprice
                    });
                    CollectionReference _priceStream = FirebaseFirestore.instance.collection('price');
                    _priceStream.doc('price').update({
                      '${(widget.num).toString()}': trade_price
                    });


                    }




                    //trade??? ?????? ?????? ?????????
                    //?????? ???????????? ?????? ???????????? isTrade ?????? ?????? false??? ???????????????

                    var collection = FirebaseFirestore.instance.collection('trade_${(widget.num).toString()}');
                    var snapshots = await collection.get();
                    for (var doc in snapshots.docs) {
                      if(doc.get('uid')!='5AJUsH5LYaQcBiTtO5MA7d6OKx72'){

                        CollectionReference users=FirebaseFirestore.instance.collection('users');
                        users.doc(doc.get('uid')).update({
                          '${(widget.num).toString()}_isTrade':false
                        });
                        await doc.reference.delete();
                      }
                    }

                    print('Finish');

                  },
                  child: Text('?????? ????????????', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    ),
                  ),
                );
              },
            ),

            Flexible(
              child: ListView(
                children: getExpenseItems(snp),
              )
            ),
          ],
        );
      }
    );
  }
  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs
        .map((doc) => new ListTile(
            title: doc.get('type')==1?
            Text( '${ doc.get('stock').toString() } ???',style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),)
                : Text( '${ doc.get('stock').toString() } ???',style: TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold),),
            subtitle: new Text('${ doc.get('price') } ???' )
        )).toList();
  }
}
