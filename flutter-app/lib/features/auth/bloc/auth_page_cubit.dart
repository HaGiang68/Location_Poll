import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:location_poll/features/poll/overview/bloc/polls_page_cubit.dart';
import 'package:location_poll/models/user.dart';
import 'package:location_poll/services/auth_service.dart';
import 'package:meta/meta.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_page_state.dart';

class AuthPageCubit extends Cubit<AuthPageState> implements Disposable {
  AuthPageCubit({
    required AuthService authService,
  })  : _authService = authService,
        super(const AuthPageInitial());

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  final AuthService _authService;
  StreamSubscription<User?>? _userSubscription;

  void loginPage() {
    _userSubscription = _authService.user.listen((event) {
      if (event != null) {
        Modular.get<PollsPageCubit>().init();
        emit(const AuthPageLoggedIn());
      }
    });

    emit(const AuthPageLogin(
      email: '',
      pwd: '',
    ));
  }

  Future<void> loginWithEmailPwd() async {
    final currState = state;
    if (currState is AuthPageLogin) {
      emit(AuthPageLoginLoading(email: currState.email, pwd: currState.pwd));
      final user = await _authService.signInWithEmailAndPassword(
          currState.email, currState.pwd);
      if (user == null) {
        emit(AuthPageLoginFailed(
          email: currState.email,
          pwd: currState.pwd,
        ));
        emit(AuthPageLogin(email: currState.email, pwd: currState.pwd));
      }
    }
  }

  Future<void> loginWithGoogle() async {
    GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;
    final user =
        await _authService.signInWithGoogle(googleSignInAuthentication);
    if (user == null) {
      emit(AuthPageLoginFailed(
        email: user!.userName,
        pwd: '',
      ));
      emit(AuthPageLogin(email: user.userName, pwd: ''));
    }
  }

  void emailChanged(String email) {
    final curState = state;
    if (curState is AuthPageLogin) {
      emit(
        AuthPageLogin(email: email, pwd: curState.pwd),
      );
    }
    if (curState is AuthPageSignup) {
      emit(
        AuthPageSignup(email: email, pwd: curState.pwd),
      );
    }
    if (curState is ForgotPassword) {
      emit(
        ForgotPassword(email: email, pwd: curState.pwd),
      );
    }
  }

  void pwdChanged(String pwd) {
    final curState = state;
    if (curState is AuthPageLogin) {
      emit(
        AuthPageLogin(email: curState.email, pwd: pwd),
      );
    }
    if (curState is AuthPageSignup) {
      emit(
        AuthPageSignup(email: curState.email, pwd: pwd),
      );
    }
  }

  Future<void> resetPassword() async {
    final curState = state;
    if (curState is ForgotPassword) {
      try {
        await _authService.resetPassword(curState.email);
      } catch (e) {
        emit(
          ForgotPasswordRequestedFail(email: curState.email, pwd: curState.pwd),
        );
        return;
      }
      emit(
        ForgotPasswordRequested(email: curState.email, pwd: curState.pwd),
      );
    }
  }

  void toggleForgotPassword() {
    final curState = state;
    if (curState is AuthPageLogin) {
      emit(
        ForgotPassword(
          email: curState.email,
          pwd: curState.email,
        ),
      );
    }
  }

  void toggleSignUpLogin() {
    final curState = state;
    if (curState is AuthPageLogin) {
      emit(
        AuthPageSignup(
          email: curState.email,
          pwd: curState.pwd,
        ),
      );
    } else if (curState is ForgotPassword) {
      emit(
        AuthPageSignup(
          email: curState.email,
          pwd: curState.pwd,
        ),
      );
    } else if (curState is AuthPageSignup) {
      emit(
        AuthPageLogin(
          email: curState.email,
          pwd: curState.pwd,
        ),
      );
    }
  }

  Future<void> registerWithEmailAndPassword() async {
    final curState = state;
    if (curState is AuthPageSignup) {
      emit(AuthPageSignupLoading(
        email: curState.email,
        pwd: curState.pwd,
      ));
      final user = await _authService.registerWithEmailAndPassword(
          curState.email, curState.pwd);
      if (user == null) {
        emit(AuthPageSignupFailed(
          email: curState.email,
          pwd: curState.pwd,
        ));
      }
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
  }
}
