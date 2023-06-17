import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:location_poll/features/auth/bloc/auth_page_cubit.dart';
import 'package:location_poll/features/home/home_module.dart';
import 'package:location_poll/global_ui/theme/buttons.dart';
import 'package:location_poll/global_ui/theme/colors.dart';
import 'package:location_poll/global_ui/theme/input_field_decoration.dart';
import 'package:location_poll/global_ui/theme/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../../theme_model.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: Modular.get<AuthPageCubit>()..loginPage(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              32,
              16,
              16,
            ),
            child: BlocConsumer<AuthPageCubit, AuthPageState>(
                listener: (context, state) {
              if (state is AuthPageLoggedIn) {
                Modular.to.navigate(HomeModule.routeName);
              }
              if (state is AuthPageLoginFailed) {
                showTopSnackBar(context,
                    const CustomSnackBar.error(message: 'Login Failed.'));
              }
              if (state is ForgotPasswordRequested) {
                showTopSnackBar(
                    context,
                    const CustomSnackBar.success(
                        message: 'Your password is send to your email'));
              }
              if (state is ForgotPasswordRequestedFail) {
                showTopSnackBar(
                    context,
                    const CustomSnackBar.error(
                        message: 'Your password can not be restored'));
              }
              if (state is AuthPageSignupFailed) {
                showTopSnackBar(context,
                    const CustomSnackBar.error(message: 'Signup Failed.'));
              }
              if (state is AuthPageLoggedIn) {
                showTopSnackBar(context,
                    const CustomSnackBar.success(message: 'Logged In.'));
              }
            }, builder: (context, state) {
              return Column(
                children: [
                  _createLogoAndTitle(context),
                  if (state is AuthPageLogin) _createWelcomeTitleLogin(context),
                  if (state is AuthPageSignup)
                    _createWelcomeTitleSignUp(context),
                  const SizedBox(height: 32),
                  if (state is AuthPageLogin) const _InputAreaLogin(),
                  if (state is AuthPageSignup) const _InputAreaSignUp(),
                  if (state is ForgotPassword ||
                      state is ForgotPasswordRequested ||
                      state is ForgotPasswordRequestedFail)
                    const _InputAreaForgotPassword(),
                  const SizedBox(height: 24),
                  const _LoginMethodsButtons(),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _createLogoAndTitle(BuildContext context) {
    return Row(children: [
      Expanded(
        flex: 2,
        child: Image.asset(
          'assets/images/Logo.png',
          height: MediaQuery.of(context).size.height * 0.2,
          width: MediaQuery.of(context).size.width * 0.2,
        ),
      ),
      Expanded(
        flex: 8,
        child: Consumer<ThemeModel>(
          builder: (context, ThemeModel themeNotifier, child) {
            return Text('Location Poll',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42,
                  color: themeNotifier.isDark
                      ? ColorTheme.colorBlack
                      : ColorTheme.colorWhite,
                ));
          },
        ),
      )
    ]);
  }

  Widget _createWelcomeTitleLogin(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Text(
          'Login with your \n'
          'registered E-Mail address.',
          textAlign: TextAlign.center,
          style: themeNotifier.isDark
              ? OwnTextStylesLightM.ownTextStyle()
              : OwnTextStylesDarkM.ownTextStyle());
    });
  }

  Widget _createWelcomeTitleSignUp(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Text('Sign-Up to enjoy the app',
          textAlign: TextAlign.center,
          style: themeNotifier.isDark
              ? OwnTextStylesLightM.ownTextStyle()
              : OwnTextStylesDarkM.ownTextStyle());
    });
  }
}

