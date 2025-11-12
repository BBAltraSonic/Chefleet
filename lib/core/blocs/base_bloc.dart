import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object?> get props => [];
}

abstract class AppBloc<Event extends AppEvent, State extends AppState> extends Bloc<Event, State> {
  AppBloc(super.initialState);
}