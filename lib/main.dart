import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebViewWidget(),
    );
  }
}

class WebViewWidget extends StatefulWidget {
  @override
  _WebViewWidgetState createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  bool _isShowingDialog = false;
  String _startUrl = 'https://flutter.dev';

  void _showConfirmationDialog(String url) {
    if (_isShowingDialog)
      return;
    _isShowingDialog = true;

    showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          content: Text("Do you want to go to $url?"),
          actions: <Widget>[
            FlatButton(
              child: const Text('NO'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            FlatButton(
              child: const Text('YES'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    ).then((bool shouldNavigate) {
      _isShowingDialog = false;

      if (shouldNavigate == true) {
        _navigateToUrl(url);
      }
    });
  }

  void _navigateToUrl(String url) {
    _controller.future.then((WebViewController controller) {
      controller.loadUrl(url);
    });
  }

  void _pushHandler(Map<String, dynamic> message, bool showDialog) {
    final dynamic data = message['data'] ?? message;
    final String url = data['url'];
    if (url == null)
      return;

    if (!_controller.isCompleted)
      _startUrl = url;
    else if (showDialog)
      _showConfirmationDialog(url);
    else
      _navigateToUrl(url);
  }

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        _pushHandler(message, true);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _pushHandler(message, false);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _pushHandler(message, false);
      },
    );

    _firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print("Push messaging token: $token");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView example'),
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {
        return WebView(
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
            webViewController.loadUrl(_startUrl);
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
        );
      }),
    );
  }
}