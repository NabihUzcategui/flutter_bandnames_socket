import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_band_name/services/socket_service.dart';
import 'package:flutter_band_name/pages/home.dart';
import 'pages/status.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ( _ ) => SocketService())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        initialRoute: 'home',
        routes: {
          'home':(_) => HomePage(),
          'status':(_) => StatusPage(),
        },
      ),
    );
  }
}