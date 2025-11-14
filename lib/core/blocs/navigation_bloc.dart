import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'base_bloc.dart';

class NavigationTab {
  const NavigationTab(this.icon, this.label, this.index);

  final IconData icon;
  final String label;
  final int index;

  static const map = NavigationTab(Icons.map, 'Map', 0);
  static const feed = NavigationTab(Icons.rss_feed, 'Feed', 1);
  static const orders = NavigationTab(Icons.shopping_bag, 'Orders', 2);
  static const chat = NavigationTab(Icons.chat, 'Chat', 3);
  static const profile = NavigationTab(Icons.person, 'Profile', 4);

  static const List<NavigationTab> values = [map, feed, orders, chat, profile];
}

// Extension for static methods on NavigationTab
extension NavigationTabExtension on NavigationTab {
  static NavigationTab fromIndex(int index) {
    return NavigationTab.values.firstWhere(
      (tab) => tab.index == index,
      orElse: () => NavigationTab.map,
    );
  }

  static List<NavigationTab> get navigationTabs => [
        NavigationTab.map,
        NavigationTab.feed,
        NavigationTab.chat,
        NavigationTab.profile,
      ];
}

class NavigationEvent extends AppEvent {
  const NavigationEvent();
}

class NavigationTabChanged extends NavigationEvent {
  const NavigationTabChanged(this.tab);

  final NavigationTab tab;

  @override
  List<Object?> get props => [tab];
}

class NavigationStateChanged extends NavigationEvent {
  const NavigationStateChanged(this.state);

  final NavigationState state;

  @override
  List<Object?> get props => [state];
}

class ActiveOrderCountUpdated extends NavigationEvent {
  const ActiveOrderCountUpdated(this.count);

  final int count;

  @override
  List<Object?> get props => [count];
}

class UnreadChatCountUpdated extends NavigationEvent {
  const UnreadChatCountUpdated(this.count);

  final int count;

  @override
  List<Object?> get props => [count];
}

class NavigationState extends AppState {
  const NavigationState({
    this.currentTab = NavigationTab.map,
    this.activeOrderCount = 0,
    this.unreadChatCount = 0,
  });

  final NavigationTab currentTab;
  final int activeOrderCount;
  final int unreadChatCount;

  NavigationState copyWith({
    NavigationTab? currentTab,
    int? activeOrderCount,
    int? unreadChatCount,
  }) {
    return NavigationState(
      currentTab: currentTab ?? this.currentTab,
      activeOrderCount: activeOrderCount ?? this.activeOrderCount,
      unreadChatCount: unreadChatCount ?? this.unreadChatCount,
    );
  }

  @override
  List<Object?> get props => [currentTab, activeOrderCount, unreadChatCount];
}

class NavigationBloc extends AppBloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<NavigationTabChanged>(_onTabChanged);
    on<NavigationStateChanged>(_onStateChanged);
    on<ActiveOrderCountUpdated>(_onActiveOrderCountUpdated);
    on<UnreadChatCountUpdated>(_onUnreadChatCountUpdated);
  }

  void _onTabChanged(NavigationTabChanged event, Emitter<NavigationState> emit) {
    emit(state.copyWith(currentTab: event.tab));
  }

  void _onStateChanged(NavigationStateChanged event, Emitter<NavigationState> emit) {
    emit(event.state);
  }

  void _onActiveOrderCountUpdated(ActiveOrderCountUpdated event, Emitter<NavigationState> emit) {
    emit(state.copyWith(activeOrderCount: event.count));
  }

  void _onUnreadChatCountUpdated(UnreadChatCountUpdated event, Emitter<NavigationState> emit) {
    emit(state.copyWith(unreadChatCount: event.count));
  }

  void selectTab(NavigationTab tab) {
    add(NavigationTabChanged(tab));
  }

  void updateActiveOrderCount(int count) {
    add(ActiveOrderCountUpdated(count));
  }

  void updateUnreadChatCount(int count) {
    add(UnreadChatCountUpdated(count));
  }
}