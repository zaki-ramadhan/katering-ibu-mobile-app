import 'package:flutter/material.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:flutter/services.dart';
import 'package:katering_ibu_m_flutter/screens/client/initial_screen.dart';
import 'package:provider/provider.dart';
import 'provider/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Katering Ibu',
        color: primaryColor,
        home: InitialScreen(),
      ),
    );
  }
}
