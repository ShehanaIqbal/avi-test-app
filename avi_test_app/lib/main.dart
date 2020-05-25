import 'package:avi_test_app/database/database.dart';
import 'package:avi_test_app/pages/homenav.dart';
import 'package:avi_test_app/pages/image_picker.dart';

import './pages/splashScreen.dart';
import 'package:flutter/material.dart';

import 'pages/logger.dart';
import 'widgets/drawer.dart';



void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  
  

 //String username = db.getUser() as String;

  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
     
    WidgetsFlutterBinding.ensureInitialized();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue
      ),
     
      home: new SplashScreen(),
    
    routes: <String, WidgetBuilder>{
      '/imagePicker': (BuildContext context) => new Logger()
    },
   
   
    );
  }
}