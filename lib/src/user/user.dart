class User {
  String? name;
  String? email;
  String? photoUrl;
  int? highestTime;
  double? balance;
  int? wins;
  int? defeats;

  User({
    this.name,
    this.email,
    this.photoUrl,
    this.highestTime,
    this.balance,
    this.wins,
    this.defeats,
  });

  User.empty()
      : name = '',
        email = '',
        photoUrl = '',
        highestTime = 0,
        balance = 0,
        wins = 0,
        defeats = 0;

  void setDataFromFireStore(Map<String, dynamic> data) {
    balance = data['balance'];
    wins = data['wins'];
    defeats = data['defeats'];
    highestTime = data['highest_time'];
  }

  Map<String, dynamic> getDataToFireStore() {
    return {
      'balance': balance,
      'highest_time': highestTime,
      'defeats': defeats,
      'wins': wins,
    };
  }
}
