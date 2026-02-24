import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AMapWebViewMap extends StatefulWidget {
  const AMapWebViewMap({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialZoom = 15,
    this.showLocationButton = true,
    this.enablePoiClick = true,
    this.isPreviewMode = false,
    this.markerLatitude,
    this.markerLongitude,
    this.webKey = '',
    this.securityCode = '',
    this.onLocationSelected,
    this.onPoiSelected,
    this.onMapReady,
    this.onError,
  });

  final double? initialLatitude;
  final double? initialLongitude;
  final double initialZoom;
  final bool showLocationButton;
  final bool enablePoiClick;
  final bool isPreviewMode;
  final double? markerLatitude;
  final double? markerLongitude;
  final String webKey;
  final String securityCode;
  final void Function(double lat, double lng)? onLocationSelected;
  final void Function(String name, String address, double lat, double lng)? onPoiSelected;
  final VoidCallback? onMapReady;
  final void Function(String error)? onError;

  @override
  State<AMapWebViewMap> createState() => _AMapWebViewMapState();
}

class _AMapWebViewMapState extends State<AMapWebViewMap> {
  WebViewController? _controller;
  bool _isMapReady = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _locationPermissionGranted = false;
  bool _isLoading = true;

  static const _primaryColor = '#2BCDEE';

  @override
  void initState() {
    super.initState();
    _requestLocationPermission().then((_) {
      _initWebView();
    });
  }

