import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/blocs/auth_bloc.dart';
import '../blocs/active_orders_bloc.dart';
import 'active_order_fab.dart';

class ActiveOrderManager extends StatefulWidget {
  final Widget child;

  const ActiveOrderManager({
    super.key,
    required this.child,
  });

  @override
  State<ActiveOrderManager> createState() => _ActiveOrderManagerState();
}

class _ActiveOrderManagerState extends State<ActiveOrderManager> {
  late final ActiveOrdersBloc _activeOrdersBloc;

  @override
  void initState() {
    super.initState();
    _activeOrdersBloc = ActiveOrdersBloc(
      supabaseClient: Supabase.instance.client,
      authBloc: context.read<AuthBloc>(),
    );
    _activeOrdersBloc.loadActiveOrders();
  }

  @override
  void dispose() {
    _activeOrdersBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _activeOrdersBloc,
      child: Stack(
        children: [
          widget.child,
          const ActiveOrderFAB(),
        ],
      ),
    );
  }
}