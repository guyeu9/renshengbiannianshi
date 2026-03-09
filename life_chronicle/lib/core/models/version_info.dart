class VersionInfo {
  final String latestVersion;
  final int buildNumber;
  final Map<String, String> downloadUrl;
  final List<String> changelog;
  final bool forceUpdate;
  final String minCompatibleVersion;
  final String releaseDate;

  VersionInfo({
    required this.latestVersion,
    required this.buildNumber,
    required this.downloadUrl,
    required this.changelog,
    required this.forceUpdate,
    required this.minCompatibleVersion,
    required this.releaseDate,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      latestVersion: json['latestVersion'] as String,
      buildNumber: json['buildNumber'] as int,
      downloadUrl: Map<String, String>.from(json['downloadUrl']),
      changelog: List<String>.from(json['changelog']),
      forceUpdate: json['forceUpdate'] as bool,
      minCompatibleVersion: json['minCompatibleVersion'] as String,
      releaseDate: json['releaseDate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latestVersion': latestVersion,
      'buildNumber': buildNumber,
      'downloadUrl': downloadUrl,
      'changelog': changelog,
      'forceUpdate': forceUpdate,
      'minCompatibleVersion': minCompatibleVersion,
      'releaseDate': releaseDate,
    };
  }
}
