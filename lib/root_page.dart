
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:investing_game_admin/home_page.dart';
import 'package:investing_game_admin/login_page.dart';



class RootPage extends StatelessWidget {
  const RootPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){

          if(!snapshot.hasData){
            return LoginPage();
          }
          return HomePage(snapshot.data);

        }
    );
  }
}
