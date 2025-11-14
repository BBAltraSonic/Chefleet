import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc() : super(const ConnectivityInitial()) {
    on<ConnectivityChanged>(_onConnectivityChanged);
    on<ConnectivityChecked>(_onConnectivityChecked);
  }

  void _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    emit(ConnectivityChanged(isConnected: event.isConnected));
  }

  void _onConnectivityChecked(
    ConnectivityChecked event,
    Emitter<ConnectivityState> emit,
  ) {
    emit(ConnectivityChanged(isConnected: event.isConnected));
  }
}