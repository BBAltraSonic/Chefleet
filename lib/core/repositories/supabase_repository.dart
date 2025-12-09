import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../diagnostics/instrumentation/repository_diagnostics_mixin.dart';
import 'base_repository.dart';
import '../exceptions/app_exceptions.dart';

abstract class SupabaseRepository<T> extends DataRepository<T>
    with RepositoryDiagnosticsMixin {
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
  Future<List<T>> getAll() {
    return runRepositorySpan<List<T>>(
      'getAll',
      () async {
        try {
          final response = await client.from(tableName).select();
          return (response as List<dynamic>)
              .map((item) => fromMap(item as Map<String, dynamic>))
              .toList();
        } catch (e) {
          throw _handleException(e);
        }
      },
      payload: {'table': tableName},
      onSuccess: (result) => {'count': result.length},
    );
  }

  @override
  Future<T?> getById(String id) {
    return runRepositorySpan<T?>(
      'getById',
      () async {
        try {
          final response = await client.from(tableName).select().eq('id', id).single();
          return fromMap(response);
        } catch (e) {
          throw _handleException(e);
        }
      },
      correlationId: id,
      payload: {'table': tableName},
    );
  }

  @override
  Future<T> create(T item) {
    return runRepositorySpan<T>(
      'create',
      () async {
        try {
          final mapData = toMap(item);
          final response =
              await client.from(tableName).insert(mapData).select().single();
          return fromMap(response);
        } catch (e) {
          throw _handleException(e);
        }
      },
      payload: {'table': tableName},
    );
  }

  @override
  Future<T> update(T item) {
    return runRepositorySpan<T>(
      'update',
      () async {
        try {
          final mapData = toMap(item);
          final response = await client
              .from(tableName)
              .update(mapData)
              .eq('id', mapData['id'])
              .select()
              .single();
          return fromMap(response);
        } catch (e) {
          throw _handleException(e);
        }
      },
      correlationId: toMap(item)['id']?.toString(),
      payload: {'table': tableName},
    );
  }

  @override
  Future<void> delete(String id) {
    return runRepositorySpan<void>(
      'delete',
      () async {
        try {
          await client.from(tableName).delete().eq('id', id);
        } catch (e) {
          throw _handleException(e);
        }
      },
      correlationId: id,
      payload: {'table': tableName},
    );
  }

  @override
  Future<List<T>> search(Map<String, dynamic> query) {
    return runRepositorySpan<List<T>>(
      'search',
      () async {
        try {
          var queryBuilder = client.from(tableName).select();

          for (final entry in query.entries) {
            queryBuilder = queryBuilder.eq(entry.key, entry.value);
          }

          final response = await queryBuilder;
          return (response as List<dynamic>)
              .map((item) => fromMap(item as Map<String, dynamic>))
              .toList();
        } catch (e) {
          throw _handleException(e);
        }
      },
      payload: {
        'table': tableName,
        'filters': query.map((key, value) => MapEntry(key, value.toString())),
      },
      onSuccess: (result) => {'count': result.length},
    );
  }

  T fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap(T item);

  Exception _handleException(dynamic error) {
    if (error is PostgrestException) {
      return ServerException(error.message);
    } else if (error is AuthException) {
      return error;
    } else {
      return UnknownException(error.toString());
    }
  }
}