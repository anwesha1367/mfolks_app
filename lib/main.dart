import 'package:flutter/material.dart';
import 'package:mfolks_app/login.dart';
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'login',
    routes:{
      'login':(context)=>loginScreen()
    },

  ));
}


