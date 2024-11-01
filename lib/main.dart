import 'package:flutter/material.dart';
import 'package:fvp/fvp.dart' as fvp;

import 'home.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  fvp.registerWith();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

