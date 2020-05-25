import 'dart:async';
import 'dart:io' as io;

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'history.dart';
import 'user.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper _instance = new DatabaseHelper._privateConstructor();
  factory DatabaseHelper() => _instance;
  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  //DatabaseHelper.internal();

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "main2.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    if (oldVersion < newVersion) {
      db.execute("ALTER TABLE History ALTER COLUMN isBlacklisted TEXT;");
    }
  }

  void _onCreate(Database db, int version) async {
    print("database created");
    await db.execute("DROP TABLE IF EXISTS History");
    await db.execute(
        "CREATE TABLE History(id INTEGER PRIMARY KEY, vehiclenumber TEXT , datetime TEXT , latitude TEXT, longitude TEXT, isBlacklisted TEXT )");
    await db.execute(
        "CREATE TABLE User(id INTEGER PRIMARY KEY, username TEXT NOT NULL, userid, branchid TEXT NOT NULL)");
  }

  Future<int> saveHistory(History history) async {
    var dbClient = await db;
    int res = await dbClient.insert("History", history.toMap());
    return res;
  }

  Future<List<History>> getHistory() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM History');
    List<History> latesthistory = new List();
    for (int i = 0; i < list.length; i++) {
      var history = new History(list[i]["vehiclenumber"], list[i]["datetime"],
          list[i]["latitude"], list[i]["longitude"], list[i]["isBlacklisted"]);
      history.setHistoryId(list[i]["id"]);
      latesthistory.add(history);
    }
    print(latesthistory.length);
    return latesthistory;
  }

  Future<int> deleteHistory(History history) async {
    var dbClient = await db;

    int res = await dbClient
        .rawDelete('DELETE FROM History WHERE id = ?', [history.id]);
    return res;
  }

  Future<bool> updatehistory(History history) async {
    var dbClient = await db;
    int res = await dbClient.update("History", history.toMap(),
        where: "id = ?", whereArgs: <int>[history.id]);
    return res > 0 ? true : false;
  }

  Future<int> saveUser(User user) async {
    var dbClient = await db;
    int res = await dbClient.insert("User", user.toMap());
    return res;
  }

  Future<User> getUser() async {
    var dbClient = await db;

    List<Map> list = await dbClient.rawQuery('SELECT * FROM User');
    List<User> latestuser = new List();
    //for (int i = 0; i < list.length; i++) {
    User user =
        new User(list[0]["username"], list[0]["userid"], list[0]["branchid"]);
    user.setUserId(list[0]["id"]);
    latestuser.add(user);
    return user;
    //String luser = list[0]["username"];
    //return luser;

    //latestuser.add(user);
    //}
    //print(latestuser.length);
  }
  Future<int> checkuser() async{
    Database dbClient = await _instance.db;
    List<Map> checklist = await dbClient.rawQuery('SELECT COUNT(username) FROM User') ;
    int checker = checklist[0]['COUNT(username)'];
    //print(checker);
    return checker;
    //return Future.delayed(Duration(seconds: 2), ()=>checker);
  }

  Future<int> deleteUser() async {
    var dbClient = await db;

    int res = await dbClient.rawDelete('DELETE FROM User');
    return res;
  }

  Future<bool> updateuser(User user) async {
    var dbClient = await db;
    int res = await dbClient.update("User", user.toMap(),
        where: "id = ?", whereArgs: <int>[user.id]);
    return res > 0 ? true : false;
  }
}
