import 'package:flutter_modular/flutter_modular.dart';
import 'package:location_poll/features/maps/map_module.dart';
import 'package:location_poll/features/poll/create/bloc/create_cubit.dart';
import 'package:location_poll/features/poll/create/ui/create_page.dart';
import 'package:location_poll/features/poll/vote/ui/vote_page.dart';
import 'package:location_poll/features/poll/vote/ui/vote_preview_page.dart';
import 'package:location_poll/services/poll_service.dart';

class PollModule extends Module {
  static const routeName = '/create';

  ///Represents an object that will be available for injection to other
  ///dependencies
  @override
  List<Bind> get binds => [
        Bind.singleton(
          (i) => CreateCubit(
            pollService: i.get<PollService>(),
          ),
        ),
      ];

  ///Page setup eligible for navigation
  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          CreatePage.routeNameEdit,
          child: (_, args) => CreatePage(poll: args.data),
        ),
        ChildRoute(
          CreatePage.routeName,
          child: (_, args) => const CreatePage(),
        ),
        ChildRoute(
          VotePage.routeName,
          child: (_, args) => VotePage(
            poll: args.data['poll'],
          ),
        ),
        ChildRoute(
          VotePreviewPage.routeName,
          child: (_, args) => VotePreviewPage(
            poll: args.data['poll'],
          ),
        ),
        ModuleRoute(MapsModule.routeName, module: MapsModule())
      ];
}
