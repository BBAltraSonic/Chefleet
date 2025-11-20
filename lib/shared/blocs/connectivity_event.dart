part of 'connectivity_bloc.dart';

abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object> get props => [];
}

class ConnectivityStatusChanged extends ConnectivityEvent {
  final bool isConnected;

  const ConnectivityStatusChanged({required this.isConnected});

  @override
  List<Object> get props => [isConnected];
}

class ConnectivityStatusChecked extends ConnectivityEvent {
  final bool isConnected;

  const ConnectivityStatusChecked({required this.isConnected});

  @override
  List<Object> get props => [isConnected];
}