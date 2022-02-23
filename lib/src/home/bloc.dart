import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  double _bidInDollars = 1;

  HomeCubit() : super(HomeState());

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
