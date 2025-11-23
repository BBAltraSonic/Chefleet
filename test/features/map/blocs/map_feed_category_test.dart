import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:chefleet/features/map/blocs/map_feed_bloc.dart';
import 'package:chefleet/features/feed/models/dish_model.dart';
import 'package:chefleet/features/feed/models/vendor_model.dart';

void main() {
  group('MapFeedBloc Category Filtering Tests', () {
    late List<Dish> mockDishes;

    setUp(() {
      // Create mock dishes with different tags
      mockDishes = [
        Dish(
          id: '1',
          vendorId: 'vendor1',
          name: 'Spicy Tuna Roll',
          description: 'Fresh tuna with spicy mayo',
          priceCents: 1299,
          prepTimeMinutes: 15,
          available: true,
          tags: ['Sushi', 'Japanese', 'Seafood'],
        ),
        Dish(
          id: '2',
          vendorId: 'vendor1',
          name: 'Classic Cheeseburger',
          description: 'Juicy beef patty with cheese',
          priceCents: 999,
          prepTimeMinutes: 10,
          available: true,
          tags: ['Burger', 'American', 'Fast Food'],
        ),
        Dish(
          id: '3',
          vendorId: 'vendor2',
          name: 'Margherita Pizza',
          description: 'Classic tomato and mozzarella',
          priceCents: 1499,
          prepTimeMinutes: 20,
          available: true,
          tags: ['Pizza', 'Italian'],
        ),
        Dish(
          id: '4',
          vendorId: 'vendor2',
          name: 'Caesar Salad',
          description: 'Crisp romaine with dressing',
          priceCents: 899,
          prepTimeMinutes: 5,
          available: true,
          tags: ['Healthy', 'Salad', 'Vegetarian'],
        ),
        Dish(
          id: '5',
          vendorId: 'vendor3',
          name: 'Chocolate Cake',
          description: 'Rich chocolate dessert',
          priceCents: 699,
          prepTimeMinutes: 5,
          available: true,
          tags: ['Dessert', 'Sweet'],
        ),
        Dish(
          id: '6',
          vendorId: 'vendor3',
          name: 'California Roll',
          description: 'Crab and avocado roll',
          priceCents: 1099,
          prepTimeMinutes: 12,
          available: true,
          tags: ['Sushi', 'Japanese'],
        ),
      ];
    });

    test('initial state has All category selected', () {
      final bloc = MapFeedBloc();
      expect(bloc.state.selectedCategory, 'All');
      bloc.close();
    });

    blocTest<MapFeedBloc, MapFeedState>(
      'emits filtered dishes when Sushi category is selected',
      build: () => MapFeedBloc(),
      seed: () => MapFeedState(
        allDishes: mockDishes,
        dishes: mockDishes,
      ),
      act: (bloc) => bloc.add(const MapCategorySelected('Sushi')),
      expect: () => [
        isA<MapFeedState>()
            .having((s) => s.selectedCategory, 'selectedCategory', 'Sushi')
            .having((s) => s.dishes.length, 'dishes length', 2)
            .having(
              (s) => s.dishes.every((d) => d.tags.contains('Sushi')),
              'all dishes have Sushi tag',
              true,
            ),
      ],
    );

    blocTest<MapFeedBloc, MapFeedState>(
      'emits filtered dishes when Burger category is selected',
      build: () => MapFeedBloc(),
      seed: () => MapFeedState(
        allDishes: mockDishes,
        dishes: mockDishes,
      ),
      act: (bloc) => bloc.add(const MapCategorySelected('Burger')),
      expect: () => [
        isA<MapFeedState>()
            .having((s) => s.selectedCategory, 'selectedCategory', 'Burger')
            .having((s) => s.dishes.length, 'dishes length', 1)
            .having(
              (s) => s.dishes.first.name,
              'first dish name',
              'Classic Cheeseburger',
            ),
      ],
    );

    blocTest<MapFeedBloc, MapFeedState>(
      'emits filtered dishes when Pizza category is selected',
      build: () => MapFeedBloc(),
      seed: () => MapFeedState(
        allDishes: mockDishes,
        dishes: mockDishes,
      ),
      act: (bloc) => bloc.add(const MapCategorySelected('Pizza')),
      expect: () => [
        isA<MapFeedState>()
            .having((s) => s.selectedCategory, 'selectedCategory', 'Pizza')
            .having((s) => s.dishes.length, 'dishes length', 1)
            .having(
              (s) => s.dishes.first.name,
              'first dish name',
              'Margherita Pizza',
            ),
      ],
    );

    blocTest<MapFeedBloc, MapFeedState>(
      'emits filtered dishes when Healthy category is selected',
      build: () => MapFeedBloc(),
      seed: () => MapFeedState(
        allDishes: mockDishes,
        dishes: mockDishes,
      ),
      act: (bloc) => bloc.add(const MapCategorySelected('Healthy')),
      expect: () => [
        isA<MapFeedState>()
            .having((s) => s.selectedCategory, 'selectedCategory', 'Healthy')
            .having((s) => s.dishes.length, 'dishes length', 1)
            .having(
              (s) => s.dishes.first.name,
              'first dish name',
              'Caesar Salad',
            ),
      ],
    );

    blocTest<MapFeedBloc, MapFeedState>(
      'emits filtered dishes when Dessert category is selected',
      build: () => MapFeedBloc(),
      seed: () => MapFeedState(
        allDishes: mockDishes,
        dishes: mockDishes,
      ),
      act: (bloc) => bloc.add(const MapCategorySelected('Dessert')),
      expect: () => [
        isA<MapFeedState>()
            .having((s) => s.selectedCategory, 'selectedCategory', 'Dessert')
            .having((s) => s.dishes.length, 'dishes length', 1)
            .having(
              (s) => s.dishes.first.name,
              'first dish name',
              'Chocolate Cake',
            ),
      ],
    );

    blocTest<MapFeedState>(
      'emits all dishes when All category is selected',
      build: () => MapFeedBloc(),
      seed: () => MapFeedState(
        allDishes: mockDishes,
        dishes: mockDishes.take(2).toList(), // Start with filtered
        selectedCategory: 'Sushi',
      ),
      act: (bloc) => bloc.add(const MapCategorySelected('All')),
      expect: () => [
        isA<MapFeedState>()
            .having((s) => s.selectedCategory, 'selectedCategory', 'All')
            .having((s) => s.dishes.length, 'dishes length', 6),
      ],
    );

    blocTest<MapFeedBloc, MapFeedState>(
      'filtering is case-insensitive',
      build: () => MapFeedBloc(),
      seed: () => MapFeedState(
        allDishes: mockDishes,
        dishes: mockDishes,
      ),
      act: (bloc) => bloc.add(const MapCategorySelected('sushi')),
      expect: () => [
        isA<MapFeedState>()
            .having((s) => s.selectedCategory, 'selectedCategory', 'sushi')
            .having((s) => s.dishes.length, 'dishes length', 2),
      ],
    );

    blocTest<MapFeedBloc, MapFeedState>(
      'handles category with no matching dishes',
      build: () => MapFeedBloc(),
      seed: () => MapFeedState(
        allDishes: mockDishes,
        dishes: mockDishes,
      ),
      act: (bloc) => bloc.add(const MapCategorySelected('Mexican')),
      expect: () => [
        isA<MapFeedState>()
            .having((s) => s.selectedCategory, 'selectedCategory', 'Mexican')
            .having((s) => s.dishes.length, 'dishes length', 0),
      ],
    );

    blocTest<MapFeedBloc, MapFeedState>(
      'maintains allDishes when filtering',
      build: () => MapFeedBloc(),
      seed: () => MapFeedState(
        allDishes: mockDishes,
        dishes: mockDishes,
      ),
      act: (bloc) => bloc.add(const MapCategorySelected('Pizza')),
      expect: () => [
        isA<MapFeedState>()
            .having((s) => s.allDishes.length, 'allDishes length', 6)
            .having((s) => s.dishes.length, 'dishes length', 1),
      ],
    );

    blocTest<MapFeedBloc, MapFeedState>(
      'can switch between categories',
      build: () => MapFeedBloc(),
      seed: () => MapFeedState(
        allDishes: mockDishes,
        dishes: mockDishes,
      ),
      act: (bloc) {
        bloc.add(const MapCategorySelected('Sushi'));
        bloc.add(const MapCategorySelected('Burger'));
        bloc.add(const MapCategorySelected('All'));
      },
      expect: () => [
        isA<MapFeedState>()
            .having((s) => s.selectedCategory, 'selectedCategory', 'Sushi')
            .having((s) => s.dishes.length, 'dishes length', 2),
        isA<MapFeedState>()
            .having((s) => s.selectedCategory, 'selectedCategory', 'Burger')
            .having((s) => s.dishes.length, 'dishes length', 1),
        isA<MapFeedState>()
            .having((s) => s.selectedCategory, 'selectedCategory', 'All')
            .having((s) => s.dishes.length, 'dishes length', 6),
      ],
    );

    blocTest<MapFeedBloc, MapFeedState>(
      'falls back to name matching for dishes without tags',
      build: () => MapFeedBloc(),
      seed: () {
        final dishesWithoutTags = [
          Dish(
            id: '7',
            vendorId: 'vendor4',
            name: 'Sushi Special',
            description: 'Special sushi combo',
            priceCents: 1999,
            prepTimeMinutes: 20,
            available: true,
            tags: const [], // No tags
          ),
        ];
        return MapFeedState(
          allDishes: dishesWithoutTags,
          dishes: dishesWithoutTags,
        );
      },
      act: (bloc) => bloc.add(const MapCategorySelected('Sushi')),
      expect: () => [
        isA<MapFeedState>()
            .having((s) => s.selectedCategory, 'selectedCategory', 'Sushi')
            .having((s) => s.dishes.length, 'dishes length', 1)
            .having(
              (s) => s.dishes.first.name,
              'first dish name',
              'Sushi Special',
            ),
      ],
    );

    blocTest<MapFeedBloc, MapFeedState>(
      'handles empty allDishes list',
      build: () => MapFeedBloc(),
      seed: () => const MapFeedState(
        allDishes: [],
        dishes: [],
      ),
      act: (bloc) => bloc.add(const MapCategorySelected('Sushi')),
      expect: () => [
        isA<MapFeedState>()
            .having((s) => s.selectedCategory, 'selectedCategory', 'Sushi')
            .having((s) => s.dishes.length, 'dishes length', 0),
      ],
    );

    blocTest<MapFeedBloc, MapFeedState>(
      'preserves other state properties when filtering',
      build: () => MapFeedBloc(),
      seed: () => MapFeedState(
        allDishes: mockDishes,
        dishes: mockDishes,
        isLoading: false,
        currentPage: 1,
        hasMoreData: true,
      ),
      act: (bloc) => bloc.add(const MapCategorySelected('Pizza')),
      expect: () => [
        isA<MapFeedState>()
            .having((s) => s.selectedCategory, 'selectedCategory', 'Pizza')
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.currentPage, 'currentPage', 1)
            .having((s) => s.hasMoreData, 'hasMoreData', true),
      ],
    );

    test('category filtering works with partial tag matches', () {
      final bloc = MapFeedBloc();
      bloc.emit(MapFeedState(
        allDishes: mockDishes,
        dishes: mockDishes,
      ));

      bloc.add(const MapCategorySelected('Japan')); // Partial match

      bloc.stream.listen((state) {
        expect(state.selectedCategory, 'Japan');
        // Should match dishes with 'Japanese' tag
        expect(state.dishes.length, greaterThan(0));
      });

      bloc.close();
    });
  });
}
