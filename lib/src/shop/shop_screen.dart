import 'package:blink/src/user/user_service.dart';
import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget {
  static const routeName = '/shopscreen';

  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  Future<void> buySimpleScreamer(BuildContext context) async {
    final user = UserService().user;
    if (user == null) return;

    if (await UserService().canBuySimpleFlash()) {
      await UserService().decreaseBalance(10);
      await UserService().addSimpleFlash();
    } else {
      const snackBar = SnackBar(
        content: Text('You can not buy simple flash. Check you balance.'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> buyProScreamer(BuildContext context) async {
    final user = UserService().user;
    if (user == null) return;

    if (await UserService().canBuyProFlash()) {
      await UserService().decreaseBalance(100);
      await UserService().addProFlash();
    } else {
      const snackBar = SnackBar(
        content: Text('You can not buy pro flash. Check you balance.'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
      ),
      body: ListView(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  height: 250,
                  child: Image.asset('assets/images/red_star.png'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () async {
                    await buySimpleScreamer(context);
                  },
                  child: const Text('Buy Simple Flash for 10 BLK'),
                ),
              )
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  height: 250,
                  child: Image.asset('assets/images/screamer.jpeg'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () async {
                    await buyProScreamer(context);
                  },
                  child: const Text('Buy Pro Flash for 100 BLK'),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
