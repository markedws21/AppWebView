import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  WebViewScreenState createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool isAtTop = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            // Verificar si la WebView está en la parte superior
            final position = await _controller.runJavaScriptReturningResult("window.scrollY;");
            setState(() {
              isAtTop = position == 0;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://grupolucky-intranet.azurewebsites.net/'));
  }

  Future<void> _reloadPage() async {
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title:Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Intranet Lucky',style: TextStyle(color: Colors.white),),
            IconButton(onPressed: _reloadPage, icon: const Icon(Icons.refresh,color: Colors.white,))
          ],
        )
      ),
      body: RefreshIndicator(
        onRefresh: isAtTop ? _reloadPage : () async {},
        child: NotificationListener<ScrollUpdateNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification.metrics.pixels <= 0) {
              setState(() {
                isAtTop = true;
              });
            } else {
              setState(() {
                isAtTop = false;
              });
            }
            return false;
          },
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}
