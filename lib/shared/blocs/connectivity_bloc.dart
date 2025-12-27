import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  Timer? _debouncer;
  
  ConnectivityBloc() : super(const ConnectivityInitial()) {
    on<ConnectivityStatusChanged>(_onConnectivityStatusChanged);
    on<ConnectivityStatusChecked>(_onConnectivityStatusChecked);
  }

  void _onConnectivityStatusChanged(
    ConnectivityStatusChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    // Debounce connectivity changes to prevent flickering on unstable connections
    _debouncer?.cancel();
    _debouncer = Timer(const Duration(milliseconds: 500), () {
      if (!isClosed) {
        emit(ConnectivityChanged(isConnected: event.isConnected));
      }
    });
  }

  void _onConnectivityStatusChecked(
    ConnectivityStatusChecked event,
    Emitter<ConnectivityState> emit,
  ) {
    // Immediate check - no debounce needed for manual checks
    emit(ConnectivityChanged(isConnected: event.isConnected));
  }

  @override
  Future<void> close() {
    _debouncer?.cancel();
    return super.close();
  }
}