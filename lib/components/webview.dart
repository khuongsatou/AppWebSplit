import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewAppPage extends StatefulWidget {
  const WebViewAppPage(
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
  State<WebViewAppPage> createState() => _WebViewAppPageState();
}

class _WebViewAppPageState extends State<WebViewAppPage> {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
        // print('WebView is loading (progress : $progress%)');
        widget.onUpdateProgress(progress);
      },
      javascriptChannels: <JavascriptChannel>{
        _toasterJavascriptChannel(context),
      },
      navigationDelegate: (NavigationRequest request) {
        // if (request.url.startsWith('https://www.youtube.com/')) {
        //   print('blocking navigation to $request}');
        //   return NavigationDecision.prevent;
        // }
        // print('allowing navigation to $request');
        return NavigationDecision.navigate;
      },
      onPageStarted: (String url) {
        // print('Page started loading: $url');
      },
      onPageFinished: (String url) async {
        // print('Page finished loading: $url');
      },
      gestureNavigationEnabled: true,
      backgroundColor: const Color(0x00000000),
    );
  }
}

JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
  return JavascriptChannel(
      name: 'Toaster',
      onMessageReceived: (JavascriptMessage message) {
        // print("message:" + message.message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      });
}
