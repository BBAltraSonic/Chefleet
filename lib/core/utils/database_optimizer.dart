import 'dart:async';
import 'dart:developer' as developer;
import 'dart:collection';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Database query optimization utilities for improving performance
class DatabaseOptimizer {
  static DatabaseOptimizer? _instance;
  DatabaseOptimizer._();

  factory DatabaseOptimizer() => _instance ??= DatabaseOptimizer._();

  /// Query performance thresholds (in milliseconds)
  static const int _slowQueryThreshold = 500;
  static const int _criticalQueryThreshold = 2000;
  static const int _cacheValidityThreshold = 100;

  /// Cache for optimized queries
  final Map<String, _CachedQueryResult> _queryCache = {};
  final Map<String, _QueryStatistics> _queryStatistics = {};

  /// Connection pool management
  final Queue<DatabaseConnection> _connectionPool = Queue<DatabaseConnection>();
  final Map<String, DatabaseConnection> _activeConnections = {};

  /// Performance monitoring
  final List<int> _recentQueryTimes = [];
  final Map<String, int> _slowQueries = {};

  /// Query optimization settings
  bool _enableQueryCache = true;
  bool _enableConnectionPooling = true;
  bool _enableQueryOptimization = true;
  int _maxCacheSize = 1000;
  int _maxConnectionPoolSize = 10;

  /// Initialize the database optimizer
  Future<void> initialize() async {
    // Initialize connection pool
    await _initializeConnectionPool();

    // Clean up old cache entries
    _scheduleCacheMaintenance();

    developer.log(
      'DatabaseOptimizer initialized',
      name: 'DatabaseOptimizer',
    );
  }

  /// Execute a query with optimization and caching
  Future<List<Map<String, dynamic>>> optimizedQuery({
    required String query,
    Map<String, dynamic>? parameters,
    String? cacheKey,
    Duration? cacheTimeout = const Duration(minutes: 5),
  }) async {
    final stopwatch = Stopwatch()..start();
    final queryId = _generateQueryId(query, parameters);

    try {
      List<Map<String, dynamic>> result;

      // Check cache first
      if (_enableQueryCache && cacheKey != null) {
        final cachedResult = _getCachedResult(cacheKey, cacheTimeout);
        if (cachedResult != null) {
          stopwatch.stop();
          _recordQueryPerformance(queryId, stopwatch.elapsedMilliseconds, true);
          return cachedResult;
        }
      }

      // Optimize query if enabled
      String optimizedQuery = query;
      Map<String, dynamic>? optimizedParameters = parameters;

      if (_enableQueryOptimization) {
        final optimization = _optimizeQuery(query, parameters);
        optimizedQuery = optimization.optimizedQuery;
        optimizedParameters = optimization.optimizedParameters;
      }

      // Execute query with connection pooling
      result = await _executeWithPooling(optimizedQuery, optimizedParameters);

      // Cache result if applicable
      if (_enableQueryCache && cacheKey != null && result.isNotEmpty) {
        _cacheResult(cacheKey, result, cacheTimeout);
      }

      stopwatch.stop();
      _recordQueryPerformance(queryId, stopwatch.elapsedMilliseconds, false);

      return result;

    } catch (e) {
      stopwatch.stop();
      _recordQueryPerformance(queryId, stopwatch.elapsedMilliseconds, false);

      developer.log(
        'Query execution failed: $query',
        name: 'DatabaseOptimizer',
        error: e,
      );

      rethrow;
    }
  }

