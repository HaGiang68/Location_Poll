import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:location_poll/features/home/bloc/home_page_cubit.dart';
import 'package:location_poll/features/home/bloc/home_page_state.dart';
import 'package:location_poll/features/poll/create/ui/create_page.dart';
import 'package:location_poll/features/poll/overview/ui/poll_map_page.dart';
import 'package:location_poll/features/poll/overview/ui/polls_page.dart';
import 'package:location_poll/features/poll/poll_module.dart';
import 'package:location_poll/features/setting/ui/setting_page.dart';
import 'package:location_poll/global_ui/theme/bottom_navi_bar.dart';
import 'package:location_poll/global_ui/theme/colors.dart';
import 'package:location_poll/global_ui/theme/text_styles.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomePageCubit>(
      create: (_) => HomePageCubit(),
      child: BlocListener<HomePageCubit, HomePageState>(
        listener: (context, state) {
          if (state is CreatePollState) {
            Modular.to.pushNamed(
              PollModule.routeName + CreatePage.routeName,
            );
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: _generateAppBar(),
          body: Stack(
            children: [
              const SizedBox.expand(
                child: _PageContent(),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BlocBuilder<HomePageCubit, HomePageState>(
                    builder: (context, state) {
                      return BottomNaviBar(
                        onButtonPressed: (value) {
                          context
                              .read<HomePageCubit>()
                              .navigationBarItemSelected(value);
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _generateAppBar() {
    return AppBar(
      backgroundColor: ColorTheme.barColorBlue,
      title: BlocBuilder<HomePageCubit, HomePageState>(
        builder: (context, state) {
          return Text(
            _appBarTitle(state),
            style: OwnTextStylesDarkM.ownTextStyle(),
          );
        },
      ),
    );
  }

  String _appBarTitle(HomePageState state) {
    if (state is PollScreenState) {
      return 'Polls';
    }
    if (state is OwnPollScreenState) {
      return 'Own Polls';
    }
    if (state is MapPollScreenState) {
      return 'Poll Map';
    }
    if (state is SettingsScreenState) {
      return 'Settings';
    }
    return '';
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomePageCubit, HomePageState>(
      builder: (context, state) {
        if (state is PollScreenState) {
          return const PollsPage(
            showOwnPollsOnly: false,
          );
        }
        if (state is OwnPollScreenState) {
          return const PollsPage(
            showOwnPollsOnly: true,
          );
        }
        if (state is MapPollScreenState) {
          return const PollMapPage();
        }
        if (state is SettingsScreenState) {
          return const SettingPage();
        }
        return const Center(
          child: Text(
            'Something went wrong',
          ),
        );
      },
    );
  }
}
