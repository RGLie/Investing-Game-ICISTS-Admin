import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:investing_game_admin/user_detail_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return new StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").orderBy('team').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return new Text("There is no expense");
          var userdoc=snapshot.data.docs;

          var team_count=Map<String, int>();

          userdoc.forEach((users) {
            if(team_count.containsKey(users.get('team'))){
              team_count[users.get('team')]+=1;
            }
            else{
              team_count[users.get('team')]=1;
            }
          });

          
          return ListView(children: List.from(_listBuilder(team_count))..addAll(getExpenseItems(snapshot)));
          // return ListView(children: getExpenseItems(snapshot));
        });
  }

  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs
        .map((doc) => InkWell(
          child: new ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return UserDetailPage( doc.get('uid')!=null?doc.get('uid'):'5AJUsH5LYaQcBiTtO5MA7d6OKx72');
              }));

            },
            title: Text( '${ doc.get('team') } 팀'),
            subtitle: new Text(doc.get('full_name') )
    ),
        )).toList();
  }


  List<Widget> _listBuilder(Map<String, int> team_count) {
    List<Widget> l = [];
    team_count.forEach((k, v) => l.add(ListTile(
      title: Text('${k} 팀 : ${v.toString()} 명', style: TextStyle(fontWeight: FontWeight.bold),),
    )));
    return l;
  }
}