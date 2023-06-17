import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:location_poll/features/poll/vote/bloc/vote_page_dart_cubit.dart';
import 'package:location_poll/features/poll/vote/bloc/vote_page_state.dart';
import 'package:location_poll/features/poll/vote/ui/poll_header.dart';
import 'package:location_poll/global_ui/theme/text_styles.dart';
import 'package:location_poll/models/choice.dart';
import 'package:location_poll/models/poll.dart';
import 'package:location_poll/services/geofence_service.dart';
import 'package:location_poll/services/poll_service.dart';
import 'package:location_poll/services/storage_service.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../../../theme_model.dart';

class VotePage extends StatelessWidget {
  const VotePage({
    Key? key,
    required this.poll,
  }) : super(key: key);

  static const String routeName = '/vote';

  final Poll poll;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VotePageCubit>(
      create: (context) => VotePageCubit(
        pollService: Modular.get<PollService>(),
        geofenceService: Modular.get<GeofenceService>(),
        storageService: Modular.get<StorageService>(),
      )..startWithPoll(
          poll,
        ),
      child: BlocListener<VotePageCubit, VotePageState>(
        listenWhen: (prev, cur) {
          return prev is VotePageSubmitting && cur.submissionFailed ||
              cur is VotePageFinished;
        },
        listener: (context, state) {
          if (state is VotePageFinished) {
            Modular.to.pop();
            Modular.to.pop();
            return;
          }
          if (state.submissionFailed) {
            showTopSnackBar(
                context,
                const CustomSnackBar.error(
                    message:
                        'Your choice couldn\'t be transmitted to the server.'));
          }
        },
        child: const _PageContent(),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BlocBuilder<VotePageCubit, VotePageState>(
            builder: (context, state) {
              if (state is VotePagePollState) {
                return PollHeader(text: state.poll.questions[0].question);
              }
              return Container();
            },
          ),
          const Expanded(
            child: SingleChildScrollView(
              child: _ChoiceList(
                questionId: 0,
              ),
            ),
          ),
          const _SubmitButton(),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VotePageCubit, VotePageState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: FloatingActionButton.extended(
            onPressed: state is VotePageSubmitting
                ? null
                : () {
                    context.read<VotePageCubit>().submit();
                  },
            backgroundColor: state.submissionFailed
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            label: Text(state.submissionFailed
                ? ' RETRY'
                : state is VotePageSubmitting
                    ? 'SUBMITTING...'
                    : 'SUBMIT'),
          ),
        );
      },
    );
  }
}

class _ChoiceListItem extends StatelessWidget {
  const _ChoiceListItem({
    Key? key,
    required this.choice,
    this.isSelected = false,
    this.onChanged,
  }) : super(key: key);

  final Choice choice;
  final bool isSelected;
  final Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Text(
                choice.choice,
                style: themeNotifier.isDark
                    ? OwnTextStylesLightM.ownTextStyle()
                    : OwnTextStylesDarkM.ownTextStyle(),
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Transform.scale(
              scale: 1.6,
              child: Checkbox(
                value: isSelected,
                onChanged: onChanged,
                shape: const CircleBorder(),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ChoiceList extends StatelessWidget {
  const _ChoiceList({
    Key? key,
    required this.questionId,
  }) : super(key: key);

  final int questionId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VotePageCubit, VotePageState>(
      builder: (context, state) {
        final currState = state;
        if (currState is VotePagePollState) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (Choice choice
                  in currState.poll.questions[questionId].choices)
                _ChoiceListItem(
                  choice: choice,
                  isSelected: currState.votes[questionId] == choice.choiceId,
                  onChanged: (value) {
                    context.read<VotePageCubit>().vote(choice.choiceId);
                  },
                ),
            ],
          );
        }
        return Container();
      },
    );
  }
}
