import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:chefleet/features/vendor/blocs/menu_management_bloc.dart';
import 'package:chefleet/features/vendor/blocs/menu_management_event.dart';
import 'package:chefleet/features/vendor/blocs/menu_management_state.dart';
import 'package:chefleet/features/feed/models/dish_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockAuth extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  group('MenuManagementBloc', () {
    late MockSupabaseClient mockSupabaseClient;
    late MockAuth mockAuth;
    late MockUser mockUser;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockAuth = MockAuth();
      mockUser = MockUser();

      when(() => mockSupabaseClient.auth).thenReturn(mockAuth);
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.id).thenReturn('test-user-id');
    });

    MenuManagementBloc createBloc() {
      return MenuManagementBloc(supabaseClient: mockSupabaseClient);
    }

    final testDish = Dish(
      id: '1',
      vendorId: 'vendor-1',
      name: 'Test Dish',
      description: 'Test Description',
      priceCents: 1000,
      category: 'Main Course',
      available: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    group('LoadDishes', () {
      blocTest<MenuManagementBloc, MenuManagementState>(
        'emits loading and loaded states when dishes are loaded successfully',
        setUp: () {
          when(() => mockSupabaseClient.from('vendors')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.select('id')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.eq('owner_id', 'test-user-id')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.single()).thenAnswer((_) async => {'id': 'vendor-1'});

          when(() => mockSupabaseClient.from('dishes')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.select()).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.eq('vendor_id', 'vendor-1')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.order('created_at', ascending: false))
              .thenReturn(mockSupabaseClient);

          final dishJson = testDish.toJson();
          when(() => mockSupabaseClient).thenAnswer((_) async => [dishJson]);
        },
        build: createBloc,
        act: (bloc) => bloc.add(const LoadDishes()),
        expect: () => [
          const MenuManagementState(status: MenuManagementStatus.loading),
          MenuManagementState(
            status: MenuManagementStatus.loaded,
            dishes: [testDish],
            filteredDishes: [testDish],
          ),
        ],
      );

      blocTest<MenuManagementBloc, MenuManagementState>(
        'emits error state when loading dishes fails',
        setUp: () {
          when(() => mockSupabaseClient.from('vendors')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.select('id')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.eq('owner_id', 'test-user-id')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.single()).thenThrow(Exception('Failed to load dishes'));
        },
        build: createBloc,
        act: (bloc) => bloc.add(const LoadDishes()),
        expect: () => [
          const MenuManagementState(status: MenuManagementStatus.loading),
          const MenuManagementState(
            status: MenuManagementStatus.error,
            errorMessage: 'Failed to load dishes: Exception: Failed to load dishes',
          ),
        ],
      );

      blocTest<MenuManagementBloc, MenuManagementState>(
        'emits error state when user is not authenticated',
        setUp: () {
          when(() => mockAuth.currentUser).thenReturn(null);
        },
        build: createBloc,
        act: (bloc) => bloc.add(const LoadDishes()),
        expect: () => [
          const MenuManagementState(status: MenuManagementStatus.loading),
          const MenuManagementState(
            status: MenuManagementStatus.error,
            errorMessage: 'User not authenticated',
          ),
        ],
      );
    });

    group('CreateDish', () {
      blocTest<MenuManagementBloc, MenuManagementState>(
        'emits loading and success states when dish is created successfully',
        setUp: () {
          when(() => mockSupabaseClient.from('vendors')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.select('id')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.eq('owner_id', 'test-user-id')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.single()).thenAnswer((_) async => {'id': 'vendor-1'});

          when(() => mockSupabaseClient.from('dishes')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.insert(any())).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.select()).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.single()).thenAnswer((_) async => testDish.toJson());
        },
        build: createBloc,
        act: (bloc) => bloc.add(CreateDish(dish: testDish)),
        expect: () => [
          const MenuManagementState(status: MenuManagementStatus.loading),
          MenuManagementState(
            status: MenuManagementStatus.loaded,
            dishes: [testDish],
            filteredDishes: [testDish],
            lastAction: MenuManagementAction.create,
          ),
        ],
      );

      blocTest<MenuManagementBloc, MenuManagementState>(
        'emits error state when dish creation fails',
        setUp: () {
          when(() => mockSupabaseClient.from('vendors')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.select('id')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.eq('owner_id', 'test-user-id')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.single()).thenAnswer((_) async => {'id': 'vendor-1'});

          when(() => mockSupabaseClient.from('dishes')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.insert(any())).thenThrow(Exception('Creation failed'));
        },
        build: createBloc,
        act: (bloc) => bloc.add(CreateDish(dish: testDish)),
        expect: () => [
          const MenuManagementState(status: MenuManagementStatus.loading),
          const MenuManagementState(
            status: MenuManagementStatus.error,
            errorMessage: 'Failed to create dish: Exception: Creation failed',
          ),
        ],
      );
    });

    group('UpdateDish', () {
      blocTest<MenuManagementBloc, MenuManagementState>(
        'emits loading and success states when dish is updated successfully',
        setUp: () {
          final updatedDish = testDish.copyWith(name: 'Updated Dish');

          when(() => mockSupabaseClient.from('dishes')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.update(any())).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.eq('id', '1')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.select()).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.single()).thenAnswer((_) async => updatedDish.toJson());
        },
        build: createBloc,
        seed: () => MenuManagementState(dishes: [testDish], filteredDishes: [testDish]),
        act: (bloc) => bloc.add(UpdateDish(dish: testDish)),
        expect: () => [
          const MenuManagementState(
            dishes: [testDish],
            filteredDishes: [testDish],
            status: MenuManagementStatus.loading,
          ),
          MenuManagementState(
            dishes: [testDish],
            filteredDishes: [testDish],
            status: MenuManagementStatus.loaded,
            lastAction: MenuManagementAction.update,
          ),
        ],
      );

      blocTest<MenuManagementBloc, MenuManagementState>(
        'emits error state when dish update fails',
        setUp: () {
          when(() => mockSupabaseClient.from('dishes')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.update(any())).thenThrow(Exception('Update failed'));
        },
        build: createBloc,
        seed: () => MenuManagementState(dishes: [testDish], filteredDishes: [testDish]),
        act: (bloc) => bloc.add(UpdateDish(dish: testDish)),
        expect: () => [
          const MenuManagementState(
            dishes: [testDish],
            filteredDishes: [testDish],
            status: MenuManagementStatus.loading,
          ),
          const MenuManagementState(
            dishes: [testDish],
            filteredDishes: [testDish],
            status: MenuManagementStatus.error,
            errorMessage: 'Failed to update dish: Exception: Update failed',
          ),
        ],
      );
    });

    group('DeleteDish', () {
      blocTest<MenuManagementBloc, MenuManagementState>(
        'emits loading and success states when dish is deleted successfully',
        setUp: () {
          when(() => mockSupabaseClient.from('dishes')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.delete()).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.eq('id', '1')).thenReturn(mockSupabaseClient);
        },
        build: createBloc,
        seed: () => MenuManagementState(dishes: [testDish], filteredDishes: [testDish]),
        act: (bloc) => bloc.add(const DeleteDish(dishId: '1')),
        expect: () => [
          const MenuManagementState(
            dishes: [testDish],
            filteredDishes: [testDish],
            status: MenuManagementStatus.loading,
          ),
          const MenuManagementState(
            dishes: [],
            filteredDishes: [],
            status: MenuManagementStatus.loaded,
            lastAction: MenuManagementAction.delete,
          ),
        ],
      );

      blocTest<MenuManagementBloc, MenuManagementState>(
        'emits error state when dish deletion fails',
        setUp: () {
          when(() => mockSupabaseClient.from('dishes')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.delete()).thenThrow(Exception('Delete failed'));
        },
        build: createBloc,
        seed: () => MenuManagementState(dishes: [testDish], filteredDishes: [testDish]),
        act: (bloc) => bloc.add(const DeleteDish(dishId: '1')),
        expect: () => [
          const MenuManagementState(
            dishes: [testDish],
            filteredDishes: [testDish],
            status: MenuManagementStatus.loading,
          ),
          const MenuManagementState(
            dishes: [testDish],
            filteredDishes: [testDish],
            status: MenuManagementStatus.error,
            errorMessage: 'Failed to delete dish: Exception: Delete failed',
          ),
        ],
      );
    });

    group('ToggleDishAvailability', () {
      blocTest<MenuManagementBloc, MenuManagementState>(
        'emits updated state when dish availability is toggled successfully',
        setUp: () {
          final updatedDish = testDish.copyWith(available: false);

          when(() => mockSupabaseClient.from('dishes')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.update(any())).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.eq('id', '1')).thenReturn(mockSupabaseClient);
        },
        build: createBloc,
        seed: () => MenuManagementState(dishes: [testDish], filteredDishes: [testDish]),
        act: (bloc) => bloc.add(ToggleDishAvailability(dish: testDish)),
        expect: () => [
          MenuManagementState(
            dishes: [testDish.copyWith(available: false)],
            filteredDishes: [testDish.copyWith(available: false)],
          ),
        ],
      );

      blocTest<MenuManagementBloc, MenuManagementState>(
        'emits error state when toggle fails',
        setUp: () {
          when(() => mockSupabaseClient.from('dishes')).thenReturn(mockSupabaseClient);
          when(() => mockSupabaseClient.update(any())).thenThrow(Exception('Toggle failed'));
        },
        build: createBloc,
        seed: () => MenuManagementState(dishes: [testDish], filteredDishes: [testDish]),
        act: (bloc) => bloc.add(ToggleDishAvailability(dish: testDish)),
        expect: () => [
          const MenuManagementState(
            dishes: [testDish],
            filteredDishes: [testDish],
            status: MenuManagementStatus.error,
            errorMessage: 'Failed to toggle dish availability: Exception: Toggle failed',
          ),
        ],
      );
    });

    group('SearchDishes', () {
      blocTest<MenuManagementBloc, MenuManagementState>(
        'filters dishes by search query',
        build: createBloc,
        seed: () => MenuManagementState(
          dishes: [
            testDish,
            testDish.copyWith(id: '2', name: 'Pizza'),
            testDish.copyWith(id: '3', name: 'Salad'),
          ],
          filteredDishes: [
            testDish,
            testDish.copyWith(id: '2', name: 'Pizza'),
            testDish.copyWith(id: '3', name: 'Salad'),
          ],
        ),
        act: (bloc) => bloc.add(const SearchDishes(query: 'Pizza')),
        expect: () => [
          MenuManagementState(
            dishes: [
              testDish,
              testDish.copyWith(id: '2', name: 'Pizza'),
              testDish.copyWith(id: '3', name: 'Salad'),
            ],
            filteredDishes: [testDish.copyWith(id: '2', name: 'Pizza')],
            searchQuery: 'Pizza',
          ),
        ],
      );

      blocTest<MenuManagementBloc, MenuManagementState>(
        'returns all dishes when search query is empty',
        build: createBloc,
        seed: () => MenuManagementState(
          dishes: [testDish],
          filteredDishes: [testDish],
          searchQuery: 'Pizza',
        ),
        act: (bloc) => bloc.add(const SearchDishes(query: '')),
        expect: () => [
          MenuManagementState(
            dishes: [testDish],
            filteredDishes: [testDish],
            searchQuery: '',
          ),
        ],
      );
    });

    group('FilterDishes', () {
      final filters = const DishFilters(availableOnly: true);

      blocTest<MenuManagementBloc, MenuManagementState>(
        'filters dishes by availability',
        build: createBloc,
        seed: () => MenuManagementState(
          dishes: [
            testDish,
            testDish.copyWith(id: '2', available: false),
          ],
          filteredDishes: [
            testDish,
            testDish.copyWith(id: '2', available: false),
          ],
        ),
        act: (bloc) => bloc.add(FilterDishes(filters: filters)),
        expect: () => [
          MenuManagementState(
            dishes: [
              testDish,
              testDish.copyWith(id: '2', available: false),
            ],
            filteredDishes: [testDish],
            filters: filters,
          ),
        ],
      );
    });

    group('SortDishes', () {
      blocTest<MenuManagementBloc, MenuManagementState>(
        'sorts dishes by name in ascending order',
        build: createBloc,
        seed: () => MenuManagementState(
          dishes: [
            testDish.copyWith(name: 'Zucchini'),
            testDish.copyWith(id: '2', name: 'Apple'),
          ],
          filteredDishes: [
            testDish.copyWith(name: 'Zucchini'),
            testDish.copyWith(id: '2', name: 'Apple'),
          ],
        ),
        act: (bloc) => bloc.add(const SortDishes(
          sortBy: DishSortOption.name,
          sortOrder: SortOrder.ascending,
        )),
        expect: () => [
          MenuManagementState(
            dishes: [
              testDish.copyWith(name: 'Zucchini'),
              testDish.copyWith(id: '2', name: 'Apple'),
            ],
            filteredDishes: [
              testDish.copyWith(id: '2', name: 'Apple'),
              testDish.copyWith(name: 'Zucchini'),
            ],
            sortBy: DishSortOption.name,
            sortOrder: SortOrder.ascending,
          ),
        ],
      );
    });

    group('RefreshDishes', () {
      blocTest<MenuManagementBloc, MenuManagementState>(
        'dispatches LoadDishes event',
        build: createBloc,
        act: (bloc) => bloc.add(const RefreshDishes()),
        expect: () => [const LoadDishes()],
      );
    });
  });
}