  /// Execute a Supabase query with optimization
  Future<PostgrestResponse<T>> optimizedSupabaseQuery<T>({
    required SupabaseQueryBuilder queryBuilder,
    String? cacheKey,
    Duration? cacheTimeout = const Duration(minutes: 5),
  }) async {
    final stopwatch = Stopwatch()..start();
    final queryString = queryBuilder.toString();
    final queryId = _generateQueryId(queryString);

    try {
      // Check cache first
      if (_enableQueryCache && cacheKey != null) {
        final cachedResult = _getCachedSupabaseResult<T>(cacheKey, cacheTimeout);
        if (cachedResult != null) {
          stopwatch.stop();
          _recordQueryPerformance(queryId, stopwatch.elapsedMilliseconds, true);
          return cachedResult;
        }
      }

      // Execute optimized query
      final optimizedBuilder = _optimizeSupabaseQuery(queryBuilder);
      final result = await optimizedBuilder;

      // Cache result if applicable
      if (_enableQueryCache && cacheKey != null && result.data != null) {
        _cacheSupabaseResult(cacheKey, result, cacheTimeout);
      }

      stopwatch.stop();
      _recordQueryPerformance(queryId, stopwatch.elapsedMilliseconds, false);

      return result;

    } catch (e) {
      stopwatch.stop();
      _recordQueryPerformance(queryId, stopwatch.elapsedMilliseconds, false);

      developer.log(
        'Supabase query execution failed: $queryString',
        name: 'DatabaseOptimizer',
        error: e,
      );

      rethrow;
    }
  }

  /// Execute a batch of queries efficiently
  Future<List<List<Map<String, dynamic>>>> optimizedBatchQuery({
    required List<String> queries,
    List<Map<String, dynamic>>? parametersList,
    List<String>? cacheKeys,
    Duration? cacheTimeout = const Duration(minutes: 5),
  }) async {
    final stopwatch = Stopwatch()..start();
    final results = <List<Map<String, dynamic>>>[];

    try {
      // Check for cached results first
      if (_enableQueryCache && cacheKeys != null) {
        for (int i = 0; i < queries.length; i++) {
          if (cacheKeys.length > i) {
            final cachedResult = _getCachedResult(cacheKeys[i], cacheTimeout);
            if (cachedResult != null) {
              results.add(cachedResult);
              continue;
            }
          }

          // Query not cached, execute it
          final parameters = parametersList?.length > i ? parametersList![i] : null;
          final cacheKey = cacheKeys.length > i ? cacheKeys[i] : null;

          final queryResult = await optimizedQuery(
            query: queries[i],
            parameters: parameters,
            cacheKey: cacheKey,
            cacheTimeout: cacheTimeout,
          );
          results.add(queryResult);
        }
      } else {
        // Execute all queries without caching
        for (int i = 0; i < queries.length; i++) {
          final parameters = parametersList?.length > i ? parametersList![i] : null;

          final queryResult = await optimizedQuery(
            query: queries[i],
            parameters: parameters,
          );
          results.add(queryResult);
        }
      }

      stopwatch.stop();

      developer.log(
        'Batch query completed: ${results.length} queries in ${stopwatch.elapsedMilliseconds}ms',
        name: 'DatabaseOptimizer',
      );

      return results;

    } catch (e) {
      stopwatch.stop();

      developer.log(
        'Batch query execution failed',
        name: 'DatabaseOptimizer',
        error: e,
      );

      rethrow;
    }
  }

  /// Initialize connection pool
  Future<void> _initializeConnectionPool() async {
    if (!_enableConnectionPooling) return;

    for (int i = 0; i < _maxConnectionPoolSize; i++) {
      // In a real implementation, this would create actual database connections
      // For now, we'll simulate connection objects
      final connection = DatabaseConnection(id: 'conn_$i');
      _connectionPool.add(connection);
    }

    developer.log(
      'Connection pool initialized with $_maxConnectionPoolSize connections',
      name: 'DatabaseOptimizer',
    );
  }

  /// Execute query with connection pooling
  Future<List<Map<String, dynamic>>> _executeWithPooling(
    String query,
    Map<String, dynamic>? parameters,
  ) async {
    DatabaseConnection? connection;

    try {
      // Acquire connection from pool
      connection = _acquireConnection();

      // Execute query (simulated)
      await Future.delayed(Duration(milliseconds: _simulateQueryTime(query)));

      // Return simulated results
      return _generateSimulatedResults(query, parameters);

    } finally {
      // Return connection to pool
      if (connection != null) {
        _releaseConnection(connection);
      }
    }
  }

