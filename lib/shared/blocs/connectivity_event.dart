part of 'connectivity_bloc.dart';

abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object> get props => [];
}

class ConnectivityChanged extends ConnectivityEvent {
  final bool isConnected;

  const ConnectivityChanged({required this.isConnected});

  @override
  List<Object> get props => [isConnected];
}

class ConnectivityChecked extends ConnectivityEvent {
  final bool isConnected;

  const ConnectivityChecked({required this.isConnected});

  @override
  List<Object> get props => [isConnected];
}