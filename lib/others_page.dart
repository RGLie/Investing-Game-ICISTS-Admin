import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OthersPage extends StatefulWidget {
  const OthersPage({Key key}) : super(key: key);

  @override
  _OthersPageState createState() => _OthersPageState();
}

class _OthersPageState extends State<OthersPage> {
  CollectionReference _userStream = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Others'),
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return Column(
      children: [
        Center(
          child: Text('유저 데이터 삭제하기', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        ),
        Padding(padding: EdgeInsets.all(5)),
        OutlinedButton(
              onPressed: () async{
                //trade의 문서 전부 지우기
                //문서 지우면서 유저 데이터의 isTrade 값을 전부 false로 바꾸여야함

                var collection = FirebaseFirestore.instance.collection('users');
                var snapshots = await collection.get();
                for (var doc in snapshots.docs) {
                  if(doc.get('uid')!='5AJUsH5LYaQcBiTtO5MA7d6OKx72'&&
                      doc.get('uid')!='Cpd34F5mU8fY0BFOFukXgE0rZ8j1'&&
                      doc.get('uid')!='Fe7JkTm0OGM9wh2BVlD9X3x65Ji2'&&
                      doc.get('uid')!='e6LZe8MhbNOxgddT93CPUNxCGyr2'&&
                      doc.get('uid')!='PDV012YM6ThmInwxMVANdHaPwIA3'){
                    await doc.reference.delete();
                  }
                }
              },
              child: Text('삭제하기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                ),
              ),
            )
      ],
    );
  }
}
