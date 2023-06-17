import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:location_poll/features/poll/overview/bloc/polls_page_cubit.dart';
import 'package:location_poll/features/poll/overview/bloc/polls_page_state.dart';
import 'package:location_poll/features/poll/overview/ui/poll_list_item.dart';
import 'package:location_poll/global_ui/theme/colors.dart';
import 'package:location_poll/models/poll.dart';
import 'package:provider/provider.dart';

class PollsPage extends StatelessWidget {
  const PollsPage({
    Key? key,
    required this.showOwnPollsOnly,
  }) : super(key: key);

  final bool showOwnPollsOnly;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PollsPageCubit>.value(
          value: Modular.get<PollsPageCubit>(),
        ),
      ],
      child: _PageContent(
        showOwnPollsOnly: showOwnPollsOnly,
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({
    Key? key,
    required this.showOwnPollsOnly,
  }) : super(key: key);
  final bool showOwnPollsOnly;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PollsPageCubit, PollsPageState>(
      builder: (context, state) {
        if (state is PollsPageInitial) {
          return Container();
        } else if (state is PollsPageLoading) {
          return const _PageContentLoading();
        } else if (state is PollsPageLoaded) {
          return _PageContentLoaded(
            polls: showOwnPollsOnly ? state.myPolls : state.allPolls,
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class _PageContentLoading extends StatelessWidget {
  const _PageContentLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _PageContentLoaded extends StatelessWidget {
  const _PageContentLoaded({
    Key? key,
    required this.polls,
  }) : super(key: key);

  final List<Poll> polls;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<PollsPageCubit>().loadPolls();
      },
      child: ListView.separated(
        itemCount: polls.length,
        itemBuilder: (context, index) {
          final poll = polls[index];
          // Styling for the poll item, could be feasible to make it a own class
          return PollListItem(
            poll: poll,
            onClickDelete: (poll) => _showDeletePollDialog(
              context: context,
              poll: poll,
              onDeletePoll: () =>
                  context.read<PollsPageCubit>().deletePoll(poll),
            ),
          );
        },
        separatorBuilder: (context, i) {
          return Divider(
            height: 1,
            indent: 15,
            endIndent: 15,
            color: ColorTheme.colorBlack,
          );
        },
      ),
    );
  }

  Future<void> _showDeletePollDialog({
    required BuildContext context,
    required Poll poll,
    required Function() onDeletePoll,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Poll?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete ${poll.title}?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Delete',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.apply(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: () {
                onDeletePoll.call();
                Modular.to.pop();
              },
            ),
            TextButton(
              child: Text(
                'Cancel',
              ),
              onPressed: () {
                Modular.to.pop();
              },
            ),
          ],
        );
      },
    );
  }
}
