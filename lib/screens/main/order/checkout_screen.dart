import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/screens/main/main_screen.dart';
import 'package:mamanike/service/database_service.dart';
import 'package:mamanike/service/notification_service.dart';
import 'package:webview_flutter/webview_flutter.dart';


class CheckoutScreen extends StatefulWidget {
  final String url;
  final String invId;

  const CheckoutScreen({Key? key, required this.url, required this.invId}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  WebViewController controller = WebViewController();

    @override
  void initState() {
    super.initState();
    controller = WebViewController();
    _setupWebView();
  }

  void _setupWebView() async {
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            if (url.contains('transaction_status=settlement')) {
              NotificationService.showNotification('Status Pembayaran' , 'Transaksi Berhasil');
              DatabaseService().changeStatusToWaitingConfirmation(widget.invId);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          }

          if (url.contains('transaction_status=pending')) {
            NotificationService.showNotification('Status Pembayaran', 'Transaksi anda dalam Pending');
            Navigator.pop(context);
          }


          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: WebViewWidget(controller: controller),
      )
    );
  }
}
