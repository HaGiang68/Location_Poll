import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:location_poll/features/auth/auth_module.dart';
import 'package:location_poll/features/home/home_module.dart';
import 'package:location_poll/features/poll/poll_module.dart';
import 'package:location_poll/features/poll/overview/bloc/polls_page_cubit.dart';
import 'package:location_poll/features/result/result_module.dart';
import 'package:location_poll/services/anonymity_layer_service.dart';
import 'package:location_poll/services/auth_service.dart';
import 'package:location_poll/services/firebase/firebase_anonymity_layer.dart';
import 'package:location_poll/services/firebase/firebase_poll_service.dart';
import 'package:location_poll/services/firebase/functions/firebase_function_service.dart';
import 'package:location_poll/services/geofence_service.dart';
import 'package:location_poll/services/location_service.dart';
import 'package:location_poll/services/poll_service.dart';
import 'package:location_poll/services/sq_lite/sq_lite_storage_service.dart';
import 'package:location_poll/services/storage_service.dart';
import 'package:sqflite/sqflite.dart';

import 'features/maps/map_module.dart';
import 'features/setting/setting_module.dart';

class AppModule extends Module {
  AppModule({
    required this.database,
  });

  final Database database;

  @override
  List<Bind> get binds => [
        Bind.singleton(
          (i) => AuthService(),
        ),
        Bind.singleton(
          (i) => GeofenceService(),
        ),
        Bind.singleton(
          (i) => SQLiteStorageService(
            database: database,
          ),
        ),
        Bind.singleton((i) => GeofenceService()),
        Bind.singleton((i) => FirebaseFunctionsService()),
        Bind.singleton(
          (i) => FirebaseAnonymityLayer(
            firebaseFunctionsService: i.get<FirebaseFunctionsService>(),
            storageService: i.get<StorageService>(),
          ),
        ),
        Bind.singleton(
          (i) => FirebasePollService(
            firestore: FirebaseFirestore.instance,
            anonymityLayerService: i.get<AnonymityLayerService>(),
            firebaseFunctionsService: i.get<FirebaseFunctionsService>(),
          ),
        ),
        Bind.singleton(
          (i) => PollsPageCubit(
              pollService: i.get<PollService>(),
              geofenceService: i.get<GeofenceService>()),
        ),
        Bind.singleton(
          (i) => LocationService(),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        ModuleRoute(
          '/',
          //AuthModule.routeName,
          module: AuthModule(),
        ),
        ModuleRoute(
          AuthModule.routeName,
          module: AuthModule(),
        ),
        ModuleRoute(
          HomeModule.routeName,
          module: HomeModule(),
        ),
        ModuleRoute(
          PollModule.routeName,
          module: PollModule(),
        ),
        ModuleRoute(
          ResultModule.routeName,
          module: ResultModule(),
        ),
        ModuleRoute(
          MapsModule.routeName,
          module: MapsModule(),
        ),
        ModuleRoute(
          SettingModule.routeName,
          module: SettingModule(),
        ),
      ];
}
