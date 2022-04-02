class BidService {
  int _bidInBlk;
  int _bidTimeInSeconds;

  static final BidService _instance = BidService._internal();

  factory BidService() => _instance;

  BidService._internal()
      : _bidInBlk = 10,
        _bidTimeInSeconds = 20;

  int get bidInBlk => _bidInBlk;

  set bidInBlk(int bid) {
    if (bid.isNegative || bid.isInfinite || bid.isNaN) {
      throw IncorrectBidFormatException(
          'Bid cannot be negative, infinite or NaN');
    }

    _bidInBlk = bid;
  }

  int get bidTimeInSeconds => _bidTimeInSeconds;

  set bidTimeInSeconds(int time) {
    if (time.isNegative || time.isInfinite || time.isNaN) {
      throw IncorrectBidTimeFormatException(
          'Bid time cannot be negative, infinite or NaN');
    }

    _bidTimeInSeconds = time;
  }
}

class IncorrectBidFormatException implements Exception {
  final String message;

  IncorrectBidFormatException(this.message);
}

class IncorrectBidTimeFormatException implements Exception {
  final String message;

  IncorrectBidTimeFormatException(this.message);
}
