class User {
  int id;
  String username;
  String userid;
  String branchid;


  User(this.username, this.userid, this.branchid);

  User.map(dynamic obj) {
    this.username = obj["username"];
    this.userid= obj["userid"];
    this.branchid= obj["branchid"];
   
  }

  String get userName => username;
  String get userId => userid;
  String get branchId => branchid;


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["username"] = username;
    map["userid"] = userid;
    map["branchid"] = branchid;
    
    return map;
  }

  void setUserId(int id) {
    this.id = id;
  }
}
