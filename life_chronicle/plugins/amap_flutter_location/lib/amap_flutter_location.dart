import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'amap_location_option.dart';

class AMapFlutterLocation {
  static const String _CHANNEL_METHOD_LOCATION = "amap_flutter_location";
  static const String _CHANNEL_STREAM_LOCATION = "amap_flutter_location_stream";

  static const MethodChannel _methodChannel =
      MethodChannel(_CHANNEL_METHOD_LOCATION);

  static const EventChannel _eventChannel =
      EventChannel(_CHANNEL_STREAM_LOCATION);

  StreamController<Map<String, Object>>? _receiveStream;
  StreamSubscription<dynamic>? _subscription;
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
    _methodChannel.invokeMethod('destroy', {'pluginKey': _pluginKey});
    _subscription?.cancel();
    _subscription = null;
    _receiveStream?.close();
    _receiveStream = null;
  }

  Stream<Map<String, Object>> onLocationChanged() {
    _subscription?.cancel();
    _receiveStream?.close();

    _receiveStream = StreamController<Map<String, Object>>.broadcast();

    _subscription = _eventChannel
        .receiveBroadcastStream()
        .map<Map<String, Object>>((element) {
          if (element is Map) {
            return Map<String, Object>.from(element);
          }
          return <String, Object>{};
        })
        .listen(
          (Map<String, Object> event) {
            if (event['pluginKey'] == _pluginKey) {
              Map<String, Object> newEvent = Map<String, Object>.of(event);
              newEvent.remove('pluginKey');
              _receiveStream?.add(newEvent);
            }
          },
          onError: (error) {
            _receiveStream?.addError(error);
          },
          onDone: () {
            _receiveStream?.close();
          },
        );

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
