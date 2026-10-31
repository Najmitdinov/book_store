import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/widgets/common.dart';
import '../../state/load_state.dart';
import '../../state/orders_provider.dart';
import 'order_card.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<OrdersProvider>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();
    final list = orders.orders;

    Widget body;
    if ((orders.status == LoadStatus.idle || orders.isLoading) &&
        list.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (orders.hasError && list.isEmpty) {
      body = ErrorView(code: orders.errorCode, onRetry: orders.load);
    } else if (list.isEmpty) {
      body = EmptyState(emoji: '📦', title: context.tr('orders_empty'));
    } else {
      body = RefreshIndicator(
        onRefresh: orders.load,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => OrderCard(order: list[i], initiallyExpanded: i == 0),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('orders_title'))),
      body: body,
    );
  }
}
