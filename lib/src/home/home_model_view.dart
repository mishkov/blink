import 'package:flutter_bloc/flutter_bloc.dart';

class HomeModelView extends Cubit<HomeState> {
  double _bidInDollars = 1;

  HomeModelView() : super(HomeState());

  set bidInDollars(double bid) {
    if (bid < 0.0) {
      throw Exception('bid can not be negative');
    }
    _bidInDollars = bid;
  }

  double get bidInDollars => _bidInDollars;
}

class HomeState {
  HomeState();
}
