import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleWebViewScreen extends StatefulWidget {
  final String url; // URL of the article to display in the WebView
  final String title; // Title of the article to display in the AppBa

  const ArticleWebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<ArticleWebViewScreen> createState() => _ArticleWebViewScreenState();
}

class _ArticleWebViewScreenState extends State<ArticleWebViewScreen> {
  late final WebViewController controller;  // Controller to manage WebView behavior
  bool isLoading = true;  // Tracks whether the page is still loading

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)  // Enable unrestricted JavaScript execution
      ..setNavigationDelegate(
        NavigationDelegate(
          // Set loading state when a page starts loading
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          // Remove loading state when a page finishes loading
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url)); // Load the requested article URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),  // Display the article title in the AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            // Open the article in the default external browser
            onPressed: () => _launchUrl(widget.url),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Display the WebView content
          WebViewWidget(controller: controller),
          if (isLoading)
          // Show a loading indicator while the page is loading
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
  // Launch the article URL in an external browser
  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      if (mounted) {
        // Show a snackbar if the URL could not be opened
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the article'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
} 