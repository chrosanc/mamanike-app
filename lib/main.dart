import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mamanike/service/notification_service.dart';
import 'package:mamanike/theme.dart';
import 'package:mamanike/viewmodel/auth/login_viewmodel.dart';
import 'package:mamanike/viewmodel/auth/otp_viewmodel.dart';
import 'package:mamanike/viewmodel/auth/phone_verification_viewmodel.dart';
import 'package:mamanike/viewmodel/auth/register_viewmodel.dart';
import 'package:mamanike/viewmodel/main/category/category_viewmodel.dart';
import 'package:mamanike/viewmodel/main/category/product_viewmodel.dart';
import 'package:mamanike/viewmodel/main/main_container_viewmodel.dart';
import 'package:mamanike/viewmodel/main/order/order_viewmodel.dart';
import 'package:provider/provider.dart';
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
  await initializeDateFormatting('id_ID', null).then((_) => runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => ProductViewModel()),
      ChangeNotifierProvider(create: (_) => OrderViewModel()),
      ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ChangeNotifierProvider(create: (_) => OtpViewModel()),
      ChangeNotifierProvider(create: (_) => PhoneVerificationViewModel()),
      ChangeNotifierProvider(create: (_) => RegisterViewModel()),
      ChangeNotifierProvider(create: (_) => MainContainerViewmodel()),
      ChangeNotifierProvider(create: (_) => CategoryViewModel()),
    ],
      child: MyApp(),
    ),

  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mamanike',
      theme: appTheme,
      home: const Splash(),
      debugShowCheckedModeBanner: false,
    );
  } 
}

