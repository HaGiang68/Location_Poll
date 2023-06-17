import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:location_poll/features/setting/bloc/setting_cubit.dart';
import 'package:location_poll/global_ui/theme/colors.dart';
import 'package:location_poll/global_ui/theme/text_styles.dart';
import 'package:location_poll/theme_model.dart';
import 'package:provider/provider.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({Key? key}) : super(key: key);
  static const routeName = '/tos';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingCubit>.value(
      value: Modular.get<SettingCubit>(),
      child: const TermsOfServiceView(),
    );
  }
}

class TermsOfServiceView extends StatelessWidget {
  const TermsOfServiceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Text(
            'Terms of Service',
            style: OwnTextStylesDarkM.ownTextStyle(),
          ),
          backgroundColor: ColorTheme.barColorBlue,
        ),
        body: FutureBuilder(
            future: rootBundle.loadString("assets/terms_of_service/tos.md"),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return Markdown(data: snapshot.data!);
              }

              return Center(
                child: CircularProgressIndicator(),
              );
            }),
      );
    });
  }
}
