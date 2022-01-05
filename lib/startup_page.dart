import 'package:flutter/material.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({Key key}) : super(key: key);

  @override
  _StartupPageState createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup'),
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