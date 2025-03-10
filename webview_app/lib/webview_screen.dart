import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  WebViewScreenState createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  double _dragOffset = 0.0;
  bool _showRefreshIcon = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://mapbs2.mapsalud.com/clientes/lucky/web/public/'));
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.primaryDelta!;
      _showRefreshIcon = _dragOffset > 30; // Mostrar icono si el usuario arrastra más de 30px
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_showRefreshIcon) {
      _controller.reload();
    }
    setState(() {
      _dragOffset = 0;
      _showRefreshIcon = false; // Oculta icono después de recargar
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          GestureDetector(
            onVerticalDragUpdate: _onVerticalDragUpdate,
            onVerticalDragEnd: _onVerticalDragEnd,
            child: WebViewWidget(controller: _controller),
          ),
          AnimatedOpacity(
            opacity: _showRefreshIcon ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: const Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Icon(
                Icons.refresh,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
