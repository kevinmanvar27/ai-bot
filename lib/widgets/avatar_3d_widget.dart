import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// A 3D avatar widget that displays a GLB model using WebView and model-viewer
class Avatar3DWidget extends StatefulWidget {
  final Color emotionColor;
  final bool isActive;
  final String modelPath;

  const Avatar3DWidget({
    super.key,
    required this.emotionColor,
    required this.isActive,
    this.modelPath = 'assets/3d_model/low_poly_character_rigged.glb',
  });

  @override
  State<Avatar3DWidget> createState() => _Avatar3DWidgetState();
}

class _Avatar3DWidgetState extends State<Avatar3DWidget> {
  late WebViewController _controller;
  bool _isLoading = true;
  String? _base64Model;
  static const String _cacheKey = '3d_model_cache';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      // Try to load from cache first
      final prefs = await SharedPreferences.getInstance();
      _base64Model = prefs.getString(_cacheKey);
      
      if (_base64Model == null) {
        // Cache miss - load from assets and save to cache
        print('🔄 Loading 3D model from assets (first time)...');
        final ByteData data = await rootBundle.load(widget.modelPath);
        final bytes = data.buffer.asUint8List();
        
        // Convert to base64
        _base64Model = base64Encode(bytes);
        
        // Save to cache for future use
        await prefs.setString(_cacheKey, _base64Model!);
        print('✅ 3D model cached successfully!');
      } else {
        print('⚡ Loading 3D model from cache (instant)!');
      }
      
      // Initialize WebView controller
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF0F172A))
        ..loadHtmlString(_getHtmlContent());
      
      // Wait a bit for loading
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading 3D model: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getHtmlContent() {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
  <script type="module" src="https://ajax.googleapis.com/ajax/libs/model-viewer/3.3.0/model-viewer.min.js"></script>
  <style>
    body {
      margin: 0;
      padding: 0;
      background-color: #0F172A;
      overflow: hidden;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      touch-action: none;
    }
    model-viewer {
      width: 100vw;
      height: 100vh;
      background-color: transparent;
      pointer-events: none;
    }
  </style>
</head>
<body>
  <model-viewer
    src="data:model/gltf-binary;base64,$_base64Model"
    alt="3D Avatar"
    camera-orbit="0deg 75deg 15m"
    camera-target="0m 1.4m 0m"
    field-of-view="25deg"
    min-camera-orbit="0deg 75deg 15m"
    max-camera-orbit="0deg 75deg 15m"
    min-field-of-view="25deg"
    max-field-of-view="25deg"
    exposure="1.5"
    shadow-intensity="1.2"
    interaction-prompt="none"
    loading="eager"
    disable-tap
    disable-zoom
    disable-pan>
  </model-viewer>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        boxShadow: [
          BoxShadow(
            color: widget.emotionColor.withOpacity(0.3),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ],
      ),
      child: Stack(
        children: [
          // WebView with 3D model (Full screen, centered, fixed, smaller size)
          if (_base64Model != null)
            WebViewWidget(controller: _controller),
          
          // Loading indicator
          if (_isLoading)
            Container(
              color: const Color(0xFF0F172A),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: widget.emotionColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading 3D Model...',
                      style: TextStyle(
                        color: widget.emotionColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
