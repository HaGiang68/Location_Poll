part of 'auth_page_cubit.dart';

@immutable
abstract class AuthPageState extends Equatable {
  const AuthPageState() : super();

  @override
  List<Object?> get props => [];
}

class AuthPageLoggedOut extends AuthPageState {
  const AuthPageLoggedOut({
    required this.email,
    required this.pwd,
  }) : super();
  final String email, pwd;

  @override
  List<Object?> get props => [
        email,
        pwd,
      ];

  bool get isEmailValid => RegExp(
          r"^[\u00F0-\u02AFa-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);

  bool get isPasswordValid => pwd.length > 5;
}

class AuthPageLoggedIn extends AuthPageState {
  const AuthPageLoggedIn() : super();
}

class AuthPageInitial extends AuthPageLoggedOut {
  const AuthPageInitial()
      : super(
          email: '',
          pwd: '',
        );
}

class AuthPageLogin extends AuthPageLoggedOut {
  const AuthPageLogin({
    required String email,
    required String pwd,
  }) : super(
          email: email,
          pwd: pwd,
        );
}

class AuthPageLoginLoading extends AuthPageLogin {
  const AuthPageLoginLoading({
    required String email,
    required String pwd,
  }) : super(email: email, pwd: pwd);
}

class AuthPageSignup extends AuthPageLoggedOut {
  const AuthPageSignup({
    required String email,
    required String pwd,
  }) : super(
          email: email,
          pwd: pwd,
        );
}

class AuthPageSignupLoading extends AuthPageSignup {
  const AuthPageSignupLoading({
    required String email,
    required String pwd,
  }) : super(
          email: email,
          pwd: pwd,
        );
}

class AuthPageSignupFailed extends AuthPageSignup {
  const AuthPageSignupFailed({
    required String email,
    required String pwd,
  }) : super(
          email: email,
          pwd: pwd,
        );
}

class AuthPageLoginFailed extends AuthPageLogin {
  const AuthPageLoginFailed({
    required String email,
    required String pwd,
  }) : super(email: email, pwd: pwd);
}

class ForgotPassword extends AuthPageLoggedOut {
  const ForgotPassword({
    required String email,
    required String pwd,
  }) : super(
          email: email,
          pwd: pwd,
        );
}

class ForgotPasswordRequested extends ForgotPassword {
  const ForgotPasswordRequested({
    required String email,
    required String pwd,
  }) : super(
          email: email,
          pwd: pwd,
        );
}

class ForgotPasswordRequestedFail extends ForgotPassword {
  const ForgotPasswordRequestedFail({
    required String email,
    required String pwd,
  }) : super(
          email: email,
          pwd: pwd,
        );
}
