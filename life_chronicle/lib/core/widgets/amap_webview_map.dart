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
    final initStartTime = DateTime.now();
    amapInfo('AmapWebView', '========== [STEP-1] Initializing WebView ==========');
    amapInfo('AmapWebView', 'Platform: ${Platform.operatingSystem}');
    amapDebug('AmapWebView', 'webKey (masked): ${maskApiKey(widget.webKey)}');
    amapDebug('AmapWebView', 'securityCode configured: ${widget.securityCode.isNotEmpty}');
    amapDebug('AmapWebView', 'initialLatitude: ${widget.initialLatitude}');
    amapDebug('AmapWebView', 'initialLongitude: ${widget.initialLongitude}');
    amapDebug('AmapWebView', 'autoLocate: ${widget.autoLocate}');
    amapDebug('AmapWebView', 'isPreviewMode: ${widget.isPreviewMode}');
    
    final htmlContent = _buildMapHtml();
    final htmlSize = htmlContent.length;
    amapInfo('AmapWebView', '[STEP-2] HTML content generated: size=$htmlSize bytes');
    amapDebug('AmapWebView', 'HTML preview (first 300 chars): ${htmlContent.substring(0, htmlSize > 300 ? 300 : htmlSize)}...');
    
    final controllerStartTime = DateTime.now();
    amapInfo('AmapWebView', '[STEP-3] Creating WebViewController...');
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            final now = DateTime.now();
            final elapsed = now.difference(initStartTime).inMilliseconds;
            amapInfo('AmapWebView', '[EVENT] onPageStarted: url=$url, elapsed=${elapsed}ms');
          },
          onPageFinished: (String url) {
            final now = DateTime.now();
            final elapsed = now.difference(initStartTime).inMilliseconds;
            amapInfo('AmapWebView', '[EVENT] onPageFinished: url=$url, elapsed=${elapsed}ms');
            amapDebug('AmapWebView', 'Setting _isLoading = false');
            setState(() => _isLoading = false);
            amapPerf('AmapWebView', 'WebView page load', elapsed);
          },
          onWebResourceError: (WebResourceError error) {
            final now = DateTime.now();
            final elapsed = now.difference(initStartTime).inMilliseconds;
            amapError('AmapWebView', '[ERROR] onWebResourceError: ${error.description}');
            amapError('AmapWebView', '[ERROR] errorCode=${error.errorCode}, errorType=${error.errorType}, url=${error.url}, elapsed=${elapsed}ms');
            setState(() {
              _hasError = true;
              _errorMessage = '资源加载失败 (${error.errorCode}): ${error.description}';
              _isLoading = false;
            });
            widget.onError?.call(_errorMessage);
          },
          onNavigationRequest: (NavigationRequest request) {
            amapDebug('AmapWebView', '[NAV] onNavigationRequest: ${request.url}');
            return NavigationDecision.navigate;
          },
          onHttpError: (error) {
            amapWarn('AmapWebView', '[WARN] onHttpError: statusCode=${error.response?.statusCode}');
          },
          onUrlChange: (change) {
            amapDebug('AmapWebView', '[EVENT] onUrlChange: ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'AMapFlutter',
        onMessageReceived: (message) {
          amapDebug('AmapWebView', '[JS->Flutter] AMapFlutter: ${message.message}');
          _handleJsMessage(message);
        },
      )
      ..addJavaScriptChannel(
        'ConsoleLog',
        onMessageReceived: (message) {
          amapDebug('WebViewConsole', message.message);
        },
      );

    final controllerCreateTime = DateTime.now();
    final controllerElapsed = controllerCreateTime.difference(controllerStartTime).inMilliseconds;
    amapInfo('AmapWebView', '[STEP-4] WebViewController created: elapsed=${controllerElapsed}ms');

    amapInfo('AmapWebView', '[STEP-5] Loading HTML content...');
    final loadStartTime = DateTime.now();
    if (Platform.isAndroid) {
      amapDebug('AmapWebView', 'Android platform, using baseUrl: https://webapi.amap.com/');
      _controller!.loadHtmlString(htmlContent, baseUrl: 'https://webapi.amap.com/');
    } else {
      amapDebug('AmapWebView', 'iOS platform, no baseUrl');
      _controller!.loadHtmlString(htmlContent);
    }
    final loadElapsed = DateTime.now().difference(loadStartTime).inMilliseconds;
    amapInfo('AmapWebView', '[STEP-6] loadHtmlString called: elapsed=${loadElapsed}ms');

    setState(() {});
    final totalElapsed = DateTime.now().difference(initStartTime).inMilliseconds;
    amapInfo('AmapWebView', '[DONE] WebView initialization complete: total=${totalElapsed}ms');
    amapDebug('AmapWebView', '_controller is null: ${_controller == null}');
    amapPerf('AmapWebView', 'WebView init total', totalElapsed, sizeBytes: htmlSize);
    amapInfo('AmapWebView', '========================================');
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
      var initStartTime = Date.now();
      var scriptLoadTime = null;
      
      function log(msg) {
        try { ConsoleLog.postMessage('[AMap] ' + msg); } catch(e) {}
      }
      
      function logPerf(operation, startTime) {
        var elapsed = Date.now() - startTime;
        log('[PERF] ' + operation + ': elapsed=' + elapsed + 'ms');
      }
      
      function showError(msg) {
        log('[ERROR] ' + msg);
        statusEl.className = 'status error';
        statusEl.innerHTML = '<svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/></svg><div>' + msg + '</div>';
        try { AMapFlutter.postMessage(JSON.stringify({type: 'error', message: msg})); } catch(e) {}
      }
      
      function showLoading(msg) {
        statusEl.className = 'status loading';
        statusEl.innerHTML = '<svg viewBox="0 0 24 24"><path d="M12 4V1L8 5l4 4V6c3.31 0 6 2.69 6 6 0 1.01-.25 1.97-.7 2.8l1.46 1.46C19.54 15.03 20 13.57 20 12c0-4.42-3.58-8-8-8zm0 14c-3.31 0-6-2.69-6-6 0-1.01.25-1.97.7-2.8L5.24 7.74C4.46 8.97 4 10.43 4 12c0 4.42 3.58 8 8 8v3l4-4-4-4v3z"/></svg><div>' + msg + '</div>';
      }
      
      function getContainerSize() {
        var container = document.getElementById('container');
        if (container) {
          return { width: container.offsetWidth, height: container.offsetHeight };
        }
        return { width: 0, height: 0 };
      }
      
      if (locationBtn) {
        locationBtn.onclick = function() {
          log('[UI] Location button clicked');
          try { AMapFlutter.postMessage(JSON.stringify({type: 'locateRequest'})); } catch(e) {}
        };
      }
      
      window.onerror = function(msg, url, line, col, error) {
        log('[JS-ERROR] ' + msg + ' @ ' + url + ':' + line + ':' + col);
        showError('脚本错误: ' + msg);
        return true;
      };
      
      window.initAMap = function() {
        var callbackTime = Date.now();
        log('[STEP-1] initAMap callback fired, elapsed=' + (callbackTime - initStartTime) + 'ms');
        log('[STEP-2] typeof AMap: ' + typeof AMap);
        
        if (typeof AMap === 'undefined') {
          log('[ERROR] AMap is undefined!');
          showError('地图 API 未定义');
          return;
        }
        
        log('[STEP-3] AMap is defined, creating map...');
        try {
          var containerSize = getContainerSize();
          log('[DEBUG] Container size: ' + containerSize.width + 'x' + containerSize.height);
          
          if (containerSize.width === 0 || containerSize.height === 0) {
            log('[ERROR] Container size is ZERO! This will cause blank map!');
            showError('地图容器尺寸为 0');
            return;
          }
          
          statusEl.style.display = 'none';
          if (centerMarker) centerMarker.style.display = 'block';
          
          var mapCreateTime = Date.now();
          log('[STEP-4] Creating AMap.Map with zoom=$initialZoom, center=[$initialLng, $initialLat]');
          map = new AMap.Map('container', {
            zoom: $initialZoom,
            center: [$initialLng, $initialLat],
            resizeEnable: true
          });
          log('[STEP-5] Map instance created: ' + (map ? 'yes' : 'no') + ', elapsed=' + (Date.now() - mapCreateTime) + 'ms');
          
          if (!map) {
            log('[ERROR] Map instance is null!');
            showError('地图实例创建失败');
            return;
          }
          
          ${hasMarker ? '''
          log('[STEP-6] Creating marker at [$markerLng, $markerLat]');
          marker = new AMap.Marker({
            position: [$markerLng, $markerLat],
            map: map
          });
          map.setCenter([$markerLng, $markerLat]);
          log('[STEP-7] Marker created and center set');
          ''' : ''}
          
          map.on('complete', function() {
            var completeTime = Date.now();
            var totalElapsed = completeTime - initStartTime;
            log('[EVENT] Map complete event fired, total=' + totalElapsed + 'ms');
            try { 
              var msg = JSON.stringify({type: 'mapReady'});
              log('[MSG] Sending mapReady message: ' + msg);
              AMapFlutter.postMessage(msg);
              log('[MSG] mapReady message sent successfully');
            } catch(e) {
              log('[ERROR] mapReady postMessage FAILED: ' + e.message);
            }
            logPerf('Map total init', initStartTime);
          });
          
          map.on('tilesloadstart', function() {
            log('[TILE] Tiles load STARTED - network is working');
          });
          
          map.on('tilesloadend', function() {
            log('[TILE] Tiles load ENDED - tiles rendered successfully');
          });
          
          map.on('error', function(e) {
            log('[ERROR] Map error event: ' + JSON.stringify(e));
            if (e && e.message) {
              showError('地图错误: ' + e.message);
            }
          });
          
          map.on('tileerror', function(e) {
            log('[ERROR] Tile error: ' + JSON.stringify(e));
            if (e && e.tile) {
              log('[ERROR] Failed tile URL: ' + e.tile.src);
            }
          });
          
          ${!isPreviewMode ? '''
          map.on('click', function(e) {
            log('[EVENT] Map clicked: lng=' + e.lnglat.getLng() + ', lat=' + e.lnglat.getLat());
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
                log('[EVENT] Map moveend: lng=' + c.getLng() + ', lat=' + c.getLat());
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
              log('[EVENT] POI clicked: name=' + poi.name);
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
          log('[ERROR] Map init failed: ' + e.message);
          showError('地图初始化失败: ' + e.message);
        }
      };
      
      window.setCenter = function(lng, lat) {
        log('[API] setCenter called: lng=' + lng + ', lat=' + lat);
        if (map) map.setCenter([lng, lat]);
      };
      
      window.setMarker = function(lng, lat) {
        log('[API] setMarker called: lng=' + lng + ', lat=' + lat);
        if (marker) {
          marker.setPosition([lng, lat]);
        } else if (map) {
          marker = new AMap.Marker({ position: [lng, lat], map: map });
        }
      };
      
      window.clearMarker = function() {
        log('[API] clearMarker called');
        if (marker) { marker.setMap(null); marker = null; }
      };
      
      log('========== [JS-INIT] Starting AMap JS API v2.0 ==========');
      log('[CONFIG] Key: ${webKey.substring(0, 4)}****${webKey.length > 8 ? webKey.substring(webKey.length - 4) : ""}');
      log('[CONFIG] Security Code: ${securityCode.isNotEmpty ? "已配置" : "未配置"}');
      log('[CONFIG] Initial position: lat=$initialLat, lng=$initialLng, zoom=$initialZoom');
      log('[CONFIG] isPreviewMode: $isPreviewMode, hasMarker: $hasMarker');
      
      var containerSize = getContainerSize();
      log('[DOM] Container size: ' + containerSize.width + 'x' + containerSize.height);
      
      window._AMapSecurityConfig = {
        securityJsCode: '$securityCode',
      };
      log('[SECURITY] Security config set');
      
      var script = document.createElement('script');
      var scriptUrl = 'https://webapi.amap.com/maps?v=2.0&key=$webKey&callback=initAMap';
      log('[SCRIPT] Creating script tag: ' + scriptUrl);
      script.src = scriptUrl;
      script.async = true;
      scriptLoadTime = Date.now();
      script.onload = function() {
        var elapsed = Date.now() - scriptLoadTime;
        log('[SCRIPT] onload fired, script loaded in ' + elapsed + 'ms');
      };
      script.onerror = function(e) {
        var elapsed = Date.now() - scriptLoadTime;
        log('[ERROR] Script onerror fired after ' + elapsed + 'ms');
        log('[ERROR] Error details: ' + (e ? JSON.stringify(e) : 'unknown'));
        showError('地图脚本加载失败，请检查网络连接或 API Key 配置');
      };
      log('[SCRIPT] Appending script to document.head');
      document.head.appendChild(script);
      log('[SCRIPT] Script appended, waiting for initAMap callback...');
      
      setTimeout(function() {
        if (typeof AMap === 'undefined') {
          log('[ERROR] AMap still undefined after 10 seconds - possible causes:');
          log('[ERROR] 1. Network blocked or slow');
          log('[ERROR] 2. Invalid API Key');
          log('[ERROR] 3. Security code mismatch');
          log('[ERROR] 4. Domain not whitelisted');
          showError('地图 API 加载超时，请检查网络或 API Key 配置');
        }
      }, 10000);
      
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

  Future<void> _tryIpLocation(DateTime locateStartTime) async {
    amapInfo('AmapWebView', '========== [IP-LOCATE-1] Trying IP-based location ==========');
    
    try {
      final uri = Uri.https('restapi.amap.com', '/v3/ip', {
        'key': _amapWebKey,
      });
      amapDebug('AmapWebView', '[IP-LOCATE-2] Request URL: $uri');
      
      final client = HttpClient();
      final requestStartTime = DateTime.now();
      final request = await client.getUrl(uri);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close(force: true);
      
      final requestElapsed = DateTime.now().difference(requestStartTime).inMilliseconds;
      amapInfo('AmapWebView', '[IP-LOCATE-3] Response received: statusCode=${response.statusCode}, elapsed=${requestElapsed}ms, size=${body.length} bytes');
      amapDebug('AmapWebView', '[IP-LOCATE] Response body: $body');
      
      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw Exception('Invalid response type: ${decoded.runtimeType}');
      }
      
      final status = '${decoded['status'] ?? ''}'.trim();
      final info = '${decoded['info'] ?? ''}'.trim();
      amapDebug('AmapWebView', '[IP-LOCATE] API status=$status, info=$info');
      
      if (status != '1') {
        throw Exception('API returned status=$status, info=$info');
      }
      
      final rectangle = '${decoded['rectangle'] ?? ''}'.trim();
      if (rectangle.isEmpty) {
        throw Exception('No rectangle in response');
      }
      amapDebug('AmapWebView', '[IP-LOCATE-4] Rectangle: $rectangle');
      
      final parts = rectangle.split(';');
      if (parts.length < 2) {
        throw Exception('Invalid rectangle format: expected 2 parts, got ${parts.length}');
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
      
      amapInfo('AmapWebView', '[IP-LOCATE-5] Calculated center: lat=$centerLat, lng=$centerLng');
      
      if (!_isValidChinaCoordinate(centerLat, centerLng)) {
        throw Exception('IP location outside China: lat=$centerLat, lng=$centerLng');
      }
      
      final province = '${decoded['province'] ?? ''}'.trim();
      final city = '${decoded['city'] ?? ''}'.trim();
      final adcode = '${decoded['adcode'] ?? ''}'.trim();
      
      amapDebug('AmapWebView', '[IP-LOCATE-6] province=$province, city=$city, adcode=$adcode');
      
      String address = '';
      if (province.isNotEmpty) address += province;
      if (city.isNotEmpty) address += city;
      
      String description = city.isNotEmpty ? city : province;
      
      final totalElapsed = DateTime.now().difference(locateStartTime).inMilliseconds;
      amapPerf('AmapWebView', 'IP Location total', totalElapsed);
      
      if (mounted) {
        _handleValidLocation(centerLat, centerLng, city, address, description);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已使用网络定位：${city.isNotEmpty ? city : province}')),
        );
      }
      amapInfo('AmapWebView', '[IP-LOCATE] Success: city=$city, province=$province');
    } catch (e) {
      amapError('AmapWebView', '[IP-LOCATE-ERROR] Failed: $e');
      if (mounted) {
        setState(() => _isLocating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('定位失败，请检查设备定位服务或稍后重试')),
        );
      }
    }
    amapInfo('AmapWebView', '===========================================');
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
    final locateStartTime = DateTime.now();
    amapInfo('AmapWebView', '========== [LOCATE-1] Handling location request ==========');
    
    if (_isLocating) {
      amapWarn('AmapWebView', '[LOCATE] Already locating, skip');
      return;
    }

    amapDebug('AmapWebView', '[LOCATE-2] Cancelling existing subscription...');
    _locationSubscription?.cancel();
    _locationSubscription = null;

    amapDebug('AmapWebView', '[LOCATE-3] Reinitializing location plugin...');
    _locationPlugin?.destroy();
    _initLocationPlugin();
    
    if (!_locationPermissionGranted) {
      amapInfo('AmapWebView', '[LOCATE-4] Permission not granted, requesting...');
      await _requestLocationPermission();
      if (!_locationPermissionGranted) {
        amapWarn('AmapWebView', '[LOCATE] Location permission still not granted');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('定位权限未授权，请在设置中开启')),
          );
        }
        return;
      }
    }

    amapInfo('AmapWebView', '[LOCATE-5] Starting location, permission granted=$_locationPermissionGranted');
    setState(() => _isLocating = true);
    
    try {
      amapDebug('AmapWebView', '[LOCATE-6] Setting up location listener...');
      _locationSubscription = _locationPlugin?.onLocationChanged().listen(
        (result) {
          final resultTime = DateTime.now();
          final elapsed = resultTime.difference(locateStartTime).inMilliseconds;
          amapInfo('AmapWebView', '[LOCATE-7] Location result received, elapsed=${elapsed}ms');
          amapDebug('AmapWebView', '[LOCATE] Result keys: ${result.keys.toList()}');
          
          final lat = result['latitude'] as double?;
          final lng = result['longitude'] as double?;
          final accuracy = result['accuracy'] as double?;
          var city = (result['city'] as String?) ?? '';
          var province = (result['province'] as String?) ?? '';
          var district = (result['district'] as String?) ?? '';
          var street = (result['street'] as String?) ?? '';
          var address = (result['address'] as String?) ?? '';
          var description = (result['description'] as String?) ?? '';
          
          amapInfo('AmapWebView', '[LOCATE] lat=$lat, lng=$lng, accuracy=$accuracy');
          amapDebug('AmapWebView', '[LOCATE] province=$province, city=$city, district=$district, street=$street');
          amapDebug('AmapWebView', '[LOCATE] address=$address, description=$description');
          
          _locationSubscription?.cancel();
          
          final errorCode = result['errorCode'];
          if (errorCode != null && errorCode != 0) {
            final errorInfo = result['errorInfo'] ?? '定位失败';
            amapError('AmapWebView', '[LOCATE-ERROR] errorCode=$errorCode, errorInfo=$errorInfo');
            if (mounted) {
              setState(() => _isLocating = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('定位失败: $errorInfo')),
              );
            }
            return;
          }
          
          if (lat != null && lng != null && mounted) {
            final isValidCoord = _isValidChinaCoordinate(lat, lng);
            amapInfo('AmapWebView', '[LOCATE-8] Coordinate validation: isValid=$isValidCoord');
            
            if (!isValidCoord) {
              amapWarn('AmapWebView', '[LOCATE] Invalid coordinate (outside China), trying IP location...');
              _locationPlugin?.stopLocation();
              _tryIpLocation(locateStartTime);
              return;
            }
            
            amapPerf('AmapWebView', 'Location total', elapsed);
            _handleValidLocation(lat, lng, city, address, description);
          } else {
            amapError('AmapWebView', '[LOCATE-ERROR] Invalid result: lat=$lat, lng=$lng');
            if (mounted) {
              setState(() => _isLocating = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('定位结果无效，请重试')),
              );
            }
          }
          
          amapDebug('AmapWebView', '[LOCATE-9] Stopping location...');
          _locationPlugin?.stopLocation();
          amapInfo('AmapWebView', '===========================================');
        },
        onError: (error) {
          amapError('AmapWebView', '[LOCATE-ERROR] Stream error: $error');
          if (mounted) {
            setState(() => _isLocating = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('定位失败: $error')),
            );
          }
        },
      );
      
      amapInfo('AmapWebView', '[LOCATE-10] Starting location...');
      _locationPlugin?.startLocation();
      amapDebug('AmapWebView', '[LOCATE] Location started, waiting for result...');
      
      amapDebug('AmapWebView', '[LOCATE-11] Setting 15 second timeout...');
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
