import 'package:equatable/equatable.dart';

abstract class HomePageState extends Equatable {
  const HomePageState() : super();

  @override
  List<Object?> get props => [];
}

class PollScreenState extends HomePageState {}

class OwnPollScreenState extends HomePageState {}

class MapPollScreenState extends HomePageState {}

class SettingsScreenState extends HomePageState {}

class CreatePollState extends HomePageState {}

