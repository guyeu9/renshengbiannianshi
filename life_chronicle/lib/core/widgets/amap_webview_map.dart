import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  final void Function(double lat, double lng)? onLocationSelected;
  final void Function(String name, String address, double lat, double lng)? onPoiSelected;
  final VoidCallback? onMapReady;
  final void Function(String error)? onError;

  @override
  State<AMapWebViewMap> createState() => _AMapWebViewMapState();
}

class _AMapWebViewMapState extends State<AMapWebViewMap> {
  late final WebViewController _controller;
  bool _isMapReady = false;
  bool _hasError = false;
  String _errorMessage = '';

  static const _primaryColor = '#2BCDEE';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (kDebugMode) {
              debugPrint('AMapWebViewMap: Page finished loading: $url');
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (kDebugMode) {
              debugPrint('AMapWebViewMap: Resource error: ${error.description}');
            }
            setState(() {
              _hasError = true;
              _errorMessage = error.description;
            });
            widget.onError?.call(error.description);
          },
        ),
      )
      ..addJavaScriptChannel(
        'AMapFlutter',
        onMessageReceived: _handleJsMessage,
      )
      ..loadHtmlString(_buildMapHtml());
  }

  String _buildMapHtml() {
    final initialLat = widget.initialLatitude ?? 39.908722;
    final initialLng = widget.initialLongitude ?? 116.397499;
    final markerLat = widget.markerLatitude;
    final markerLng = widget.markerLongitude;

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>高德地图</title>
  <style>
    * { margin: 0; padding: 0; }
    html, body, #container { width: 100%; height: 100%; overflow: hidden; }
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
    .location-btn svg {
      width: 24px;
      height: 24px;
      fill: #333;
    }
    .center-marker {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -100%);
      z-index: 99;
      pointer-events: none;
    }
    .center-marker svg {
      width: 32px;
      height: 32px;
    }
  </style>
</head>
<body>
  <div id="container"></div>
  ${widget.showLocationButton && !widget.isPreviewMode ? '''
  <div class="location-btn" onclick="locateMe()">
    <svg viewBox="0 0 24 24"><path d="M12 8c-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4-1.79-4-4-4zm8.94 3c-.46-4.17-3.77-7.48-7.94-7.94V1h-2v2.06C6.83 3.52 3.52 6.83 3.06 11H1v2h2.06c.46 4.17 3.77 7.48 7.94 7.94V23h2v-2.06c4.17-.46 7.48-3.77 7.94-7.94H23v-2h-2.06zM12 19c-3.87 0-7-3.13-7-7s3.13-7 7-7 7 3.13 7 7-3.13 7-7 7z"/></svg>
  </div>
  ''' : ''}
  ${!widget.isPreviewMode ? '''
  <div class="center-marker" id="centerMarker">
    <svg viewBox="0 0 24 24" fill="$_primaryColor"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg>
  </div>
  ''' : ''}
  <script src="https://webapi.amap.com/maps?v=2.0&key=${widget.webKey}"></script>
  <script>
    var map;
    var marker;
    var centerMarker = document.getElementById('centerMarker');
    
    function initMap() {
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
        AMapFlutter.postMessage(JSON.stringify({type: 'mapReady'}));
      });
      
      ${!widget.isPreviewMode ? '''
      map.on('click', function(e) {
        var lng = e.lnglat.getLng();
        var lat = e.lnglat.getLat();
        AMapFlutter.postMessage(JSON.stringify({
          type: 'click',
          lng: lng,
          lat: lat
        }));
      });
      
      map.on('moveend', function() {
        if (centerMarker) {
          var center = map.getCenter();
          AMapFlutter.postMessage(JSON.stringify({
            type: 'moveEnd',
            lng: center.getLng(),
            lat: center.getLat()
          }));
        }
      });
      ''' : ''}
      
      ${widget.enablePoiClick && !widget.isPreviewMode ? '''
      map.on('poiClick', function(e) {
        var poi = e.poi;
        if (poi && poi.location) {
          AMapFlutter.postMessage(JSON.stringify({
            type: 'poiClick',
            name: poi.name || '',
            address: poi.address || '',
            lng: poi.location.getLng(),
            lat: poi.location.getLat()
          }));
        }
      });
      ''' : ''}
    }
    
    function locateMe() {
      AMapFlutter.postMessage(JSON.stringify({type: 'locateRequest'}));
    }
    
    function setCenter(lat, lng) {
      if (map) {
        map.setCenter([lng, lat]);
      }
    }
    
    function setMarker(lat, lng) {
      if (marker) {
        marker.setPosition([lng, lat]);
      } else {
        marker = new AMap.Marker({
          position: [lng, lat],
          map: map
        });
      }
    }
    
    function clearMarker() {
      if (marker) {
        marker.setMap(null);
        marker = null;
      }
    }
    
    if (typeof AMap !== 'undefined') {
      initMap();
    } else {
      window.onerror = function(msg) {
        AMapFlutter.postMessage(JSON.stringify({type: 'error', message: msg}));
      };
    }
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
          });
          widget.onError?.call(errorMsg);
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AMapWebViewMap: Error parsing JS message: $e');
      }
    }
  }

  Future<void> _handleLocationRequest() async {
    try {
      await _controller.runJavaScript('''
        if (navigator.geolocation) {
          navigator.geolocation.getCurrentPosition(
            function(position) {
              var lat = position.coords.latitude;
              var lng = position.coords.longitude;
              map.setCenter([lng, lat]);
              map.setZoom(15);
              AMapFlutter.postMessage(JSON.stringify({
                type: 'locationResult',
                lat: lat,
                lng: lng
              }));
            },
            function(error) {
              AMapFlutter.postMessage(JSON.stringify({
                type: 'locationError',
                message: error.message
              }));
            }
          );
        }
      ''');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AMapWebViewMap: Error running location script: $e');
      }
    }
  }

  Future<void> setCenter(double lat, double lng) async {
    await _controller.runJavaScript('setCenter($lat, $lng)');
  }

  Future<void> setMarker(double lat, double lng) async {
    await _controller.runJavaScript('setMarker($lat, $lng)');
  }

  Future<void> clearMarker() async {
    await _controller.runJavaScript('clearMarker()');
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                '地图加载失败',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (!_isMapReady && !_hasError)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
