class User {
  String? name;
  String? email;
  String? photoUrl;
  int? highestTime;
  double? balance;
  double? won;
  double? lost;

  User({
    this.name,
    this.email,
    this.photoUrl,
    this.highestTime,
    this.balance,
    this.won,
    this.lost,
  });

  User.empty()
      : name = '',
        email = '',
        photoUrl = '',
        highestTime = 0,
        balance = 0,
        won = 0,
        lost = 0;

  void setDataFromFireStore(Map<String, dynamic> data) {
    balance = data['balance'];
    won = data['won'];
    lost = data['lost'];
    highestTime = data['highest_time'];
  }

  Map<String, dynamic> getDataToFireStore() {
    return {
      'balance': balance,
      'highest_time': highestTime,
      'lost': lost,
      'won': won,
    };
  }
}
