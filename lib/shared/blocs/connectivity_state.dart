part of 'connectivity_bloc.dart';

abstract class ConnectivityState extends Equatable {
  const ConnectivityState();

  @override
  List<Object> get props => [];
}

class ConnectivityInitial extends ConnectivityState {
  const ConnectivityInitial();
}

class ConnectivityChanged extends ConnectivityState {
  final bool isConnected;

  const ConnectivityChanged({required this.isConnected});

  @override
  List<Object> get props => [isConnected];
}

extension ConnectivityStateX on ConnectivityState {
  bool get isConnected => this is ConnectivityChanged && (this as ConnectivityChanged).isConnected;
}