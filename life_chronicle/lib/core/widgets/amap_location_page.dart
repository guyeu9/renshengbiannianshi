import 'dart:convert';
import 'dart:io';

import 'package:amap_flutter/amap_flutter.dart' as amap;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AmapLocationPickResult {
  const AmapLocationPickResult({
    required this.poiName,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String poiName;
  final String address;
  final double? latitude;
  final double? longitude;
}

enum AmapLocationPageMode { pick, preview }

class AmapLocationPage extends StatefulWidget {
  const AmapLocationPage.pick({
    super.key,
    required this.initialPoiName,
    required this.initialAddress,
    required this.initialLatitude,
    required this.initialLongitude,
  })  : mode = AmapLocationPageMode.pick,
        title = null,
        poiName = '',
        address = '',
        latitude = null,
        longitude = null;

  const AmapLocationPage.preview({
    super.key,
    required this.title,
    required this.poiName,
    required this.address,
    required this.latitude,
    required this.longitude,
  })  : mode = AmapLocationPageMode.preview,
        initialPoiName = '',
        initialAddress = '',
        initialLatitude = null,
        initialLongitude = null;

  final AmapLocationPageMode mode;

  final String? title;
  final String poiName;
  final String address;
  final double? latitude;
  final double? longitude;

  final String initialPoiName;
  final String initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<AmapLocationPage> createState() => _AmapLocationPageState();
}

class _AmapPoi {
  const _AmapPoi({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
}

class _AmapLocationPageState extends State<AmapLocationPage> {
  static const String _amapAndroidKey = String.fromEnvironment('AMAP_ANDROID_KEY', defaultValue: 'a5a3e21e2d17ffa851374ed158a985a6');
  static const String _amapIosKey = String.fromEnvironment('AMAP_IOS_KEY', defaultValue: '');
  static const String _amapWebKey = String.fromEnvironment('AMAP_WEB_KEY', defaultValue: '76e66f23c7045fbe296f9aa9b7e7f12c');

  static const _primary = Color(0xFF2BCDEE);

  final _searchController = TextEditingController();
  final _poiNameController = TextEditingController();
  final _addressController = TextEditingController();

  var _loading = false;
  var _errorText = '';
  var _pois = <_AmapPoi>[];

  String get _pickedPoiName => _poiNameController.text.trim();
  String get _pickedAddress => _addressController.text.trim();

  double? _pickedLatitude;
  double? _pickedLongitude;

  amap.AMapController? _mapController;
  var _sdkReady = false;
  var _sdkErrorText = '';

  bool get _hasMapKey {
    if (kIsWeb) return _amapWebKey.trim().isNotEmpty;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _amapAndroidKey.trim().isNotEmpty;
      case TargetPlatform.iOS:
        return _amapIosKey.trim().isNotEmpty;
      default:
        return _amapAndroidKey.trim().isNotEmpty || _amapIosKey.trim().isNotEmpty;
    }
  }

  bool get _hasWebKey => _amapWebKey.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.mode == AmapLocationPageMode.preview) {
      _poiNameController.text = widget.poiName;
      _addressController.text = widget.address;
      _pickedLatitude = widget.latitude;
      _pickedLongitude = widget.longitude;
      _searchController.text = widget.poiName.trim().isNotEmpty ? widget.poiName.trim() : widget.address.trim();
    } else {
      _poiNameController.text = widget.initialPoiName;
      _addressController.text = widget.initialAddress;
      _pickedLatitude = widget.initialLatitude;
      _pickedLongitude = widget.initialLongitude;
      _searchController.text = widget.initialPoiName.trim().isNotEmpty ? widget.initialPoiName.trim() : widget.initialAddress.trim();
    }

    _initAmapSdk();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _poiNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _initAmapSdk() async {
    if (!_hasMapKey) return;
    try {
      await amap.AMapFlutter.init(
        apiKey: amap.ApiKey(
          iosKey: _amapIosKey,
          androidKey: _amapAndroidKey,
          webKey: _amapWebKey,
        ),
        agreePrivacy: true,
      );
      if (!mounted) return;
      setState(() {
        _sdkReady = true;
        _sdkErrorText = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sdkReady = false;
        _sdkErrorText = '$e';
      });
    }
  }

  void _syncMarkerAndCamera() {
    final controller = _mapController;
    if (controller == null) return;
    controller.removeMarker('picked');
    final lat = _pickedLatitude;
    final lng = _pickedLongitude;
    if (lat == null || lng == null) return;
    controller.addMarker(
      amap.Marker(
        id: 'picked',
        position: amap.Position(latitude: lat, longitude: lng),
      ),
    );
    controller.moveCamera(
      amap.CameraPosition(
        position: amap.Position(latitude: lat, longitude: lng),
        zoom: 15,
      ),
      const Duration(milliseconds: 220),
    );
  }

  Future<void> _searchPoi() async {
    if (!_hasWebKey) {
      setState(() {
        _errorText = '未配置高德 Web Key（AMAP_WEB_KEY）';
        _pois = [];
      });
      return;
    }
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      setState(() {
        _errorText = '请输入地点关键词';
        _pois = [];
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorText = '';
      _pois = [];
    });

    try {
      final uri = Uri.https('restapi.amap.com', '/v3/place/text', {
        'keywords': keyword,
        'offset': '20',
        'page': '1',
        'extensions': 'base',
        'key': _amapWebKey,
      });
      final client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close(force: true);

      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw const FormatException('invalid json');
      }
      final status = '${decoded['status'] ?? ''}'.trim();
      if (status != '1') {
        final info = '${decoded['info'] ?? '搜索失败'}';
        throw Exception(info);
      }
      final poisRaw = decoded['pois'];
      final next = <_AmapPoi>[];
      if (poisRaw is List) {
        for (final p in poisRaw) {
          if (p is! Map) continue;
          final name = '${p['name'] ?? ''}'.trim();
          final address = '${p['address'] ?? ''}'.trim();
          final location = '${p['location'] ?? ''}'.trim();
          double? lng;
          double? lat;
          if (location.contains(',')) {
            final parts = location.split(',');
            if (parts.length >= 2) {
              lng = double.tryParse(parts[0].trim());
              lat = double.tryParse(parts[1].trim());
            }
          }
          if (name.isEmpty && address.isEmpty) continue;
          next.add(_AmapPoi(name: name, address: address, latitude: lat, longitude: lng));
        }
      }

      if (!mounted) return;
      setState(() {
        _pois = next;
        if (next.isEmpty) _errorText = '未找到结果';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = '搜索失败：$e';
        _pois = [];
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _showManualEditSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _BottomSheetShell(
          title: '手动填写地点',
          actionText: '完成',
          onAction: () => Navigator.of(sheetContext).pop(),
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _poiNameController,
                  decoration: InputDecoration(
                    labelText: '地点名称',
                    hintText: '例如：海底捞（中关村店）',
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: '地址',
                    hintText: '例如：北京市海淀区…',
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _pickedLatitude = null;
                      _pickedLongitude = null;
                    });
                    Navigator.of(sheetContext).pop();
                  },
                  child: const Text('清除坐标'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openExternalNavigation() async {
    final lat = _pickedLatitude;
    final lng = _pickedLongitude;
    final name = Uri.encodeComponent(_pickedPoiName.isEmpty ? '目的地' : _pickedPoiName);
    final addr = Uri.encodeComponent(_pickedAddress);
    if (lat == null || lng == null) {
      final q = Uri.encodeComponent((_pickedPoiName.isNotEmpty ? _pickedPoiName : _pickedAddress).trim());
      final url = Uri.parse('https://uri.amap.com/search?keyword=$q');
      await _launchExternal(url);
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _BottomSheetShell(
          title: '选择导航方式',
          actionText: '关闭',
          onAction: () => Navigator.of(sheetContext).pop(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.map, color: Color(0xFF22BEBE)),
                title: const Text('高德地图', style: TextStyle(fontWeight: FontWeight.w800)),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final url = Uri.parse('https://uri.amap.com/marker?position=$lng,$lat&name=$name&src=life_chronicle');
                  await _launchExternal(url);
                },
              ),
              ListTile(
                leading: const Icon(Icons.public, color: Color(0xFF3B82F6)),
                title: const Text('百度地图', style: TextStyle(fontWeight: FontWeight.w800)),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final url = Uri.parse('https://api.map.baidu.com/marker?location=$lat,$lng&title=$name&content=$addr&output=html');
                  await _launchExternal(url);
                },
              ),
              ListTile(
                leading: const Icon(Icons.navigation, color: Color(0xFF10B981)),
                title: const Text('腾讯地图', style: TextStyle(fontWeight: FontWeight.w800)),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final url = Uri.parse('https://apis.map.qq.com/uri/v1/marker?marker=coord:$lat,$lng;title:$name;addr:$addr&referer=life_chronicle');
                  await _launchExternal(url);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchExternal(Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('无法打开外部地图应用')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPreview = widget.mode == AmapLocationPageMode.preview;
    final title = isPreview ? (widget.title ?? '地图预览') : '选择地点';

    final mapTargetLat = _pickedLatitude ?? 39.908722;
    final mapTargetLng = _pickedLongitude ?? 116.397499;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (isPreview)
            IconButton(
              onPressed: _openExternalNavigation,
              icon: const Icon(Icons.near_me),
            ),
          if (!isPreview)
            TextButton(
              onPressed: _showManualEditSheet,
              child: const Text('手动填写', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 220,
              color: Colors.white,
              child: !_hasMapKey
                  ? const Center(
                      child: Text('未配置高德 Key', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                    )
                  : (_sdkErrorText.isNotEmpty
                      ? Center(
                          child: Text(
                            _sdkErrorText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFEF4444)),
                          ),
                        )
                      : (!_sdkReady
                          ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                          : amap.AMapFlutter(
                              initCameraPosition: amap.CameraPosition(
                                position: amap.Position(latitude: mapTargetLat, longitude: mapTargetLng),
                                zoom: 15,
                              ),
                              onMapCreated: (controller) {
                                _mapController = controller;
                                _syncMarkerAndCamera();
                              },
                              onPoiClick: isPreview
                                  ? null
                                  : (poi) {
                                      setState(() {
                                        _poiNameController.text = poi.name;
                                        _pickedLatitude = poi.position.latitude;
                                        _pickedLongitude = poi.position.longitude;
                                      });
                                      _syncMarkerAndCamera();
                                    },
                              onMapLongPress: isPreview
                                  ? null
                                  : (position) {
                                      setState(() {
                                        _pickedLatitude = position.latitude;
                                        _pickedLongitude = position.longitude;
                                      });
                                      _syncMarkerAndCamera();
                                    },
                            ))),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_pickedPoiName.isEmpty ? '未选择地点' : _pickedPoiName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(_pickedAddress.isEmpty ? '未填写地址' : _pickedAddress,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFFF1F5F9))),
                      child: Text(
                        (_pickedLatitude == null || _pickedLongitude == null) ? '无坐标' : '$_pickedLatitude, $_pickedLongitude',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                      ),
                    ),
                    const Spacer(),
                    if (isPreview)
                      TextButton(
                        onPressed: _openExternalNavigation,
                        child: const Text('外部导航', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (!isPreview) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchPoi(),
                    decoration: InputDecoration(
                      hintText: '搜索地点名称/地址',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: const Color(0xFF102222),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  onPressed: _loading ? null : _searchPoi,
                  child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('搜索'),
                ),
              ],
            ),
            if (_errorText.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(_errorText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFEF4444))),
            ],
            const SizedBox(height: 12),
            if (!_hasWebKey)
              const Text('可通过 AMAP_WEB_KEY 启用地点搜索', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
            if (_hasWebKey && _pois.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pois.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final p = _pois[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      setState(() {
                        _poiNameController.text = p.name;
                        _addressController.text = p.address;
                        _pickedLatitude = p.latitude;
                        _pickedLongitude = p.longitude;
                      });
                      _syncMarkerAndCamera();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name.isEmpty ? '未命名地点' : p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text(p.address.isEmpty ? '无地址' : p.address,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ],
      ),
      bottomNavigationBar: widget.mode == AmapLocationPageMode.pick
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: const Color(0xFF102222),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(
                      AmapLocationPickResult(
                        poiName: _pickedPoiName,
                        address: _pickedAddress,
                        latitude: _pickedLatitude,
                        longitude: _pickedLongitude,
                      ),
                    );
                  },
                  child: const Text('使用此地点'),
                ),
              ),
            )
          : null,
    );
  }
}

class _BottomSheetShell extends StatelessWidget {
  const _BottomSheetShell({
    required this.title,
    required this.actionText,
    required this.onAction,
    required this.child,
  });

  final String title;
  final String actionText;
  final VoidCallback onAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900))),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2BCDEE),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    child: Text(actionText),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            child,
          ],
        ),
      ),
    );
  }
}

