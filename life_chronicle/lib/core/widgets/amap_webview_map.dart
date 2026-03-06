import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../services/file_logger.dart';

class AMapWebViewMap extends StatefulWidget {
  const AMapWebViewMap({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialZoom = 15,
    this.showLocationButton = true,
    this.enablePoiClick = true,
    this.isPreviewMode = false,
    this.autoLocate = false,
    this.markerLatitude,
    this.markerLongitude,
    this.webKey = '',
    this.securityCode = '',
    this.onLocationSelected,
    this.onPoiSelected,
    this.onMapReady,
    this.onError,
    this.onLocationWithAddress,
    this.onLocationReadyForNearbySearch,
    this.onMapMoveEnd,
  });

  final double? initialLatitude;
  final double? initialLongitude;
  final double initialZoom;
  final bool showLocationButton;
  final bool enablePoiClick;
  final bool isPreviewMode;
  final bool autoLocate;
  final double? markerLatitude;
  final double? markerLongitude;
  final String webKey;
  final String securityCode;
  final void Function(double lat, double lng)? onLocationSelected;
  final void Function(String name, String address, double lat, double lng)? onPoiSelected;
  final VoidCallback? onMapReady;
  final void Function(String error)? onError;
  final void Function(double lat, double lng, String city, String address, String description)? onLocationWithAddress;
  final void Function(double lat, double lng)? onLocationReadyForNearbySearch;
  final void Function(double lat, double lng)? onMapMoveEnd;

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
  AMapFlutterLocation? _locationPlugin;
  StreamSubscription<Map<String, Object>>? _locationSubscription;
  bool _isLocating = false;
  double? _pendingLat;
  double? _pendingLng;

  static const _primaryColor = '#2BCDEE';
  static const _amapAndroidKey = String.fromEnvironment('AMAP_ANDROID_KEY', defaultValue: 'a5a3e21e2d17ffa851374ed158a985a6');
  static const _amapIosKey = String.fromEnvironment('AMAP_IOS_KEY', defaultValue: '');
  static const _amapWebKey = String.fromEnvironment('AMAP_WEB_KEY', defaultValue: '76e66f23c7045fbe296f9aa9b7e7f12c');

  @override
  void initState() {
    super.initState();
    amapLog('AmapWebView', '========== WebView Map initState ==========');
    amapLog('AmapWebView', 'initialLatitude: ${widget.initialLatitude}');
    amapLog('AmapWebView', 'initialLongitude: ${widget.initialLongitude}');
    amapLog('AmapWebView', 'autoLocate: ${widget.autoLocate}');
    amapLog('AmapWebView', 'webKey configured: ${widget.webKey.isNotEmpty}');
    amapLog('AmapWebView', '===========================================');
    _initLocationPlugin();
    _requestLocationPermission().then((_) {
      _initWebView();
    });
  }

  void _initLocationPlugin() {
    amapLog('AmapWebView', 'Initializing location plugin...');
    AMapFlutterLocation.setApiKey(_amapAndroidKey, _amapIosKey);
    AMapFlutterLocation.updatePrivacyShow(true, true);
    AMapFlutterLocation.updatePrivacyAgree(true);
    amapLog('AmapWebView', 'Privacy settings updated');
    
    _locationPlugin = AMapFlutterLocation();
    _locationPlugin?.setLocationOption(AMapLocationOption(
      onceLocation: true,
      needAddress: true,
      geoLanguage: GeoLanguage.ZH,
      locationMode: AMapLocationMode.Hight_Accuracy,
    ));
    amapLog('AmapWebView', 'Location plugin initialized');
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _locationPlugin?.destroy();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    amapLog('AmapWebView', '========== Requesting location permission ==========');
    if (!Platform.isAndroid && !Platform.isIOS) {
      amapLog('AmapWebView', 'Not on mobile, permission granted');
      _locationPermissionGranted = true;
      return;
    }

    try {
      final status = await Permission.location.status;
      amapLog('AmapWebView', 'Current permission status: $status');
      if (status.isGranted) {
        amapLog('AmapWebView', 'Permission already granted');
        _locationPermissionGranted = true;
        return;
      }

      amapLog('AmapWebView', 'Requesting location permission...');
      final result = await Permission.location.request();
      amapLog('AmapWebView', 'Permission request result: $result');
      if (result.isGranted) {
        amapLog('AmapWebView', 'Permission granted');
        _locationPermissionGranted = true;
      } else if (result.isPermanentlyDenied) {
        amapLog('AmapWebView', 'Location permission permanently denied');
      } else if (result.isDenied) {
        amapLog('AmapWebView', 'Location permission denied');
      }
    } catch (e) {
      amapLog('AmapWebView', 'Permission request error: $e');
    }
    
    try {
      final preciseStatus = await Permission.locationAlways.status;
      amapLog('AmapWebView', 'LocationAlways status: $preciseStatus');
      final whenInUseStatus = await Permission.locationWhenInUse.status;
      amapLog('AmapWebView', 'LocationWhenInUse status: $whenInUseStatus');
    } catch (e) {
      amapLog('AmapWebView', 'Precise location permission check error: $e');
    }
    
    amapLog('AmapWebView', '_locationPermissionGranted: $_locationPermissionGranted');
    amapLog('AmapWebView', '===================================================');
  }

