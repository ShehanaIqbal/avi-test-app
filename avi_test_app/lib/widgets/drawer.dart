import 'package:flutter/material.dart';
import 'package:avi_test_app/pages/history_page.dart';
import 'package:avi_test_app/pages/logger.dart';

class DrawerUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("usename here"),
            accountEmail: Text(""),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                  ? Colors.blue
                  : Colors.white,
              child: Text(
                "U",
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
          ),
          ListTile(
            title: Text("Login"),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Logger()),
              );
            },
          ),
          ListTile(
            title: Text("Recent History"),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage()),
              );
            },
          ),
          ListTile(
            title: Text("Instructions"),
            trailing: Icon(Icons.info),
          ),
          ListTile(
            title: Text("Reset Password"),
            trailing: Icon(Icons.lock),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
          ),
          ListTile(
            title: Text("Settings"),
            trailing: Icon(Icons.settings),
          ),
          ListTile(
            title: Text("Share"),
            trailing: Icon(Icons.share),
          ),
        ],
      ),
    );
  }
}
