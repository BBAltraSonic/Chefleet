import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/order_details_widget.dart';
import '../blocs/order_management_bloc.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderManagementBloc(
        supabaseClient: Supabase.instance.client,
      ),
      child: Scaffold(
        body: SafeArea(
          child: OrderDetailsWidget(
            orderId: orderId,
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}
