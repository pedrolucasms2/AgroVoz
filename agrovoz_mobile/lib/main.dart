import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/session_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SessionProvider(),
      child: MaterialApp(
        title: 'AgroVoz Mobile',
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: Color(0xFF128C7E),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF128C7E),
            foregroundColor: Colors.white,
          ),
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
