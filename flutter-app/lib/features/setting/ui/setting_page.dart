import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:location_poll/features/auth/auth_module.dart';
import 'package:location_poll/features/setting/bloc/setting_cubit.dart';
import 'package:location_poll/features/setting/setting_module.dart';
import 'package:location_poll/features/setting/ui/tos_page.dart';
import 'package:location_poll/global_ui/theme/text_styles.dart';
import 'package:location_poll/services/auth_service.dart';
import 'package:location_poll/theme_model.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingCubit>(
      create: (_) => SettingCubit(),
      child: const SettingView(),
    );
  }
}

class SettingView extends StatelessWidget {
  const SettingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        ListTile(
          title: Text(
            'Logout',
            style: ListTileStyles.ownTextStyle(context),
          ),
          onTap: () async {
            await Modular.get<AuthService>().signOut();
            Modular.to.navigate(AuthModule.routeName);
          },
        ),
        Consumer<ThemeModel>(
          builder: (context, ThemeModel themeNotifier, child) {
            return ListTile(
              title: Text(
                themeNotifier.isDark ? "Dark Mode" : 'Light Mode',
                style: ListTileStyles.ownTextStyle(context),
              ),
              onTap: () async {
                themeNotifier.isDark
                    ? themeNotifier.isDark = false
                    : themeNotifier.isDark = true;
              },
            );
          },
        ),
        ListTile(
          title: Text(
            'Terms of service',
            style: ListTileStyles.ownTextStyle(context),
          ),
          onTap: () => Modular.to.pushNamed(
              SettingModule.routeName + TermsOfServicePage.routeName),
        ),
        ListTile(
          title: Text(
            'Licenses',
            style: ListTileStyles.ownTextStyle(context),
          ),
          onTap: () => showLicensePage(context: context),
        ),
      ],
    );
  }
}
