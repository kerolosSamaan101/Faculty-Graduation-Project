import 'package:FCIS_F1/core/utils/routes_manager.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RoutsManager.router,
      initialRoute: RoutsManager.loginScreen,
    );
  }
}
