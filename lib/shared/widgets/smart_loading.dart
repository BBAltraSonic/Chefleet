import 'package:flutter/material.dart';

/// Smart loading widget that shows loading indicator only if operation takes longer than threshold.
///
/// This prevents loading indicator flicker for fast operations (<300ms by default).
/// Use this for operations that may complete quickly but could take longer.
///
/// Example:
/// ```dart
/// SmartLoading<List<Order>>(
///   future: ordersRepository.fetchOrders(),
///   threshold: Duration(milliseconds: 300),
///   builder: (context, data) => OrdersList(orders: data),
///   loadingBuilder: (context) => OrdersSkeletonLoader(),
///   errorBuilder: (context, error) => ErrorDisplay(error: error),
/// )
/// ```
class SmartLoading<T> extends StatefulWidget {
  const SmartLoading({
    super.key,
    required this.future,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.threshold = const Duration(milliseconds: 300),
    this.initialData,
  });

  /// The async operation to execute
  final Future<T> future;

  /// Builder for displaying the data when loaded
  final Widget Function(BuildContext context, T data) builder;

  /// Optional custom loading widget (defaults to CircularProgressIndicator)
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Optional custom error widget (defaults to error message text)
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Threshold duration before showing loading indicator (default: 300ms)
  final Duration threshold;

  /// Optional initial data to display while loading
  final T? initialData;

  @override
  State<SmartLoading<T>> createState() => _SmartLoadingState<T>();
}

class _SmartLoadingState<T> extends State<SmartLoading<T>> {
  late Future<T> _future;
  bool _showLoading = false;
  T? _data;
  Object? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
    _future = widget.future;
    _startLoadingWithThreshold();
  }

  @override
  void didUpdateWidget(SmartLoading<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.future != widget.future) {
      _data = widget.initialData;
      _error = null;
      _isLoading = true;
      _showLoading = false;
      _future = widget.future;
      _startLoadingWithThreshold();
    }
  }

  Future<void> _startLoadingWithThreshold() async {
    // Start threshold timer
    Future.delayed(widget.threshold).then((_) {
      if (_isLoading && mounted) {
        setState(() {
          _showLoading = true;
        });
      }
    });

    // Execute the future
    try {
      final result = await _future;
      if (mounted) {
        setState(() {
          _data = result;
          _error = null;
          _isLoading = false;
          _showLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _isLoading = false;
          _showLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show error if present
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error!);
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error: ${_error.toString()}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Show data if loaded
    if (!_isLoading && _data != null) {
      return widget.builder(context, _data as T);
    }

    // Show initial data while loading (if provided)
    if (_isLoading && _data != null) {
      return widget.builder(context, _data as T);
    }

    // Show loading indicator only after threshold
    if (_showLoading) {
      if (widget.loadingBuilder != null) {
        return widget.loadingBuilder!(context);
      }
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Don't show anything while within threshold period
    return const SizedBox.shrink();
  }
}

/// Simplified version of SmartLoading for common use cases
class SmartLoadingBuilder<T> extends StatelessWidget {
  const SmartLoadingBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.threshold = const Duration(milliseconds: 300),
  });

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final Duration threshold;

  @override
  Widget build(BuildContext context) {
    return SmartLoading<T>(
      future: future,
      builder: builder,
      threshold: threshold,
    );
  }
}

/// Stream-based version of SmartLoading for real-time data
class SmartStreamLoading<T> extends StatefulWidget {
  const SmartStreamLoading({
    super.key,
    required this.stream,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.threshold = const Duration(milliseconds: 300),
    this.initialData,
  });

  final Stream<T> stream;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Duration threshold;
  final T? initialData;

  @override
  State<SmartStreamLoading<T>> createState() => _SmartStreamLoadingState<T>();
}

class _SmartStreamLoadingState<T> extends State<SmartStreamLoading<T>> {
  bool _showLoading = false;
  bool _hasReceivedData = false;

  @override
  void initState() {
    super.initState();
    _startThresholdTimer();
  }

  void _startThresholdTimer() {
    Future.delayed(widget.threshold).then((_) {
      if (!_hasReceivedData && mounted) {
        setState(() {
          _showLoading = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: widget.stream,
      initialData: widget.initialData,
      builder: (context, snapshot) {
        // Update loading state when data arrives
        if (snapshot.hasData && !_hasReceivedData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _hasReceivedData = true;
                _showLoading = false;
              });
            }
          });
        }

        // Show error
        if (snapshot.hasError) {
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(context, snapshot.error!);
          }
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        // Show data
        if (snapshot.hasData) {
          return widget.builder(context, snapshot.data as T);
        }

        // Show loading only after threshold
        if (_showLoading) {
          if (widget.loadingBuilder != null) {
            return widget.loadingBuilder!(context);
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}





