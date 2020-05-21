class History {
  int id;
  String vehiclenumber;
  String datetime;
  String latitude;
  String longitude;
  String isBlacklisted;

  History(this.vehiclenumber, this.datetime, this.latitude, this.longitude,
      this.isBlacklisted);

  History.map(dynamic obj) {
    this.vehiclenumber = obj["vehiclenumber"];
    this.datetime = obj["datetime"];
    this.latitude = obj["latitude"];
    this.longitude = obj["longitude"];
    this.isBlacklisted = obj["isBlacklisted"];
  }

  String get vehicleNumber => vehiclenumber;
  String get dateTime => datetime;
  String get latiTude => latitude;
  String get longiTude => longitude;
  String get isBlackListed => isBlacklisted;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["vehiclenumber"] = vehiclenumber;
    map["datetime"] = datetime;
    map["latitude"] = latitude;
    map["longitude"] = longitude;
    map["isBlacklisted"] = isBlacklisted;
    return map;
  }

  void setHistoryId(int id) {
    this.id = id;
  }
}
