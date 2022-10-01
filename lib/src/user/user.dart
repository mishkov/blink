class User {
  String? name;
  String? email;
  String? photoUrl;
  int? highestTime;
  double? balance;
  int? wins;
  int? defeats;
  int? simpleFlashCount;
  int? proFlashCount;

  User({
    this.name,
    this.email,
    this.photoUrl,
    this.highestTime,
    this.balance,
    this.wins,
    this.defeats,
    this.simpleFlashCount,
    this.proFlashCount,
  });

  User.empty()
      : name = '',
        email = '',
        photoUrl = '',
        highestTime = 0,
        balance = 0,
        wins = 0,
        defeats = 0,
        simpleFlashCount = 0,
        proFlashCount = 0;

  void setDataFromFireStore(Map<String, dynamic> data) {
    balance = data['balance'].toDouble();
    wins = data['wins'];
    defeats = data['defeats'];
    highestTime = data['highest_time'];
    simpleFlashCount = data['simpleFlashCount'];
    proFlashCount = data['proFlashCount'];
  }

  Map<String, dynamic> getDataToFireStore() {
    return {
      'balance': balance,
      'highest_time': highestTime,
      'defeats': defeats,
      'wins': wins,
      'simpleFlashCount': simpleFlashCount,
      'ProFlashCount': proFlashCount,
    };
  }
}
