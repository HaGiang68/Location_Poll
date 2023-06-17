import 'package:flutter_modular/flutter_modular.dart';
import 'package:location_poll/features/result/ui/result_page.dart';

class ResultModule extends Module {
  static const routeName = '/result';

  @override
  List<Bind<Object>> get binds => [];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          child: (_, args) => ResultPage(poll: args.data),
        )
      ];
}