  void _initWebView() {
    amapLog('AmapWebView', '========== Initializing WebView ==========');
    amapLog('AmapWebView', 'Platform: ${Platform.operatingSystem}');
    amapLog('AmapWebView', 'webKey length: ${widget.webKey.length}');
    amapLog('AmapWebView', 'securityCode length: ${widget.securityCode.length}');
    
    final htmlContent = _buildMapHtml();
    amapLog('AmapWebView', 'HTML content length: ${htmlContent.length}');
    amapLog('AmapWebView', 'HTML content preview (first 500 chars): ${htmlContent.substring(0, htmlContent.length > 500 ? 500 : htmlContent.length)}');
    
    amapLog('AmapWebView', 'Creating WebViewController...');
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            amapLog('AmapWebView', '>>> onPageStarted: $url');
          },
          onPageFinished: (String url) {
            amapLog('AmapWebView', '>>> onPageFinished: $url');
            amapLog('AmapWebView', '>>> Setting _isLoading = false');
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            amapLog('AmapWebView', '>>> onWebResourceError: ${error.description}');
            amapLog('AmapWebView', '>>> Error code: ${error.errorCode}, type: ${error.errorType}');
            amapLog('AmapWebView', '>>> Error URL: ${error.url}');
            setState(() {
              _hasError = true;
              _errorMessage = '资源加载失败 (${error.errorCode}): ${error.description}';
              _isLoading = false;
            });
            widget.onError?.call(_errorMessage);
          },
          onNavigationRequest: (NavigationRequest request) {
            amapLog('AmapWebView', '>>> onNavigationRequest: ${request.url}');
            return NavigationDecision.navigate;
          },
          onHttpError: (error) {
            amapLog('AmapWebView', '>>> onHttpError: ${error.response?.statusCode}');
          },
          onUrlChange: (change) {
            amapLog('AmapWebView', '>>> onUrlChange: ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'AMapFlutter',
        onMessageReceived: (message) {
          amapLog('AmapWebView', '>>> AMapFlutter message received: ${message.message}');
          _handleJsMessage(message);
        },
      )
      ..addJavaScriptChannel(
        'ConsoleLog',
        onMessageReceived: (message) {
          amapLog('WebViewConsole', message.message);
        },
      );

    amapLog('AmapWebView', 'Loading HTML content...');
    if (Platform.isAndroid) {
      amapLog('AmapWebView', 'Android platform, using baseUrl: https://webapi.amap.com/');
      _controller!.loadHtmlString(htmlContent, baseUrl: 'https://webapi.amap.com/');
    } else {
      amapLog('AmapWebView', 'iOS platform, no baseUrl');
      _controller!.loadHtmlString(htmlContent);
    }

    setState(() {});
    amapLog('AmapWebView', 'WebView initialization complete');
    amapLog('AmapWebView', '_controller is null: ${_controller == null}');
    amapLog('AmapWebView', '========================================');
  }

