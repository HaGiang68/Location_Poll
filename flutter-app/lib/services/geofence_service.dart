import 'package:flutter/cupertino.dart';
import 'package:flutter_geofence/geofence.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class GeofenceService {
  GeofenceService() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: null);
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    Geofence.initialize();
    Geofence.startListening(GeolocationEvent.entry, (entry) {
      scheduleNotification(
          "Eine neue Poll für dich", "Nimm jetzt an: ${entry.id} teil");
    });
    Geofence.startListeningForLocationChanges();
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void scheduleNotification(String title, String subtitle) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, subtitle, platformChannelSpecifics, payload: '');
  }

  void addGeofenceEntry(Geolocation geoloc) {
    Geofence.addGeolocation(geoloc, GeolocationEvent.entry).then((onValue) {
      debugPrint("great success");
    }).catchError((onError) {
      debugPrint("failure");
    });
  }

  void getCurrentLocation() {
    Geofence.getCurrentLocation().then((coordinate) {
      print(
          "Your latitude is ${coordinate?.latitude} and longitude ${coordinate?.longitude}");
      // scheduleNotification("Current Location","Your latitude is ${coordinate?.latitude} and longitude ${coordinate?.longitude}");
    });
  }

  // should be called after voting
  void deleteGeofence(Geolocation geoloc) {
    Geofence.removeGeolocation(geoloc, GeolocationEvent.entry);
  }
}
