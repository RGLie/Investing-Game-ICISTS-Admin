import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserDetailPage extends StatefulWidget {
  String uid;
  UserDetailPage(this.uid);

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final List<String> datas = <String>['full_name', 'nick_name', 'team', 'phone_number', 'money', 'startup_1_stocks', 'startup_2_stocks', 'startup_3_stocks','startup_4_stocks','startup_5_stocks','startup_6_stocks','startup_7_stocks','startup_8_stocks'];
  CollectionReference userstream = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Detail'),
      ),
      body:_buildBody(),
    );
  }

 _buildBody() {

    return StreamBuilder(
      stream: userstream.doc(widget.uid).snapshots(),
      builder: (context, snapshot){

        if(snapshot.hasError){
          return Text('ERROR');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        Map<String, dynamic> user_data =snapshot.data.data();


        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView.separated(
            padding: EdgeInsets.only(left: 20, right: 20),
            itemCount: 13,
            separatorBuilder: (BuildContext context, int index) => const Divider(),
            itemBuilder: (BuildContext context, int index){
              return Center(
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(datas[index]),
                      Text(user_data[datas[index]] is int?user_data[datas[index]].toString():user_data[datas[index]])
                    ],
                  ),
                ),
              );
            }
          )
        );
      },
    );
  }
}