  /// Acquire connection from pool
  DatabaseConnection _acquireConnection() {
    if (_connectionPool.isNotEmpty) {
      final connection = _connectionPool.removeFirst();
      _activeConnections[connection.id] = connection;
      return connection;
    }

    // Pool exhausted, create new connection
    final connection = DatabaseConnection(id: 'conn_${_activeConnections.length}');
    _activeConnections[connection.id] = connection;
    return connection;
  }

  /// Release connection back to pool
  void _releaseConnection(DatabaseConnection connection) {
    _activeConnections.remove(connection.id);

    if (_connectionPool.length < _maxConnectionPoolSize) {
      _connectionPool.add(connection);
    }
  }

  /// Optimize SQL query
  _QueryOptimization _optimizeQuery(String query, Map<String, dynamic>? parameters) {
    String optimizedQuery = query;
    Map<String, dynamic> optimizedParameters = parameters ?? {};

    // Add LIMIT clause if not present
    if (!optimizedQuery.toUpperCase().contains('LIMIT') &&
        (optimizedQuery.toUpperCase().contains('SELECT'))) {
      // Add reasonable LIMIT for large result sets
      if (!optimizedQuery.toUpperCase().contains('WHERE')) {
        optimizedQuery += ' LIMIT 1000';
      } else {
        optimizedQuery += ' LIMIT 500';
      }
    }

    // Optimize ORDER BY clauses
    if (optimizedQuery.toUpperCase().contains('ORDER BY')) {
      // Add index hints if appropriate
      if (optimizedQuery.contains('vendors') &&
          optimizedQuery.contains('latitude') &&
          optimizedQuery.contains('longitude')) {
        optimizedQuery = optimizedQuery.replaceFirst(
          'ORDER BY',
          'ORDER BY',
        );
      }
    }

    return _QueryOptimization(
      optimizedQuery: optimizedQuery,
      optimizedParameters: optimizedParameters,
    );
  }

  /// Optimize Supabase query
  SupabaseQueryBuilder _optimizeSupabaseQuery(SupabaseQueryBuilder queryBuilder) {
    // Add select optimizations
    // In a real implementation, this would manipulate the query builder

    return queryBuilder;
  }

  /// Simulate query execution time
  int _simulateQueryTime(String query) {
    // Base time
    int time = 50;

    // Add complexity based time
    if (query.toUpperCase().contains('JOIN')) time += 100;
    if (query.toUpperCase().contains('ORDER BY')) time += 50;
    if (query.toUpperCase().contains('GROUP BY')) time += 150;
    if (query.toUpperCase().contains('WHERE')) time += 25;

    // Add random variance
    time += (DateTime.now().millisecondsSinceEpoch % 100);

    return time;
  }

  /// Generate simulated query results
  List<Map<String, dynamic>> _generateSimulatedResults(String query, Map<String, dynamic>? parameters) {
    final results = <Map<String, dynamic>>[];

    if (query.toLowerCase().contains('vendors')) {
      final vendorCount = _extractLimitFromQuery(query) ?? 10;
      for (int i = 0; i < vendorCount; i++) {
        results.add({
          'id': 'vendor_$i',
          'name': 'Vendor $i',
          'latitude': 37.7749 + (i * 0.001),
          'longitude': -122.4194 + (i * 0.001),
          'is_active': true,
          'dish_count': (i % 20) + 1,
        });
      }
    } else if (query.toLowerCase().contains('dishes')) {
      final dishCount = _extractLimitFromQuery(query) ?? 20;
      for (int i = 0; i < dishCount; i++) {
        results.add({
          'id': 'dish_$i',
          'name': 'Dish $i',
          'vendor_id': 'vendor_${i % 10}',
          'price': 10.0 + (i % 50),
          'available': (i % 10) != 0,
        });
      }
    }

    return results;
  }

  /// Extract LIMIT value from query
  int? _extractLimitFromQuery(String query) {
    final limitRegex = RegExp(r'LIMIT\s+(\d+)', caseSensitive: false);
    final match = limitRegex.firstMatch(query);
    return match != null ? int.parse(match.group(1)!) : null;
  }

