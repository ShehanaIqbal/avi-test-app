import 'dart:async';
import 'dart:convert';
import 'package:avi_test_app/pages/image_picker.dart';
import 'package:avi_test_app/pages/resetpassword.dart';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'image_picker.dart';
import 'package:avi_test_app/database/database.dart';
import 'package:avi_test_app/database/user.dart';

String username;
String userid;
String branchid;
String isReset;
String password;
var db = new DatabaseHelper();

class Logger extends StatefulWidget {
  @override
  _LoggerState createState() => _LoggerState();
}

class _LoggerState extends State<Logger> {
  TextEditingController user = new TextEditingController();
  TextEditingController pass = new TextEditingController();

  String uname = '';
  String msg = '';

  Future<Map<String, dynamic>> _login() async {
    final loginrequest = http.MultipartRequest(
        'POST', Uri.parse("http://192.168.43.132/flutterdemoapi/login.php"));

    loginrequest.fields['username'] = user.text.toString();
    loginrequest.fields['password'] = pass.text.toString();
    password = pass.text.toString();

    try {
      final streamedResponse = await loginrequest.send();

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

  void _logstart() async {
    await db.deleteUser();

    final Map<String, dynamic> datauser = await _login();

    if (datauser == null) {
      Toast.show("Login details upload Failed!!!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      msg = 'Login details upload Failed!!!';
    } else if (datauser.containsKey("error")) {
      Toast.show(datauser['error'], context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      msg = datauser['error'];
    } else {
      branchid = (datauser['branchID']);
      userid = (datauser['userID']);
      username = (datauser['username']);
      isReset = (datauser['isReset']);

      var user = new User(username, userid, branchid);
      await db.saveUser(user);

      msg = datauser['response'];
      Toast.show(datauser['response'], context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

      print(isReset);
      if (isReset == '0') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Resetpass(
                  userid: userid,
                  username: username,
                  branchid: branchid,
                  password: password)),
        );
      }
      if (isReset == '1') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ImageInput(
                    userid: userid,
                    username: username,
                    branchid: branchid,
                  )),
        );
      }
    }
    setState(() {
      uname = datauser['username'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
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
                controller: user,
                decoration: InputDecoration(hintText: 'Username'),
              ),
              Text(
                "Password",
                style: TextStyle(fontSize: 18.0),
              ),
              TextField(
                controller: pass,
                obscureText: true,
                decoration: InputDecoration(hintText: 'Password'),
              ),
              RaisedButton(
                child: Text("Login"),
                onPressed: () {
                  _logstart();
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
