import 'package:bloc/bloc.dart';
import 'package:location_poll/features/home/bloc/home_page_state.dart';
import 'package:location_poll/global_ui/theme/bottom_navi_bar.dart';

class HomePageCubit extends Cubit<HomePageState> {
  HomePageCubit()
      : super(
          PollScreenState(),
        );

  void navigationBarItemSelected(SelectedButton selectedButton) {
    switch (selectedButton) {
      case SelectedButton.polls:
        emit(
          PollScreenState(),
        );
        break;
      case SelectedButton.ownPolls:
        emit(
          OwnPollScreenState(),
        );
        break;
      case SelectedButton.pollsMap:
        emit(
          MapPollScreenState(),
        );
        break;
      case SelectedButton.settings:
        emit(
          SettingsScreenState(),
        );
        break;
      case SelectedButton.createPoll:
        final curState = state;
        emit(
          CreatePollState(),
        );
        emit(curState);
        break;
    }
  }
}