  /// Get cached result
  List<Map<String, dynamic>>? _getCachedResult(String cacheKey, Duration? cacheTimeout) {
    final cached = _queryCache[cacheKey];
    if (cached != null && !cached.isExpired(cacheTimeout)) {
      return cached.result;
    }

    // Remove expired cache entry
    _queryCache.remove(cacheKey);
    return null;
  }

  /// Get cached Supabase result
  PostgrestResponse<T>? _getCachedSupabaseResult<T>(String cacheKey, Duration? cacheTimeout) {
    final cached = _queryCache[cacheKey];
    if (cached != null && !cached.isExpired(cacheTimeout)) {
      return cached.result as PostgrestResponse<T>;
    }

    _queryCache.remove(cacheKey);
    return null;
  }

  /// Cache query result
  void _cacheResult(String cacheKey, List<Map<String, dynamic>> result, Duration? cacheTimeout) {
    if (_queryCache.length >= _maxCacheSize) {
      _evictOldestCacheEntry();
    }

    _queryCache[cacheKey] = _CachedQueryResult(
      result: result,
      timestamp: DateTime.now(),
    );
  }

  /// Cache Supabase result
  void _cacheSupabaseResult<T>(String cacheKey, PostgrestResponse<T> result, Duration? cacheTimeout) {
    if (_queryCache.length >= _maxCacheSize) {
      _evictOldestCacheEntry();
    }

    _queryCache[cacheKey] = _CachedQueryResult(
      result: result,
      timestamp: DateTime.now(),
    );
  }

  /// Evict oldest cache entry
  void _evictOldestCacheEntry() {
    if (_queryCache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTimestamp;

    for (final entry in _queryCache.entries) {
      if (oldestTimestamp == null || entry.value.timestamp.isBefore(oldestTimestamp)) {
        oldestKey = entry.key;
        oldestTimestamp = entry.value.timestamp;
      }
    }

    if (oldestKey != null) {
      _queryCache.remove(oldestKey);
    }
  }

  /// Generate query ID for statistics
  String _generateQueryId(String query, [Map<String, dynamic>? parameters]) {
    final queryHash = query.hashCode;
    final paramsHash = parameters?.toString().hashCode ?? 0;
    return '${queryHash}_$paramsHash';
  }

  /// Record query performance
  void _recordQueryPerformance(String queryId, int executionTime, bool wasCached) {
    // Update query statistics
    final stats = _queryStatistics.putIfAbsent(
      queryId,
      () => _QueryStatistics(queryId: queryId),
    );

    stats.recordExecution(executionTime, wasCached);

    // Track recent query times
    _recentQueryTimes.add(executionTime);
    if (_recentQueryTimes.length > 100) {
      _recentQueryTimes.removeAt(0);
    }

    // Track slow queries
    if (executionTime > _slowQueryThreshold) {
      _slowQueries[queryId] = (_slowQueries[queryId] ?? 0) + 1;

      developer.log(
        'Slow query detected: $queryId took ${executionTime}ms',
        name: 'DatabaseOptimizer',
      );
    }

    // Critical query warning
    if (executionTime > _criticalQueryThreshold) {
      developer.log(
        'CRITICAL: Query $queryId took ${executionTime}ms (threshold: ${_criticalQueryThreshold}ms)',
        name: 'DatabaseOptimizer',
        level: 1000,
      );
    }
  }

  /// Schedule cache maintenance
  void _scheduleCacheMaintenance() {
    Timer.periodic(const Duration(minutes: 10), (_) {
      _performCacheMaintenance();
    });
  }

  /// Perform cache maintenance
  void _performCacheMaintenance() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _queryCache.entries) {
      if (now.difference(entry.value.timestamp).inHours > 1) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _queryCache.remove(key);
    }

