import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mamanike/service/notification_service.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:mamanike/screens/splash.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );

  await NotificationService.initialize();
  await initializeDateFormatting('id_ID', null).then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      title: 'Mamanike',
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: const Splash(),
      debugShowCheckedModeBanner: false,
    );
  } 
}

