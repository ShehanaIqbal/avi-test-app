import 'dart:async';
import 'dart:convert';
import 'package:avi_test_app/pages/image_picker.dart';
import 'package:avi_test_app/pages/logger.dart';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'image_picker.dart';
import 'package:avi_test_app/database/database.dart';
import 'package:avi_test_app/database/user.dart';

var db = new DatabaseHelper();

class NewResetpass extends StatefulWidget {
  @override
  _ResetpassState createState() => _ResetpassState();
}

class _ResetpassState extends State<NewResetpass> {
  TextEditingController pass1 = new TextEditingController();
  TextEditingController pass2 = new TextEditingController();
  TextEditingController username = new TextEditingController();
  TextEditingController cpass = new TextEditingController();

  String msg = '';

  Future<Map<String, dynamic>> _reset() async {
    final resetrequest = http.MultipartRequest(
        'POST', Uri.parse("http://192.168.43.132/flutterdemoapi/newreset.php"));

    resetrequest.fields['password1'] = pass1.text.toString();
    resetrequest.fields['password2'] = pass2.text.toString();
    resetrequest.fields['username'] = username.text.toString();
    resetrequest.fields['password'] = cpass.text.toString();

    try {
      final streamedResponse = await resetrequest.send();

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> responseData = json.decode(response.body);

      return responseData;
    } catch (e) {
      return null;
    }
  }

  void _resetstart() async {
    final Map<String, dynamic> datauser = await _reset();

    if (datauser == null) {
      Toast.show("Reset details upload Failed!!!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      msg = 'Reset details upload Failed!!!';
    } else if (datauser.containsKey("error")) {
      Toast.show(datauser['error'], context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      msg = datauser['error'];
    } else {
      msg = datauser['response'];
      Toast.show(datauser['response'], context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Logger()),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reset Password"),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                "Username",
                style: TextStyle(fontSize: 18.0),
              ),
              TextField(
                controller: username,
                obscureText: false,
                decoration: InputDecoration(hintText: 'Username'),
              ),
              Text(
                "Current Password",
                style: TextStyle(fontSize: 18.0),
              ),
              TextField(
                controller: cpass,
                obscureText: true,
                decoration: InputDecoration(hintText: 'Current Password'),
              ),
              Text(
                "New Password",
                style: TextStyle(fontSize: 18.0),
              ),
              TextField(
                controller: pass1,
                obscureText: true,
                decoration: InputDecoration(hintText: 'New Password'),
              ),
              Text(
                "Re-enter Password",
                style: TextStyle(fontSize: 18.0),
              ),
              TextField(
                controller: pass2,
                obscureText: true,
                decoration: InputDecoration(hintText: 'Re-enter Password'),
              ),
              RaisedButton(
                child: Text("Reset"),
                onPressed: () {
                  _resetstart();
                },
              ),
              Text(
                msg,
                style: TextStyle(fontSize: 20.0, color: Colors.red),
              )
            ],
          ),
        ),
      ),
    );
  }
}
