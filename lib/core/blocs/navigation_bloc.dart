import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'base_bloc.dart';

enum NavigationTab {
  map(0, Icons.map, 'Map'),
  feed(1, Icons.rss_feed, 'Feed'),
  orders(2, Icons.shopping_bag, 'Orders'),
  chat(3, Icons.chat, 'Chat'),
  profile(4, Icons.person, 'Profile');

  const NavigationTab(this.index, this.icon, this.label);

  final int index;
  final IconData icon;
  final String label;

  static NavigationTab fromIndex(int index) {
    return NavigationTab.values.firstWhere(
      (tab) => tab.index == index,
      orElse: () => NavigationTab.map,
    );
  }

  static List<NavigationTab> get navigationTabs => [
        map,
        feed,
        chat,
        profile,
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
  }

  void _onTabChanged(NavigationTabChanged event, Emitter<NavigationState> emit) {
    emit(state.copyWith(currentTab: event.tab));
  }

  void _onStateChanged(NavigationStateChanged event, Emitter<NavigationState> emit) {
    emit(event.state);
  }

  void selectTab(NavigationTab tab) {
    add(NavigationTabChanged(tab));
  }

  void updateActiveOrderCount(int count) {
    emit(state.copyWith(activeOrderCount: count));
  }

  void updateUnreadChatCount(int count) {
    emit(state.copyWith(unreadChatCount: count));
  }
}