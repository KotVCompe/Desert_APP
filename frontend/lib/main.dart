import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/tolitiki_screen.dart';
import 'services/cart_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartService(),
      child: MaterialApp(
        title: 'Tolitiki App',
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
        home: const TolitikiScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