class _InputAreaLogin extends StatelessWidget {
  const _InputAreaLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return BlocBuilder<AuthPageCubit, AuthPageState>(
      builder: (context, state) {
        final curState = state;
        if (curState is AuthPageLoggedOut) {
          return Form(
            key: _formKey,
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextFormField(
                  onChanged: (value) {
                    context.read<AuthPageCubit>().emailChanged(value);
                  },
                  decoration: InputFieldDecorations.defaultDecoration(
                    context: context,
                      labelText: "E-Mail",
                      suffixIcon: const Icon(Icons.mail_outlined)),
                  validator: (val) =>
                      curState.isEmailValid ? null : 'Enter an email',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  onChanged: (value) {
                    context.read<AuthPageCubit>().pwdChanged(value);
                  },
                  obscureText: true,
                  decoration: InputFieldDecorations.defaultDecoration(
                    context: context,
                      labelText: "Password",
                      suffixIcon: const Icon(Icons.password)),
                  validator: (val) => curState.isPasswordValid
                      ? null
                      : 'Enter a password 6+ chars long',
                ),
                SizedBox(
                  height: 28,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        context.read<AuthPageCubit>().toggleForgotPassword();
                      },
                      child: Text(
                        'FORGOT PASSWORD',
                        style: TextStyle(
                          fontSize: 10,
                          color: ColorTheme.buttonColorGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        context.read<AuthPageCubit>().loginWithEmailPwd();
                      }
                    },
                    child: Text(
                      'LOGIN',
                      style: ButtonTextStylesBlack.buttonTextStyle(),
                    ),
                    style: ButtonStyles.fullSizeButton(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          ColorTheme.buttonColorlightCyan),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AuthPageCubit>().toggleSignUpLogin();
                    },
                    child: Text(
                      'SIGN-UP',
                      style: ButtonTextStylesBlack.buttonTextStyle(),
                    ),
                    style: ButtonStyles.fullSizeButton(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          ColorTheme.buttonColorGrey),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}

class _InputAreaSignUp extends StatelessWidget {
  const _InputAreaSignUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return BlocBuilder<AuthPageCubit, AuthPageState>(
      builder: (context, state) {
        final curState = state;
        if (curState is AuthPageLoggedOut) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  onChanged: (value) {
                    context.read<AuthPageCubit>().emailChanged(value);
                  },
                  decoration: InputFieldDecorations.defaultDecoration(
                    context: context,
                      labelText: "E-Mail",
                      suffixIcon: const Icon(Icons.mail_outlined)),
                  validator: (val) =>
                      curState.isEmailValid ? null : 'Enter an valid email',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  onChanged: (value) {
                    context.read<AuthPageCubit>().pwdChanged(value);
                  },
                  obscureText: true,
                  decoration: InputFieldDecorations.defaultDecoration(
                    context: context,
                      labelText: "Password",
                      suffixIcon: const Icon(Icons.password)),
                  validator: (val) => curState.isPasswordValid
                      ? null
                      : 'Enter a password 6+ chars long',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  onChanged: (value) {
                    context.read<AuthPageCubit>().pwdChanged(value);
                  },
                  obscureText: true,
                  decoration: InputFieldDecorations.defaultDecoration(
                    context: context,
                      labelText: "Repeat password",
                      suffixIcon: const Icon(Icons.password)),
                  validator: (val) =>
                      curState.pwd == val ? null : 'Password does not match',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        context
                            .read<AuthPageCubit>()
                            .registerWithEmailAndPassword();
                      }
                    },
                    child: Text(
                      'SIGN-UP',
                      style: ButtonTextStylesBlack.buttonTextStyle(),
                    ),
                    style: ButtonStyles.fullSizeButton(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          ColorTheme.buttonColorGrey),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AuthPageCubit>().toggleSignUpLogin();
                    },
                    child: Text(
                      'LOGIN',
                      style: ButtonTextStylesBlack.buttonTextStyle(),
                    ),
                    style: ButtonStyles.fullSizeButton(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          ColorTheme.buttonColorlightCyan),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}

class _InputAreaForgotPassword extends StatelessWidget {
  const _InputAreaForgotPassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return BlocBuilder<AuthPageCubit, AuthPageState>(
      builder: (context, state) {
        final curState = state;
        if (curState is AuthPageLoggedOut) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  onChanged: (value) {
                    context.read<AuthPageCubit>().emailChanged(value);
                  },
                  decoration: InputFieldDecorations.defaultDecoration(
                    context: context,
                      labelText: "E-Mail",
                      suffixIcon: const Icon(Icons.mail_outlined)),
                  validator: (val) =>
                      curState.isEmailValid ? null : 'Enter your email',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        context.read<AuthPageCubit>().resetPassword();
                      }
                    },
                    child: Text(
                      'GET PASSWORD',
                      style: TextStyle(
                        fontSize: 20,
                        color: ColorTheme.colorBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ButtonStyles.fullSizeButton(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          ColorTheme.buttonColorlightCyan),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AuthPageCubit>().toggleSignUpLogin();
                    },
                    child: Text(
                      'SIGN-UP',
                      style: ButtonTextStylesBlack.buttonTextStyle(),
                    ),
                    style: ButtonStyles.fullSizeButton(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          ColorTheme.buttonColorGrey),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}

class _LoginMethodsButtons extends StatelessWidget {
  const _LoginMethodsButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 48,
          width: MediaQuery.of(context).size.width * 0.6,
          child: ElevatedButton(
            onPressed: () {
              context.read<AuthPageCubit>().loginWithGoogle();
            },
            child: Text(
              'GOOGLE',
              style: ButtonTextStylesBlack.buttonTextStyle(),
            ),
            style: ButtonStyles.fullSizeButton(
              backgroundColor:
                  MaterialStateProperty.all<Color>(ColorTheme.buttonColorBlue),
            ),
          ),
        ),
        //const SizedBox(height: 16),
      ],
    );
  }
}