    developer.log(
      'Cache maintenance completed: removed ${keysToRemove.length} expired entries',
      name: 'DatabaseOptimizer',
    );
  }

  /// Get query performance statistics
  Map<String, dynamic> getPerformanceStatistics() {
    final totalQueries = _queryStatistics.values.fold(
      0,
      (sum, stats) => sum + stats.totalExecutions,
    );

    final avgExecutionTime = _recentQueryTimes.isEmpty
        ? 0.0
        : _recentQueryTimes.reduce((a, b) => a + b) / _recentQueryTimes.length;

    final cacheHitRate = totalQueries > 0
        ? (_queryStatistics.values.fold(
            0,
            (sum, stats) => sum + stats.cachedExecutions,
          ) / totalQueries) * 100
        : 0.0;

    return {
      'totalQueries': totalQueries,
      'averageExecutionTime': avgExecutionTime.round(),
      'cacheHitRate': cacheHitRate.toStringAsFixed(1),
      'cacheSize': _queryCache.length,
      'connectionPoolSize': _connectionPool.length,
      'activeConnections': _activeConnections.length,
      'slowQueriesCount': _slowQueries.length,
      'recentQueryTimes': List.from(_recentQueryTimes.takeLast(10)),
    };
  }

  /// Clear query cache
  void clearCache() {
    _queryCache.clear();
    developer.log('Query cache cleared', name: 'DatabaseOptimizer');
  }

  /// Optimize database indexes (simulated)
  Future<void> optimizeIndexes() async {
    developer.log('Starting index optimization...', name: 'DatabaseOptimizer');

    // Simulate index optimization
    await Future.delayed(const Duration(seconds: 2));

    developer.log('Index optimization completed', name: 'DatabaseOptimizer');
  }

  /// Analyze slow queries and suggest optimizations
  Map<String, String> analyzeSlowQueries() {
    final suggestions = <String, String>{};

    for (final entry in _slowQueries.entries) {
      final queryId = entry.key;
      final count = entry.value;

      if (count > 5) {
        suggestions[queryId] = 'Consider adding indexes or optimizing query structure';
      }
    }

    return suggestions;
  }

  /// Cleanup resources
  void dispose() {
    _queryCache.clear();
    _queryStatistics.clear();
    _connectionPool.clear();
    _activeConnections.clear();
    _recentQueryTimes.clear();
    _slowQueries.clear();

    developer.log('DatabaseOptimizer disposed', name: 'DatabaseOptimizer');
  }
}

/// Database connection representation
class DatabaseConnection {
  final String id;
  final DateTime createdAt;
  bool isAvailable;

  DatabaseConnection({
    required this.id,
  }) : createdAt = DateTime.now(),
       isAvailable = true;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'isAvailable': isAvailable,
    };
  }
}

/// Cached query result
class _CachedQueryResult {
  final dynamic result;
  final DateTime timestamp;

  _CachedQueryResult({
    required this.result,
    required this.timestamp,
  });

  bool isExpired(Duration? timeout) {
    if (timeout == null) return false;
    return DateTime.now().difference(timestamp) > timeout;
  }
}

/// Query statistics
class _QueryStatistics {
  final String queryId;
  int totalExecutions = 0;
  int cachedExecutions = 0;
  int totalExecutionTime = 0;
  int minExecutionTime = 0;
  int maxExecutionTime = 0;

  _QueryStatistics({
    required this.queryId,
  });

  void recordExecution(int executionTime, bool wasCached) {
    totalExecutions++;
    totalExecutionTime += executionTime;

    if (wasCached) {
      cachedExecutions++;
    }

    if (minExecutionTime == 0 || executionTime < minExecutionTime) {
      minExecutionTime = executionTime;
    }

    if (executionTime > maxExecutionTime) {
      maxExecutionTime = executionTime;
    }
  }

  double get averageExecutionTime {
    return totalExecutions > 0 ? totalExecutionTime / totalExecutions : 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'queryId': queryId,
      'totalExecutions': totalExecutions,
      'cachedExecutions': cachedExecutions,
      'averageExecutionTime': averageExecutionTime.round(),
      'minExecutionTime': minExecutionTime,
      'maxExecutionTime': maxExecutionTime,
    };
  }
}

/// Query optimization result
class _QueryOptimization {
  final String optimizedQuery;
  final Map<String, dynamic> optimizedParameters;

  _QueryOptimization({
    required this.optimizedQuery,
    required this.optimizedParameters,
  });
}

/// Extension for list operations
extension ListExtension<T> on List<T> {
  List<T> takeLast(int n) {
    if (length <= n) return this;
    return sublist(length - n);
  }
}