import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:chefleet/core/blocs/navigation_bloc.dart';

void main() {
  group('NavigationBloc Tests (Post Bottom-Nav Removal)', () {
    late NavigationBloc navigationBloc;

    setUp(() {
      navigationBloc = NavigationBloc();
    });

    tearDown(() {
      navigationBloc.close();
    });

    test('initial state should be map tab', () {
      expect(navigationBloc.state.currentTab, NavigationTab.map);
      expect(navigationBloc.state.activeOrderCount, 0);
      expect(navigationBloc.state.unreadChatCount, 0);
    });

    test('NavigationTab should not include feed or chat tabs', () {
      final availableTabs = NavigationTab.values;
      
      // Verify feed and chat are not in available tabs
      expect(
        availableTabs.any((tab) => tab.name == 'feed'),
        false,
        reason: 'Feed tab should be removed after bottom nav removal',
      );
      expect(
        availableTabs.any((tab) => tab.name == 'chat'),
        false,
        reason: 'Chat tab should be removed after bottom nav removal',
      );
    });

    blocTest<NavigationBloc, NavigationState>(
      'selectTab should change current tab to map',
      build: () => navigationBloc,
      act: (bloc) => bloc.add(const NavigationTabSelected(NavigationTab.map)),
      expect: () => [
        const NavigationState(
          currentTab: NavigationTab.map,
          activeOrderCount: 0,
          unreadChatCount: 0,
        ),
      ],
    );

    blocTest<NavigationBloc, NavigationState>(
      'selectTab should change current tab to profile',
      build: () => navigationBloc,
      act: (bloc) => bloc.add(const NavigationTabSelected(NavigationTab.profile)),
      expect: () => [
        const NavigationState(
          currentTab: NavigationTab.profile,
          activeOrderCount: 0,
          unreadChatCount: 0,
        ),
      ],
    );

    blocTest<NavigationBloc, NavigationState>(
      'activeOrderCountUpdated should update count',
      build: () => navigationBloc,
      act: (bloc) => bloc.add(const NavigationActiveOrderCountUpdated(3)),
      expect: () => [
        const NavigationState(
          currentTab: NavigationTab.map,
          activeOrderCount: 3,
          unreadChatCount: 0,
        ),
      ],
    );

    blocTest<NavigationBloc, NavigationState>(
      'unreadChatCountUpdated should update count',
      build: () => navigationBloc,
      act: (bloc) => bloc.add(const NavigationUnreadChatCountUpdated(5)),
      expect: () => [
        const NavigationState(
          currentTab: NavigationTab.map,
          activeOrderCount: 0,
          unreadChatCount: 5,
        ),
      ],
    );

    test('NavigationTabExtension.navigationTabs should not include removed tabs', () {
      final navigationTabs = NavigationTabExtension.navigationTabs;
      
      expect(
        navigationTabs.length,
        lessThanOrEqualTo(3),
        reason: 'Should have at most 3 tabs after removing feed and chat',
      );
      
      expect(
        navigationTabs.contains(NavigationTab.map),
        true,
        reason: 'Map tab should be available',
      );
      
      expect(
        navigationTabs.contains(NavigationTab.profile),
        true,
        reason: 'Profile tab should be available',
      );
    });

    test('NavigationTab index values should be sequential', () {
      final tabs = NavigationTab.values;
      for (int i = 0; i < tabs.length; i++) {
        expect(
          tabs[i].index,
          i,
          reason: 'Tab indices should be sequential starting from 0',
        );
      }
    });
  });

  group('NavigationTab Regression Tests', () {
    test('verify no feed tab constant exists', () {
      // This will fail at compile time if feed tab is accidentally re-added
      expect(
        () => NavigationTab.values.firstWhere((tab) => tab.name == 'feed'),
        throwsStateError,
        reason: 'Feed tab should not exist',
      );
    });

    test('verify no chat tab constant exists', () {
      // This will fail at compile time if chat tab is accidentally re-added
      expect(
        () => NavigationTab.values.firstWhere((tab) => tab.name == 'chat'),
        throwsStateError,
        reason: 'Chat tab should not exist',
      );
    });
  });
}
