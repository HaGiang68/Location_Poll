import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:location_poll/features/home/home_module.dart';
import 'package:location_poll/features/result/bloc/result_cubit.dart';
import 'package:location_poll/global_ui/theme/box_deco.dart';
import 'package:location_poll/global_ui/theme/colors.dart';
import 'package:location_poll/global_ui/theme/text_styles.dart';
import 'package:location_poll/models/choice.dart';
import 'package:location_poll/models/poll.dart';
import 'package:location_poll/services/poll_service.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../theme_model.dart';

class ResultPage extends StatelessWidget {
  Poll poll;

  ResultPage({Key? key, required this.poll}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ResultCubit>(
      create: (_) => ResultCubit(pollService: Modular.get<PollService>())
        ..startWithPoll(poll),
      child: ResultView(),
    );
  }
}

class ResultView extends StatelessWidget {
  ResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return BlocBuilder<ResultCubit, ResultState>(
        builder: (context, state) {
          if (state is! PollLoaded) {
            return const Text('Unable');
          }
          final poll = state.poll;
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: ColorTheme.barColorBlue,
                leading: Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                        onPressed: () {
                          Modular.to.navigate(HomeModule.routeName);
                        },
                        icon: const Icon(Icons.arrow_back_ios_new));
                  },
                ),
                title: Text(
                  'Result',
                  style: OwnTextStylesDarkM.ownTextStyle(),
                ),
              ),
              body: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  SliverAppBar(
                    floating: false,
                    pinned: true,
                    backgroundColor: ColorTheme.backgroundColor,
                    onStretchTrigger: () {
                      // Function callback for stretch
                      return Future<void>.value();
                    },
                    expandedHeight: MediaQuery.of(context).size.width * 0.7,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDeco.boxDeco(),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 50.0, right: 20.0, left: 20.0, bottom: 20.0),
                          child: Column(
                            children: [
                              Text(
                                poll.title,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.clip,
                                style: OwnTextStylesBlackBold.ownTextStyle(),
                              ),
                              Text(
                                poll.questions[0].question,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.clip,
                                style: ButtonTextStylesBlack.buttonTextStyle(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(-8),
                      child: Container(
                        color: themeNotifier.isDark
                            ? ColorTheme.backgroundColorLight
                            : ColorTheme.backgroundColor,
                        child: TabBar(
                          labelColor: themeNotifier.isDark
                              ? ColorTheme.colorBlack
                              : ColorTheme.colorWhite,
                          tabs: const [
                            Tab(text: 'STATS'),
                            Tab(text: 'NUMBERS'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    child: TabBarView(children: [
                      RefreshIndicator(
                        onRefresh: () async {
                          await context.read<ResultCubit>().updatePoll();
                        },
                        child: ListView(
                          padding: const EdgeInsets.only(
                              right: 8, left: 8, bottom: 8, top: 20),
                          children: <Widget>[
                            SizedBox(
                              height: 40,
                              child: RichText(
                                text: TextSpan(
                                    text: 'Start Time: ',
                                    style: themeNotifier.isDark
                                        ? StatsStylesLightM.ownTextStyle()
                                        : StatsStyles.ownTextStyle(),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text:
                                            poll.requirements.timeRequirement
                                                    .startTime.day
                                                    .toString() +
                                                '.' +
                                                poll.requirements
                                                    .timeRequirement.startTime.month
                                                    .toString() +
                                                '.' +
                                                poll
                                                    .requirements
                                                    .timeRequirement
                                                    .startTime
                                                    .year
                                                    .toString() +
                                                ' ' +
                                                poll
                                                    .requirements
                                                    .timeRequirement
                                                    .startTime
                                                    .hour
                                                    .toString() +
                                                ':' +
                                                poll
                                                    .requirements
                                                    .timeRequirement
                                                    .startTime
                                                    .minute
                                                    .toString(),
                                      ),
                                    ]),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              child: RichText(
                                text: TextSpan(
                                    text: 'End Time: ',
                                    style: themeNotifier.isDark
                                        ? StatsStylesLightM.ownTextStyle()
                                        : StatsStyles.ownTextStyle(),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text:
                                            poll.requirements.timeRequirement
                                                    .endTime.day
                                                    .toString() +
                                                '.' +
                                                poll
                                                    .requirements
                                                    .timeRequirement
                                                    .endTime
                                                    .month
                                                    .toString() +
                                                '.' +
                                                poll
                                                    .requirements
                                                    .timeRequirement
                                                    .endTime
                                                    .year
                                                    .toString() +
                                                ' ' +
                                                poll
                                                    .requirements
                                                    .timeRequirement
                                                    .endTime
                                                    .hour
                                                    .toString() +
                                                ':' +
                                                poll
                                                    .requirements
                                                    .timeRequirement
                                                    .endTime
                                                    .minute
                                                    .toString(),
                                      ),
                                    ]),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              child: RichText(
                                text: TextSpan(
                                    text: 'Total Number of votes: ',
                                    style: themeNotifier.isDark
                                        ? StatsStylesLightM.ownTextStyle()
                                        : StatsStyles.ownTextStyle(),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: totalNumberOfVotes(
                                              poll.questions[0].choices)),
                                    ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                      RefreshIndicator(
                        onRefresh: () async {
                          await context.read<ResultCubit>().updatePoll();
                        },
                        child: ListView.builder(
                          itemCount: poll.questions[0].choices.length,
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              height: 65,
                              decoration: BoxDecoration(
                                  border: Border(
                                bottom: BorderSide(
                                    width: 1.0, color: ColorTheme.colorWhite),
                              )),
                              child: LinearPercentIndicator(
                                alignment: MainAxisAlignment.center,
                                width: 170.0,
                                animation: true,
                                animationDuration: 1000,
                                lineHeight: 20.0,
                                leading: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  child: Text(
                                    poll.questions[0].choices[index].choice
                                        .toString(),
                                    style: themeNotifier.isDark
                                        ? StatsStylesLightM.ownTextStyle()
                                        : StatsStyles.ownTextStyle(),
                                  ),
                                ),
                                trailing: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  child: Text(
                                    poll.questions[0].choices[index].counter
                                        .toString(),
                                    style: themeNotifier.isDark
                                        ? StatsStylesLightM.ownTextStyle()
                                        : StatsStyles.ownTextStyle(),
                                  ),
                                ),
                                percent: choicePercentage(
                                        poll.questions[0].choices,
                                        poll.questions[0].choices[index]) /
                                    100,
                                center: Text(
                                  choicePercentage(poll.questions[0].choices,
                                          poll.questions[0].choices[index])
                                      .toString(),
                                  style:
                                      TextStyle(color: ColorTheme.colorWhite),
                                ),
                                linearStrokeCap: LinearStrokeCap.butt,
                                progressColor: ColorTheme.barColorBlue,
                                backgroundColor: ColorTheme.buttonColorGrey,
                              ),
                            );
                          },
                        ),
                      )
                    ]),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  String totalNumberOfVotes(List<Choice> list) {
    int? sumOfAllVotes = 0;
    for (var i in list) {
      sumOfAllVotes = sumOfAllVotes! + i.counter;
    }
    return sumOfAllVotes.toString();
  }

  double choicePercentage(List<Choice> list, var choice) {
    int sumOffAllVotes = 0;
    for (var i in list) {
      sumOffAllVotes = sumOffAllVotes + i.counter;
    }
    for (var j in list) {
      if (j == choice) {
        int number = j.counter;
        double result =
            (number / (sumOffAllVotes == 0 ? 1 : sumOffAllVotes)) * 100;
        double percent = double.parse(result.toStringAsFixed(2));
        return percent;
      }
    }
    return 0.0;
  }
}
