import 'package:flutter_modular/flutter_modular.dart';
import 'package:location_poll/features/setting/ui/setting_page.dart';
import 'package:location_poll/features/setting/ui/tos_page.dart';

import 'bloc/setting_cubit.dart';

class SettingModule extends Module {
  static const routeName = '/setting';


  @override
  List<Bind<Object>> get binds => [
        Bind.singleton(
          (i) => SettingCubit(),
        )
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          child: (_, args) => SettingPage(),
        ),
        ChildRoute(
          TermsOfServicePage.routeName,
          child: (_, args) => TermsOfServicePage(),
        )
      ];
}
