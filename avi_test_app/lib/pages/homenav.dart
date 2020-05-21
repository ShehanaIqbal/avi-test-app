import 'package:avi_test_app/database/database.dart';
import 'package:avi_test_app/pages/image_picker.dart';
import 'package:avi_test_app/pages/logger.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/utils/utils.dart';

var db = new DatabaseHelper();

class Homenav extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Homenav();
  }
}

class _Homenav extends State<Homenav> {
  int data1;
  navigatelogger() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Logger()),
    );
  }

  navigateimage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ImageInput()),
    );
  }

  checkValue() async {
    final data = await db.checkuser();
    print(data == 1 ? "yes" : "no");
    if (data == 0) {
      data1 = 0;
    }
    if (data == 1) {
      data1 = 1;
    }
    print(data1);
    return data1;
  }

  @override
  Widget build(BuildContext context) {
    int data1;
    return new FutureBuilder(
        future: checkValue(),
        builder: (BuildContext context, AsyncSnapshot response) {
          if (response.data == 1) {
            data1 = 1;
            print('user logged');
            navigateimage();
          }
          if (response.data == 0) {
            data1 = 1;
            print('no user');
            navigatelogger();
          }
          //response.data==0? new Logger(): new Scaffold();
          return Scaffold();
        });
  }
}
