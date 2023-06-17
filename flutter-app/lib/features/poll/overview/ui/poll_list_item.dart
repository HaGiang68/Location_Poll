import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:location_poll/features/poll/create/ui/create_page.dart';
import 'package:location_poll/features/poll/poll_module.dart';
import 'package:location_poll/features/poll/vote/ui/vote_preview_page.dart';
import 'package:location_poll/features/result/result_module.dart';
import 'package:location_poll/global_ui/theme/colors.dart';
import 'package:location_poll/global_ui/theme/text_styles.dart';
import 'package:location_poll/models/poll.dart';

class PollListItem extends StatelessWidget {
  const PollListItem({
    Key? key,
    required this.poll,
    this.onClickDelete,
  }) : super(key: key);

  final Poll poll;
  final Function(Poll poll)? onClickDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        poll.title,
        style: ListTileStyles.ownTextStyle(context),
      ),
      onTap: () {
        Modular.to.pushNamed(
          PollModule.routeName + VotePreviewPage.routeName,
          arguments: {
            'poll': poll,
          },
        );
      },
      trailing: SizedBox(
        width: 200,
        child: SizedBox.expand(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (poll.alreadyVoted)
                ElevatedButton(
                  child: Icon(
                    Icons.trending_up,
                    color: ColorTheme.colorWhite,
                    size: 20,
                  ),
                  onPressed: () {
                    Modular.to
                        .navigate(ResultModule.routeName, arguments: poll);
                  },
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(const CircleBorder()),
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(10)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          ColorTheme.buttonColorlightCyan)),
                ),
              if (poll.isEditable)
                ElevatedButton(
                  onPressed: () {
                    Modular.to.navigate(
                        '${PollModule.routeName}${CreatePage.routeNameEdit}',
                        arguments: poll);
                  },
                  child: Icon(
                    Icons.edit,
                    color: ColorTheme.colorWhite,
                    size: 20,
                  ),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(const CircleBorder()),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          ColorTheme.buttonColorBlue)),
                ),
              if (poll.isDeletable)
                ElevatedButton(
                  onPressed: () => onClickDelete?.call(poll),
                  child: Icon(
                    Icons.delete,
                    color: ColorTheme.colorWhite,
                    size: 20,
                    semanticLabel: 'Delete',
                  ),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(const CircleBorder()),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          ColorTheme.deleteButtonColorRed)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
