import 'package:flutter/material.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:flutter/services.dart';
import 'package:katering_ibu_m_flutter/screens/client/initial_screen.dart';
import 'package:provider/provider.dart';
import 'provider/cart_provider.dart';
import 'package:katering_ibu_m_flutter/services/local_notification_service.dart';
import 'package:katering_ibu_m_flutter/services/notification_polling_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await LocalNotificationService.initialize();
  await LocalNotificationService.requestPermissions();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          NotificationPollingService().startPolling();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final pollingService = NotificationPollingService();

    switch (state) {
      case AppLifecycleState.resumed:
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            pollingService.startPolling();
          }
        });
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        pollingService.stopPolling();
        break;
      case AppLifecycleState.detached:
        pollingService.dispose();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NotificationPollingService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Katering Ibu',
        color: primaryColor,
        home: InitialScreen(),
      ),
    );
  }
}
