import 'package:flutter_modular/flutter_modular.dart';
import 'package:location_poll/features/auth/bloc/auth_page_cubit.dart';
import 'package:location_poll/features/auth/ui/auth_page.dart';
import 'package:location_poll/services/auth_service.dart';

class AuthModule extends Module {
  static const routeName = '/auth';

  @override
  List<Bind<Object>> get binds => [
        Bind.singleton(
          (i) => AuthPageCubit(
            authService: i.get<AuthService>(),
          ),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          child: (_, args) => const AuthPage(),
        ),
      ];
}
