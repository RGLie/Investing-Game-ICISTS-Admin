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
              child: Text('예상 체결가 : ${trade_price.toString()}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
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
                    //buy trade랑 sell trade 중 거래가 아예 없는 경우는 거름
                    if (min(buy_trade_order.length, sell_trade_order.length)==0) {
                      //거래 박은 거를 다시 되돌려줌
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
                        //각 trade order list를 작은 length 기준으로 for문 돌림
                        check+=1;

                        //case1
                        //매수 가격 < 매도 가격 인 경우
                        //거래가 안이루어짐. 각 trade list는 오름차순, 내림차순으로 정렬되어 있기때문에 이 경우 체결이 종료된다
                        if(buy_trade_order[i]['price']<sell_trade_order[i]['price']){
                          //이 경우 체결이 종료되므로 그 전까지의 buyer, seller의 거래를 체결시킴
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
                        //for문 마지막일 때
                        //이때도 체결이 종료됨. 근데 왜 이걸 이렇게 해야하지? -> 보류
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
                          print('-${trade_amount.toString()}주 - 매수 ${buyer}, 매도 ${seller}');
                          break;
                        }

                        //case3
                        //seller, buyer는 i-1번째 거래자의 정보.
                        //이전 거래자와 동일하면 그냥 넘어간다.
                        if((seller==sell_trade_order[i]['uid'])&&(buyer==buy_trade_order[i]['uid'])){
                          trade_amount+=1;
                          continue;
                        }


                        //case4
                        //이전 seller 정보가 i번째와 다를때, 이전 buyer 정보가 i번째와 다를때
                        //거래자 정보가 바뀌므로 이전 거래를 체결시킴.
                        //그 후 seller 와 buyer 정보를 업데이트
                        if(seller!=sell_trade_order[i]['uid']||buyer!=buy_trade_order[i]['uid']){
                          CollectionReference users=FirebaseFirestore.instance.collection('users');
                          users.doc(buyer).update({
                            'money': FieldValue.increment(trade_amount*buy_trade_order[i]['price']-trade_amount*trade_price),
                            'startup_${(widget.num).toString()}_stocks': FieldValue.increment(trade_amount),
                          });

                          users.doc(seller).update({
                            'money' : FieldValue.increment(trade_amount*trade_price),
                          });

                          //print('${trade_amount.toString()}주 - 매수 ${buyer}, 매도 ${seller}');


                          trade_amount=1;
                          seller=sell_trade_order[i]['uid'];
                          buyer=buy_trade_order[i]['uid'];

                          buyer_amount=user_have_amount[buyer];
                          buyer_money=user_have_money[buyer];
                          seller_amount=user_have_amount[seller];
                          seller_money=user_have_money[seller];
                        }
                      }


                      //위의 check 변수부터 다시 for 문 시작
                      //왜냐면 거래가 다 처리 안된 거래들을 취소하기 위해
                      //buyer의 남은 주문은 그 돈만큼 다시 줘야함.
                      //seller의 남은 주문은 그 주식수만큼 다시 줘야함.

                      //이거는 check부터 남은 buyer trade 처리
                      for(var i=check;i<buy_trade_order.length;i++){
                        CollectionReference users=FirebaseFirestore.instance.collection('users');
                        users.doc(buy_trade_order[i]['uid']).update({
                          'money': FieldValue.increment(buy_trade_order[i]['price']),
                        });
                      }

                      //여기는 check부터 남은 sell trade order 처리
                      for(var i=check;i<sell_trade_order.length;i++){
                        CollectionReference users=FirebaseFirestore.instance.collection('users');
                        users.doc(sell_trade_order[i]['uid']).update({
                          'startup_${(widget.num).toString()}_stocks': FieldValue.increment(1),
                        });
                      }

                    //이제 여기서 각 기업의 가격을 변동 시킴
                    //price랑 startup price 두 개의 컬렉션의 데이터를 둘다 바꿈
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




                    //trade의 문서 전부 지우기
                    //문서 지우면서 유저 데이터의 isTrade 값을 전부 false로 바꾸여야함

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
                  child: Text('거래 처리하기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
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
            Text( '${ doc.get('stock').toString() } 주',style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),)
                : Text( '${ doc.get('stock').toString() } 주',style: TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold),),
            subtitle: new Text('${ doc.get('price') } 원' )
        )).toList();
  }
}
