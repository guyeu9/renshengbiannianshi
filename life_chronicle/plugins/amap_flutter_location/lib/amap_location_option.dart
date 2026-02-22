class AMapLocationOption {
  bool needAddress = true;

  GeoLanguage geoLanguage;

  bool onceLocation = false;

  AMapLocationMode locationMode;

  int locationInterval = 2000;

  bool pausesLocationUpdatesAutomatically = false;

  DesiredAccuracy desiredAccuracy = DesiredAccuracy.Best;

  double distanceFilter = -1;

  AMapLocationAccuracyAuthorizationMode
      desiredLocationAccuracyAuthorizationMode =
      AMapLocationAccuracyAuthorizationMode.FullAccuracy;

  String fullAccuracyPurposeKey = "";

  AMapLocationOption(
      {this.locationInterval = 2000,
      this.needAddress = true,
      this.locationMode = AMapLocationMode.Hight_Accuracy,
      this.geoLanguage = GeoLanguage.DEFAULT,
      this.onceLocation = false,
      this.pausesLocationUpdatesAutomatically = false,
      this.desiredAccuracy = DesiredAccuracy.Best,
      this.distanceFilter = -1,
      this.desiredLocationAccuracyAuthorizationMode =
          AMapLocationAccuracyAuthorizationMode.FullAccuracy});

  Map getOptionsMap() {
    return {
      "locationInterval": this.locationInterval,
      "needAddress": needAddress,
      "locationMode": locationMode.index,
      "geoLanguage": geoLanguage.index,
      "onceLocation": onceLocation,
      "pausesLocationUpdatesAutomatically": pausesLocationUpdatesAutomatically,
      "desiredAccuracy": desiredAccuracy.index,
      'distanceFilter': distanceFilter,
      "locationAccuracyAuthorizationMode":
          desiredLocationAccuracyAuthorizationMode.index,
      "fullAccuracyPurposeKey": fullAccuracyPurposeKey
    };
  }
}

enum AMapLocationMode {
  Battery_Saving,
  Device_Sensors,
  Hight_Accuracy
}

enum GeoLanguage {
  DEFAULT,
  ZH,
  EN
}

enum DesiredAccuracy {
  Best,
  BestForNavigation,
  NearestTenMeters,
  HundredMeters,
  Kilometer,
  ThreeKilometers,
}

enum AMapLocationAccuracyAuthorizationMode {
  FullAndReduceAccuracy,
  FullAccuracy,
  ReduceAccuracy
}

enum AMapAccuracyAuthorization {
  AMapAccuracyAuthorizationFullAccuracy,
  AMapAccuracyAuthorizationReducedAccuracy,
  AMapAccuracyAuthorizationInvalid
}
