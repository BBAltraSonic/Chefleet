import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc() : super(const ConnectivityInitial()) {
    on<ConnectivityStatusChanged>(_onConnectivityStatusChanged);
    on<ConnectivityStatusChecked>(_onConnectivityStatusChecked);
  }

  void _onConnectivityStatusChanged(
    ConnectivityStatusChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    emit(ConnectivityChanged(isConnected: event.isConnected));
  }

  void _onConnectivityStatusChecked(
    ConnectivityStatusChecked event,
    Emitter<ConnectivityState> emit,
  ) {
    emit(ConnectivityChanged(isConnected: event.isConnected));
  }
}