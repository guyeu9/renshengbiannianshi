import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'amap_location_option.dart';

class AMapFlutterLocation {
  static const String _CHANNEL_METHOD_LOCATION = "amap_flutter_location";
  static const String _CHANNEL_STREAM_LOCATION = "amap_flutter_location_stream";

  static const MethodChannel _methodChannel =
      const MethodChannel(_CHANNEL_METHOD_LOCATION);

  static const EventChannel _eventChannel =
      const EventChannel(_CHANNEL_STREAM_LOCATION);

  static Stream<Map<String, Object>> _onLocationChanged = _eventChannel
      .receiveBroadcastStream()
      .asBroadcastStream()
      .map<Map<String, Object>>((element) => element.cast<String, Object>());

  StreamController<Map<String, Object>>? _receiveStream;
  StreamSubscription<Map<String, Object>>? _subscription;
  String? _pluginKey;

  Future<AMapAccuracyAuthorization> getSystemAccuracyAuthorization() async {
    int result = -1;
    if (Platform.isIOS) {
      result = await _methodChannel.invokeMethod(
          "getSystemAccuracyAuthorization", {'pluginKey': _pluginKey});
    }
    if (result == 0) {
      return AMapAccuracyAuthorization.AMapAccuracyAuthorizationFullAccuracy;
    } else if (result == 1) {
      return AMapAccuracyAuthorization.AMapAccuracyAuthorizationReducedAccuracy;
    }
    return AMapAccuracyAuthorization.AMapAccuracyAuthorizationInvalid;
  }

  AMapFlutterLocation() {
    _pluginKey = DateTime.now().millisecondsSinceEpoch.toString();
  }

  void startLocation() {
    _methodChannel.invokeMethod('startLocation', {'pluginKey': _pluginKey});
    return;
  }

  void stopLocation() {
    _methodChannel.invokeMethod('stopLocation', {'pluginKey': _pluginKey});
    return;
  }

  static void setApiKey(String androidKey, String iosKey) {
    _methodChannel
        .invokeMethod('setApiKey', {'android': androidKey, 'ios': iosKey});
  }

  void setLocationOption(AMapLocationOption locationOption) {
    Map option = locationOption.getOptionsMap();
    option['pluginKey'] = _pluginKey;
    _methodChannel.invokeMethod('setLocationOption', option);
  }

  void destroy() {
    _methodChannel.invokeListMethod('destroy', {'pluginKey': _pluginKey});
    if (_subscription != null) {
      _receiveStream?.close();
      _subscription?.cancel();
      _receiveStream = null;
      _subscription = null;
    }
  }

  Stream<Map<String, Object>> onLocationChanged() {
    if (_receiveStream == null) {
      _receiveStream = StreamController();
      _subscription = _onLocationChanged.listen((Map<String, Object> event) {
        if (event['pluginKey'] == _pluginKey) {
          Map<String, Object> newEvent = Map<String, Object>.of(event);
          newEvent.remove('pluginKey');
          _receiveStream?.add(newEvent);
        }
      });
    }
    return _receiveStream!.stream;
  }

  static void updatePrivacyShow(bool hasContains, bool hasShow) {
    _methodChannel
        .invokeMethod('updatePrivacyStatement', {'hasContains': hasContains, 'hasShow': hasShow});
  }

  static void updatePrivacyAgree(bool hasAgree) {
    _methodChannel
        .invokeMethod('updatePrivacyStatement', {'hasAgree': hasAgree});
  }
}
