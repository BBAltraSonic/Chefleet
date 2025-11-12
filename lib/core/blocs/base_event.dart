abstract class AppEvent {
  const AppEvent();

  @override
  bool operator ==(Object other) => identical(this, other) || other is AppEvent && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}