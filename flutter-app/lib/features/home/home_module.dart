import 'package:flutter_modular/flutter_modular.dart';
import 'package:location_poll/features/home/ui/home_page.dart';

class HomeModule extends Module {
  static const routeName = '/home/';

  @override
  List<Bind<Object>> get binds => [];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          child: (_, args) => const HomePage(),
        ),
      ];
}