  Future<void> _requestLocationPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      _locationPermissionGranted = true;
      return;
    }

    try {
      final status = await Permission.location.status;
      if (status.isGranted) {
        _locationPermissionGranted = true;
        return;
      }

      final result = await Permission.location.request();
      if (result.isGranted) {
        _locationPermissionGranted = true;
      } else if (result.isPermanentlyDenied) {
        if (kDebugMode) {
          debugPrint('AMapWebViewMap: Location permission permanently denied');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AMapWebViewMap: Permission request error: $e');
      }
    }
  }

  void _initWebView() {
    final htmlContent = _buildMapHtml();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('AMapWebViewMap: Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('AMapWebViewMap: Page finished loading: $url');
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('AMapWebViewMap: Resource error: ${error.description}, code: ${error.errorCode}');
            setState(() {
              _hasError = true;
              _errorMessage = '资源加载失败 (${error.errorCode}): ${error.description}';
              _isLoading = false;
            });
            widget.onError?.call(_errorMessage);
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('AMapWebViewMap: Navigation request: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'AMapFlutter',
        onMessageReceived: _handleJsMessage,
      )
      ..addJavaScriptChannel(
        'ConsoleLog',
        onMessageReceived: (message) {
          debugPrint('[WebView] ${message.message}');
        },
      );

    if (Platform.isAndroid) {
      _controller!.loadHtmlString(htmlContent, baseUrl: 'https://webapi.amap.com/');
    } else {
      _controller!.loadHtmlString(htmlContent);
    }

    setState(() {});
  }

  String _buildMapHtml() {
    final initialLat = widget.initialLatitude ?? 39.908722;
    final initialLng = widget.initialLongitude ?? 116.397499;
    final markerLat = widget.markerLatitude;
    final markerLng = widget.markerLongitude;
    final webKey = widget.webKey;

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>地图</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; overflow: hidden; background: #f5f5f5; }
    #container { width: 100%; height: 100%; }
    .location-btn {
      position: absolute;
      right: 10px;
      bottom: 20px;
      width: 40px;
      height: 40px;
      background: white;
      border-radius: 8px;
      box-shadow: 0 2px 6px rgba(0,0,0,0.15);
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      z-index: 100;
    }
    .location-btn svg { width: 24px; height: 24px; fill: #333; }
    .center-marker {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -100%);
      z-index: 99;
      pointer-events: none;
    }
    .center-marker svg { width: 32px; height: 32px; }
    .status {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      height: 100%;
      color: #666;
      font-size: 14px;
      text-align: center;
      padding: 20px;
    }
    .status svg { width: 48px; height: 48px; margin-bottom: 12px; }
    .status.error svg { fill: #ef4444; }
    .status.loading svg { fill: #2196f3; }
  </style>
</head>
<body>
  <div id="container">
    <div class="status loading" id="status">
      <svg viewBox="0 0 24 24"><path d="M12 4V1L8 5l4 4V6c3.31 0 6 2.69 6 6 0 1.01-.25 1.97-.7 2.8l1.46 1.46C19.54 15.03 20 13.57 20 12c0-4.42-3.58-8-8-8zm0 14c-3.31 0-6-2.69-6-6 0-1.01.25-1.97.7-2.8L5.24 7.74C4.46 8.97 4 10.43 4 12c0 4.42 3.58 8 8 8v3l4-4-4-4v3z"/></svg>
      <div>正在加载地图...</div>
    </div>
  </div>
  ${widget.showLocationButton && !widget.isPreviewMode ? '''
  <div class="location-btn" id="locationBtn">
    <svg viewBox="0 0 24 24"><path d="M12 8c-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4-1.79-4-4-4zm8.94 3c-.46-4.17-3.77-7.48-7.94-7.94V1h-2v2.06C6.83 3.52 3.52 6.83 3.06 11H1v2h2.06c.46 4.17 3.77 7.48 7.94 7.94V23h2v-2.06c4.17-.46 7.48-3.77 7.94-7.94H23v-2h-2.06zM12 19c-3.87 0-7-3.13-7-7s3.13-7 7-7 7 3.13 7 7-3.13 7-7 7z"/></svg>
  </div>
  ''' : ''}
  ${!widget.isPreviewMode ? '''
  <div class="center-marker" id="centerMarker" style="display: none;">
    <svg viewBox="0 0 24 24" fill="$_primaryColor"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg>
  </div>
  ''' : ''}
  <script>
    (function() {
      var map = null;
      var marker = null;
      var statusEl = document.getElementById('status');
      var centerMarker = document.getElementById('centerMarker');
      var locationBtn = document.getElementById('locationBtn');
      
      function log(msg) {
        try { ConsoleLog.postMessage('[AMap] ' + msg); } catch(e) {}
      }
      
      function showError(msg) {
        statusEl.className = 'status error';
        statusEl.innerHTML = '<svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/></svg><div>' + msg + '</div>';
        try { AMapFlutter.postMessage(JSON.stringify({type: 'error', message: msg})); } catch(e) {}
      }
      
      function showLoading(msg) {
        statusEl.className = 'status loading';
        statusEl.innerHTML = '<svg viewBox="0 0 24 24"><path d="M12 4V1L8 5l4 4V6c3.31 0 6 2.69 6 6 0 1.01-.25 1.97-.7 2.8l1.46 1.46C19.54 15.03 20 13.57 20 12c0-4.42-3.58-8-8-8zm0 14c-3.31 0-6-2.69-6-6 0-1.01.25-1.97.7-2.8L5.24 7.74C4.46 8.97 4 10.43 4 12c0 4.42 3.58 8 8 8v3l4-4-4-4v3z"/></svg><div>' + msg + '</div>';
      }
      
      if (locationBtn) {
        locationBtn.onclick = function() {
          try { AMapFlutter.postMessage(JSON.stringify({type: 'locateRequest'})); } catch(e) {}
        };
      }
      
      window.onerror = function(msg, url, line, col, error) {
        log('JS Error: ' + msg + ' @ ' + line + ':' + col);
        showError('脚本错误: ' + msg);
        return true;
      };
      
      window.initAMap = function() {
        log('AMap callback fired');
        
        if (typeof AMap === 'undefined') {
          showError('地图 API 未定义');
          return;
        }
        
        try {
          statusEl.style.display = 'none';
          if (centerMarker) centerMarker.style.display = 'block';
          
          map = new AMap.Map('container', {
            zoom: ${widget.initialZoom},
            center: [$initialLng, $initialLat],
            resizeEnable: true
          });
          
          ${widget.isPreviewMode && markerLat != null && markerLng != null ? '''
          marker = new AMap.Marker({
            position: [$markerLng, $markerLat],
            map: map
          });
          map.setCenter([$markerLng, $markerLat]);
          ''' : ''}
          
          map.on('complete', function() {
            log('Map complete');
            try { AMapFlutter.postMessage(JSON.stringify({type: 'mapReady'})); } catch(e) {}
          });
          
          ${!widget.isPreviewMode ? '''
          map.on('click', function(e) {
            try {
              AMapFlutter.postMessage(JSON.stringify({
                type: 'click',
                lng: e.lnglat.getLng(),
                lat: e.lnglat.getLat()
              }));
            } catch(e) {}
          });
          
          map.on('moveend', function() {
            if (centerMarker) {
              try {
                var c = map.getCenter();
                AMapFlutter.postMessage(JSON.stringify({
                  type: 'moveEnd',
                  lng: c.getLng(),
                  lat: c.getLat()
                }));
              } catch(e) {}
            }
          });
          ''' : ''}
          
          ${widget.enablePoiClick && !widget.isPreviewMode ? '''
          map.on('poiClick', function(e) {
            var poi = e.poi;
            if (poi && poi.location) {
              try {
                AMapFlutter.postMessage(JSON.stringify({
                  type: 'poiClick',
                  name: poi.name || '',
                  address: poi.address || '',
                  lng: poi.location.getLng(),
                  lat: poi.location.getLat()
                }));
              } catch(e) {}
            }
          });
          ''' : ''}
          
        } catch (e) {
          log('Map init failed: ' + e.message);
          showError('地图初始化失败: ' + e.message);
        }
      };
      
      window.setCenter = function(lat, lng) {
        if (map) map.setCenter([lng, lat]);
      };
      
      window.setMarker = function(lat, lng) {
        if (marker) {
          marker.setPosition([lng, lat]);
        } else if (map) {
          marker = new AMap.Marker({ position: [lng, lat], map: map });
        }
      };
      
      window.clearMarker = function() {
        if (marker) { marker.setMap(null); marker = null; }
      };
      
      log('Loading AMap JS API v2.0...');
      log('Key: $webKey');
      
      // 安全密钥配置
      window._AMapSecurityConfig = {
        securityJsCode: '${widget.securityCode}',
      };
      
      var script = document.createElement('script');
      script.src = 'https://webapi.amap.com/maps?v=2.0&key=$webKey&callback=initAMap';
      script.async = true;
      script.onerror = function() {
        log('Script load failed');
        showError('地图脚本加载失败，请检查网络');
      };
      document.head.appendChild(script);
      
    })();
  </script>
</body>
</html>
''';
  }

  void _handleJsMessage(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      final type = data['type'] as String?;

      switch (type) {
        case 'mapReady':
          setState(() => _isMapReady = true);
          widget.onMapReady?.call();
          break;
        case 'click':
          final lat = (data['lat'] as num).toDouble();
          final lng = (data['lng'] as num).toDouble();
          widget.onLocationSelected?.call(lat, lng);
          break;
        case 'moveEnd':
          final lat = (data['lat'] as num).toDouble();
          final lng = (data['lng'] as num).toDouble();
          widget.onLocationSelected?.call(lat, lng);
          break;
        case 'poiClick':
          final name = data['name'] as String? ?? '';
          final address = data['address'] as String? ?? '';
          final lat = (data['lat'] as num).toDouble();
          final lng = (data['lng'] as num).toDouble();
          widget.onPoiSelected?.call(name, address, lat, lng);
          break;
        case 'locateRequest':
          _handleLocationRequest();
          break;
        case 'error':
          final errorMsg = data['message'] as String? ?? 'Unknown error';
          setState(() {
            _hasError = true;
            _errorMessage = errorMsg;
            _isLoading = false;
          });
          widget.onError?.call(errorMsg);
          break;
      }
    } catch (e) {
      debugPrint('AMapWebViewMap: Error parsing JS message: $e');
    }
  }

  Future<void> _handleLocationRequest() async {
    if (!_locationPermissionGranted) {
      await _requestLocationPermission();
      if (!_locationPermissionGranted) {
        debugPrint('AMapWebViewMap: Location permission not granted');
        return;
      }
    }

    try {
      await _controller?.runJavaScript('''
        if (navigator.geolocation) {
          navigator.geolocation.getCurrentPosition(
            function(pos) {
              if (window.setCenter) window.setCenter(pos.coords.latitude, pos.coords.longitude);
              AMapFlutter.postMessage(JSON.stringify({
                type: 'locationResult',
                lat: pos.coords.latitude,
                lng: pos.coords.longitude
              }));
            },
            function(err) {
              AMapFlutter.postMessage(JSON.stringify({
                type: 'locationError',
                message: err.message
              }));
            },
            { enableHighAccuracy: true, timeout: 10000 }
          );
        }
      ''');
    } catch (e) {
      debugPrint('AMapWebViewMap: Error running location script: $e');
    }
  }

  Future<void> setCenter(double lat, double lng) async {
    await _controller?.runJavaScript('if(window.setCenter) window.setCenter($lat, $lng)');
  }

  Future<void> setMarker(double lat, double lng) async {
    await _controller?.runJavaScript('if(window.setMarker) window.setMarker($lat, $lng)');
  }

  Future<void> clearMarker() async {
    await _controller?.runJavaScript('if(window.clearMarker) window.clearMarker()');
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              const Text('地图加载失败', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_errorMessage, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _errorMessage = '';
                    _isLoading = true;
                    _isMapReady = false;
                  });
                  _initWebView();
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller!),
        if (_isLoading || !_isMapReady)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
