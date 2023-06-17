import 'package:flutter_modular/flutter_modular.dart';
import 'package:location_poll/features/maps/ui/map_page.dart';

import 'bloc/map_cubit.dart';

class MapsModule extends Module {
  static const routeName = '/maps';

  @override
  List<Bind<Object>> get binds => [
        Bind.singleton(
          (i) => MapCubit(),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/',
            child: (_, args) =>
                MapPage(position: args.data[0], radius: args.data[1])),
      ];
}
