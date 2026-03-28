import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Embedded [WebViewWidget] for an event URL (Firestore `url` field).
class EventWebViewPage extends StatefulWidget {
  const EventWebViewPage({
    super.key,
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  @override
  State<EventWebViewPage> createState() => _EventWebViewPageState();
}

class _EventWebViewPageState extends State<EventWebViewPage> {
  late final WebViewController _controller;
  double _progress = 0;

  bool get _loadingComplete => _progress >= 1.0;

  @override
  void initState() {
    super.initState();
    final uri = Uri.parse(widget.url);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int value) {
            if (mounted) {
              setState(() => _progress = value / 100.0);
            }
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _progress = 1);
          },
        ),
      )
      ..loadRequest(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171717),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (!_loadingComplete)
            LinearProgressIndicator(
              value: _progress > 0 ? _progress : null,
              minHeight: 3.h,
              backgroundColor: Colors.white12,
              color: const Color(0xFF00BFA5),
            ),
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
    );
  }
}
