import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  WebViewScreenState createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool isAtTop = true;
  bool isLoading = true;
  bool hasInternet = true;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (_) async {
            final position = await _controller.runJavaScriptReturningResult("window.scrollY;");
            setState(() {
              isLoading = false;
              isAtTop = position == 0;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://grupolucky-intranet.azurewebsites.net/'));
  }

  Future<void> _checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      // ignore: unrelated_type_equality_checks
      hasInternet = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> _reloadPage() async {
    await _checkInternetConnection();
    if (hasInternet) {
      await _controller.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1E2B),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                width: 30,
                height: 30,
                child: Image.asset(
                  'assets/icon/luckyup.png',
                  fit: BoxFit.contain,
                ),
                ),
                const SizedBox(width: 8),
                const Text(
                'Intranet Lucky',
                style: TextStyle(color: Colors.white),
                ),
            ],
          ),
          IconButton(
            onPressed: _reloadPage,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      ),
      body: RefreshIndicator(
        onRefresh: isAtTop ? _reloadPage : () async {},
        child: hasInternet
            ? Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              )
            : _buildNoInternetWidget(),
      ),
    );
  }

  Widget _buildNoInternetWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No hay conexión a Internet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Revisa tu conexión e intenta nuevamente'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _reloadPage,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
