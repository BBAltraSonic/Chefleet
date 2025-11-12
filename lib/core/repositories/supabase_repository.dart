import 'package:supabase_flutter/supabase_flutter.dart';
import 'base_repository.dart';
import '../exceptions/app_exceptions.dart';

abstract class SupabaseRepository<T> extends DataRepository<T> {
  SupabaseRepository(this.client);

  final SupabaseClient client;
  late final String tableName;

  @override
  Future<void> initialize() async {
    // Initialize any necessary resources
  }

  @override
  Future<void> dispose() async {
    // Dispose any resources
  }

  @override
  Future<List<T>> getAll() async {
    try {
      final response = await client.from(tableName).select();
      return (response as List<dynamic>).map((item) => fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<T?> getById(String id) async {
    try {
      final response = await client.from(tableName).select().eq('id', id).single();
      return fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<T> create(T item) async {
    try {
      final mapData = toMap(item);
      final response = await client.from(tableName).insert(mapData).select().single();
      return fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<T> update(T item) async {
    try {
      final mapData = toMap(item);
      final response = await client.from(tableName).update(mapData).eq('id', mapData['id']).select().single();
      return fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await client.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<List<T>> search(Map<String, dynamic> query) async {
    try {
      var queryBuilder = client.from(tableName).select();

      for (final entry in query.entries) {
        queryBuilder = queryBuilder.eq(entry.key, entry.value);
      }

      final response = await queryBuilder;
      return (response as List<dynamic>).map((item) => fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _handleException(e);
    }
  }

  T fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap(T item);

  Exception _handleException(dynamic error) {
    if (error is PostgException) {
      return ServerException(error.message);
    } else if (error is AuthException) {
      return AuthException(error.message);
    } else {
      return UnknownException(error.toString());
    }
  }
}