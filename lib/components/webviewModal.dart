import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewAppModalPage extends StatefulWidget {
  const WebViewAppModalPage(
      {Key? key,
      required this.title,
      required this.url,
      required this.controller,
      required this.onUpdateProgress})
      : super(key: key);

  final String title;
  final String url;
  final Completer<WebViewController> controller;
  final Function onUpdateProgress;

  @override
  State<WebViewAppModalPage> createState() => _WebViewAppModalPageState();
}

class _WebViewAppModalPageState extends State<WebViewAppModalPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _sourceWeb();
  }

  Widget _sourceWeb() {
    return WebView(
      initialUrl: widget.url,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        widget.controller.complete(webViewController);
      },
      onProgress: (int progress) {
        widget.onUpdateProgress(progress);
      },
      javascriptChannels: <JavascriptChannel>{
        _toasterJavascriptChannel(context),
      },
      navigationDelegate: (NavigationRequest request) {
        return NavigationDecision.navigate;
      },
      onPageStarted: (String url) {},
      onPageFinished: (String url) async {},
      gestureNavigationEnabled: true,
      backgroundColor: const Color(0x00000000),
    );
  }
}

JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
  return JavascriptChannel(
      name: 'Toaster',
      onMessageReceived: (JavascriptMessage message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      });
}
