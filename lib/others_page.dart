import 'package:flutter/material.dart';

class OthersPage extends StatefulWidget {
  const OthersPage({Key key}) : super(key: key);

  @override
  _OthersPageState createState() => _OthersPageState();
}

class _OthersPageState extends State<OthersPage> {
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
        Text('f')
      ],
    );
  }
}
