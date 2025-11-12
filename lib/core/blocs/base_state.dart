abstract class AppState {
  const AppState();

  @override
  bool operator ==(Object other) => identical(this, other) || other is AppState && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}