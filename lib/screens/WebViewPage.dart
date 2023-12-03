import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPage extends StatelessWidget {
  final String formLink;

  WebViewPage({required this.formLink});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Form'),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(formLink)),
        onLoadError: (InAppWebViewController controller, Uri? url, int code, String message) {
          print('Error loading $url: $message');
        },
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            // other options...
          ),
        ),
      ),
    );
  }
}