  String _buildMapHtml() {
    final initialLat = widget.initialLatitude ?? 39.908722;
    final initialLng = widget.initialLongitude ?? 116.397499;
    final markerLat = widget.markerLatitude;
    final markerLng = widget.markerLongitude;
    final webKey = widget.webKey;
    final securityCode = widget.securityCode;
    final initialZoom = widget.initialZoom;
    final primaryColor = _primaryColor;
    final showLocationButton = widget.showLocationButton && !widget.isPreviewMode;
    final isPreviewMode = widget.isPreviewMode;
    final enablePoiClick = widget.enablePoiClick && !widget.isPreviewMode;
    final hasMarker = isPreviewMode && markerLat != null && markerLng != null;

    amapLog('AmapWebView', 'Building HTML with webKey=$webKey, securityCode=${securityCode.isNotEmpty ? "已配置" : "未配置"}');
    amapLog('AmapWebView', 'Initial position: lat=$initialLat, lng=$initialLng, zoom=$initialZoom');

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
  ${showLocationButton ? '''
  <div class="location-btn" id="locationBtn">
    <svg viewBox="0 0 24 24"><path d="M12 8c-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4-1.79-4-4-4zm8.94 3c-.46-4.17-3.77-7.48-7.94-7.94V1h-2v2.06C6.83 3.52 3.52 6.83 3.06 11H1v2h2.06c.46 4.17 3.77 7.48 7.94 7.94V23h2v-2.06c4.17-.46 7.48-3.77 7.94-7.94H23v-2h-2.06zM12 19c-3.87 0-7-3.13-7-7s3.13-7 7-7 7 3.13 7 7-3.13 7-7 7z"/></svg>
  </div>
  ''' : ''}
  ${!isPreviewMode ? '''
  <div class="center-marker" id="centerMarker" style="display: none;">
    <svg viewBox="0 0 24 24" fill="$primaryColor"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg>
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
        log('>>> initAMap callback fired');
        log('>>> typeof AMap: ' + typeof AMap);
        
        if (typeof AMap === 'undefined') {
          log('>>> ERROR: AMap is undefined!');
          showError('地图 API 未定义');
          return;
        }
        
        log('>>> AMap is defined, creating map...');
        try {
          statusEl.style.display = 'none';
          if (centerMarker) centerMarker.style.display = 'block';
          
          log('>>> Creating AMap.Map with container, zoom=$initialZoom, center=[$initialLng, $initialLat]');
          map = new AMap.Map('container', {
            zoom: $initialZoom,
            center: [$initialLng, $initialLat],
            resizeEnable: true
          });
          log('>>> Map created successfully: ' + (map ? 'yes' : 'no'));
          
          ${hasMarker ? '''
          log('>>> Creating marker at [$markerLng, $markerLat]');
          marker = new AMap.Marker({
            position: [$markerLng, $markerLat],
            map: map
          });
          map.setCenter([$markerLng, $markerLat]);
          log('>>> Marker created and center set');
          ''' : ''}
          
          map.on('complete', function() {
            log('>>> Map complete event fired');
            try { 
              var msg = JSON.stringify({type: 'mapReady'});
              log('>>> Sending mapReady message: ' + msg);
              AMapFlutter.postMessage(msg);
              log('>>> mapReady message sent successfully');
            } catch(e) {
              log('>>> mapReady postMessage FAILED: ' + e.message);
            }
          });
          
          ${!isPreviewMode ? '''
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
          
          ${enablePoiClick ? '''
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
      log('Security Code: ${securityCode.isNotEmpty ? "已配置" : "未配置"}');
      log('Initial position: lat=$initialLat, lng=$initialLng, zoom=$initialZoom');
      log('isPreviewMode: $isPreviewMode, hasMarker: $hasMarker');
      
      // 安全密钥配置
      window._AMapSecurityConfig = {
        securityJsCode: '$securityCode',
      };
      log('Security config set');
      
      var script = document.createElement('script');
      var scriptUrl = 'https://webapi.amap.com/maps?v=2.0&key=$webKey&callback=initAMap';
      log('Creating script tag with URL: ' + scriptUrl);
      script.src = scriptUrl;
      script.async = true;
      script.onload = function() {
        log('>>> Script onload fired - script loaded successfully');
      };
      script.onerror = function(e) {
        log('>>> Script onerror fired: ' + (e || 'unknown error'));
        showError('地图脚本加载失败，请检查网络');
      };
      log('Appending script to document.head');
      document.head.appendChild(script);
      log('Script appended, waiting for callback...');
      
    })();
  </script>
</body>
</html>
''';
  }

  bool _isValidChinaCoordinate(double lat, double lng) {
    return lat >= 18.0 && lat <= 53.0 && lng >= 73.0 && lng <= 135.0;
  }

  void _handleValidLocation(double lat, double lng, String city, String address, String description) {
    if (address.isEmpty && city.isEmpty) {
      amapLog('AmapWebView', 'Address empty, will use reverse geocode from parent widget');
    }
    
    if (_isMapReady) {
      amapLog('AmapWebView', 'Map is ready, setting center...');
      _controller?.runJavaScript('if(window.setCenter) window.setCenter($lng, $lat)');
    } else {
      _pendingLat = lat;
      _pendingLng = lng;
      amapLog('AmapWebView', 'Map not ready, caching location: lat=$lat, lng=$lng');
    }
    widget.onLocationSelected?.call(lat, lng);
    widget.onLocationWithAddress?.call(lat, lng, city, address, description);
    widget.onLocationReadyForNearbySearch?.call(lat, lng);
    setState(() => _isLocating = false);
    amapLog('AmapWebView', 'Location success: lat=$lat, lng=$lng, city=$city, address=$address');
  }

  Future<void> _tryIpLocation() async {
    amapLog('AmapWebView', '========== Trying IP-based location ==========');
    try {
      final uri = Uri.https('restapi.amap.com', '/v3/ip', {
        'key': _amapWebKey,
      });
      final client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close(force: true);

      amapLog('AmapWebView', 'IP location response: $body');
      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw Exception('Invalid response');
      }
      
      final status = '${decoded['status'] ?? ''}'.trim();
      if (status != '1') {
        throw Exception('API returned status: $status');
      }
      
      final rectangle = '${decoded['rectangle'] ?? ''}'.trim();
      if (rectangle.isEmpty) {
        throw Exception('No rectangle in response');
      }
      
      final parts = rectangle.split(';');
      if (parts.length < 2) {
        throw Exception('Invalid rectangle format');
      }
      
      final coord1 = parts[0].split(',');
      final coord2 = parts[1].split(',');
      if (coord1.length < 2 || coord2.length < 2) {
        throw Exception('Invalid coordinate format');
      }
      
      final lng1 = double.tryParse(coord1[0].trim()) ?? 0;
      final lat1 = double.tryParse(coord1[1].trim()) ?? 0;
      final lng2 = double.tryParse(coord2[0].trim()) ?? 0;
      final lat2 = double.tryParse(coord2[1].trim()) ?? 0;
      
      final centerLng = (lng1 + lng2) / 2;
      final centerLat = (lat1 + lat2) / 2;
      
      amapLog('AmapWebView', 'IP location center: lat=$centerLat, lng=$centerLng');
      
      if (!_isValidChinaCoordinate(centerLat, centerLng)) {
        throw Exception('IP location outside China: lat=$centerLat, lng=$centerLng');
      }
      
      final province = '${decoded['province'] ?? ''}'.trim();
      final city = '${decoded['city'] ?? ''}'.trim();
      
      String address = '';
      if (province.isNotEmpty) address += province;
      if (city.isNotEmpty) address += city;
      
      String description = city.isNotEmpty ? city : province;
      
      if (mounted) {
        _handleValidLocation(centerLat, centerLng, city, address, description);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已使用网络定位：${city.isNotEmpty ? city : province}')),
        );
      }
    } catch (e) {
      amapLog('AmapWebView', 'IP location failed: $e');
      if (mounted) {
        setState(() => _isLocating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('定位失败，请检查设备定位服务或稍后重试')),
        );
      }
    }
    amapLog('AmapWebView', '===========================================');
  }

  void _handleJsMessage(JavaScriptMessage message) {
    amapLog('AmapWebView', '>>> _handleJsMessage called');
    amapLog('AmapWebView', '>>> Raw message: ${message.message}');
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      final type = data['type'] as String?;
      amapLog('AmapWebView', '>>> Parsed type: $type');
      amapLog('AmapWebView', '>>> Parsed data: $data');

      switch (type) {
        case 'mapReady':
          amapLog('AmapWebView', '========== mapReady message received ==========');
          setState(() {
            _isMapReady = true;
            _isLoading = false;
          });
          widget.onMapReady?.call();
          amapLog('AmapWebView', '_isMapReady set to true, _isLoading set to false');
          if (_pendingLat != null && _pendingLng != null) {
            if (_isValidChinaCoordinate(_pendingLat!, _pendingLng!)) {
              amapLog('AmapWebView', 'Map ready, setting cached location: lat=$_pendingLat, lng=$_pendingLng');
              _controller?.runJavaScript('if(window.setCenter) window.setCenter($_pendingLng, $_pendingLat)');
            } else {
              amapLog('AmapWebView', 'Cached location invalid (outside China): lat=$_pendingLat, lng=$_pendingLng, ignoring');
            }
            _pendingLat = null;
            _pendingLng = null;
          } else if (widget.autoLocate && !widget.isPreviewMode) {
            amapLog('AmapWebView', 'Map ready, auto-locating...');
            _handleLocationRequest();
          }
          break;
        case 'click':
          amapLog('AmapWebView', '>>> click event received');
          final lat = (data['lat'] as num).toDouble();
          final lng = (data['lng'] as num).toDouble();
          widget.onLocationSelected?.call(lat, lng);
          break;
        case 'moveEnd':
          amapLog('AmapWebView', '>>> moveEnd event received');
          final lat = (data['lat'] as num).toDouble();
          final lng = (data['lng'] as num).toDouble();
          widget.onLocationSelected?.call(lat, lng);
          widget.onMapMoveEnd?.call(lat, lng);
          break;
        case 'poiClick':
          amapLog('AmapWebView', '>>> poiClick event received');
          final name = data['name'] as String? ?? '';
          final address = data['address'] as String? ?? '';
          final lat = (data['lat'] as num).toDouble();
          final lng = (data['lng'] as num).toDouble();
          widget.onPoiSelected?.call(name, address, lat, lng);
          break;
        case 'locateRequest':
          amapLog('AmapWebView', '>>> locateRequest event received');
          _handleLocationRequest();
          break;
        case 'error':
          amapLog('AmapWebView', '>>> error event received');
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
      amapLog('AmapWebView', 'Error parsing JS message: $e');
    }
  }

  Future<void> _handleLocationRequest() async {
    amapLog('AmapWebView', '========== Handling location request ==========');
    if (_isLocating) {
      amapLog('AmapWebView', 'Already locating, skip');
      return;
    }

    amapLog('AmapWebView', 'Cancelling existing subscription...');
    _locationSubscription?.cancel();
    _locationSubscription = null;

    amapLog('AmapWebView', 'Reinitializing location plugin...');
    _locationPlugin?.destroy();
    _initLocationPlugin();
    
    if (!_locationPermissionGranted) {
      amapLog('AmapWebView', 'Permission not granted, requesting...');
      await _requestLocationPermission();
      if (!_locationPermissionGranted) {
        amapLog('AmapWebView', 'Location permission still not granted');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('定位权限未授权，请在设置中开启')),
          );
        }
        return;
      }
    }

    amapLog('AmapWebView', 'Setting _isLocating = true');
    setState(() => _isLocating = true);
    
    try {
      amapLog('AmapWebView', 'Setting up location listener...');
      _locationSubscription = _locationPlugin?.onLocationChanged().listen(
        (result) {
          amapLog('AmapWebView', '========== Location result received ==========');
          amapLog('AmapWebView', 'Full location result: $result');
          amapLog('AmapWebView', 'Result keys: ${result.keys.toList()}');
          result.forEach((key, value) {
            amapLog('AmapWebView', '  $key: $value');
          });
          _locationSubscription?.cancel();
          
          final errorCode = result['errorCode'];
          if (errorCode != null && errorCode != 0) {
            final errorInfo = result['errorInfo'] ?? '定位失败';
            amapLog('AmapWebView', 'Location error code=$errorCode, info=$errorInfo');
            if (mounted) {
              setState(() => _isLocating = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('定位失败: $errorInfo')),
              );
            }
            return;
          }
          
          final lat = result['latitude'] as double?;
          final lng = result['longitude'] as double?;
          var city = (result['city'] as String?) ?? '';
          var address = (result['address'] as String?) ?? '';
          var description = (result['description'] as String?) ?? '';
          
          amapLog('AmapWebView', 'Location details - lat=$lat, lng=$lng, city=$city, address=$address, description=$description');
          
          if (lat != null && lng != null && mounted) {
            final isValidCoord = _isValidChinaCoordinate(lat, lng);
            amapLog('AmapWebView', 'Coordinate validation: isValid=$isValidCoord (lat=$lat, lng=$lng)');
            
            if (!isValidCoord) {
              amapLog('AmapWebView', 'Invalid coordinate detected (outside China), trying IP location as fallback...');
              _locationPlugin?.stopLocation();
              _tryIpLocation();
              return;
            }
            
            _handleValidLocation(lat, lng, city, address, description);
          } else {
            amapLog('AmapWebView', 'Location result invalid: $result');
            if (mounted) {
              setState(() => _isLocating = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('定位结果无效，请重试')),
              );
            }
          }
          
          amapLog('AmapWebView', 'Stopping location...');
          _locationPlugin?.stopLocation();
          amapLog('AmapWebView', '===========================================');
        },
        onError: (error) {
          amapLog('AmapWebView', 'Location stream error: $error');
          if (mounted) {
            setState(() => _isLocating = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('定位失败: $error')),
            );
          }
        },
      );
      
      amapLog('AmapWebView', 'Starting location...');
      _locationPlugin?.startLocation();
      amapLog('AmapWebView', 'Location started, waiting for result...');
      
      amapLog('AmapWebView', 'Setting 15 second timeout...');
      await Future.delayed(const Duration(seconds: 15));
      if (_isLocating && mounted) {
        amapLog('AmapWebView', '========== Location timeout after 15 seconds ==========');
        _locationSubscription?.cancel();
        _locationPlugin?.stopLocation();
        setState(() => _isLocating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('定位超时，请检查定位服务是否开启')),
        );
      }
    } catch (e) {
      amapLog('AmapWebView', 'Location error: $e');
      if (mounted) {
        setState(() => _isLocating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('定位失败: $e')),
        );
      }
    }
    amapLog('AmapWebView', '=============================================');
  }

  Future<void> setCenter(double lat, double lng) async {
    await _controller?.runJavaScript('if(window.setCenter) window.setCenter($lng, $lat)');
  }

  Future<void> setMarker(double lat, double lng) async {
    await _controller?.runJavaScript('if(window.setMarker) window.setMarker($lng, $lat)');
  }

  Future<void> clearMarker() async {
    await _controller?.runJavaScript('if(window.clearMarker) window.clearMarker()');
  }

  @override
  Widget build(BuildContext context) {
    amapLog('AmapWebView', '>>> build() called');
    amapLog('AmapWebView', '>>> _controller == null: ${_controller == null}');
    amapLog('AmapWebView', '>>> _hasError: $_hasError');
    amapLog('AmapWebView', '>>> _isLoading: $_isLoading');
    amapLog('AmapWebView', '>>> _isMapReady: $_isMapReady');
    
    if (_controller == null) {
      amapLog('AmapWebView', '>>> Returning CircularProgressIndicator (controller is null)');
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      amapLog('AmapWebView', '>>> Returning error widget');
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
        WebViewWidget(
          controller: _controller!,
          gestureRecognizers: {
            Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()),
            Factory<HorizontalDragGestureRecognizer>(() => HorizontalDragGestureRecognizer()),
          },
        ),
        if (_isLocating)
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '正在定位...',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
