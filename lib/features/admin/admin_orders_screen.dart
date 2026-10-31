import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/widgets/common.dart';
import '../../data/models/order.dart';
import '../../state/load_state.dart';
import '../../state/orders_provider.dart';
import '../orders/order_card.dart';
import 'manage_books_screen.dart';

/// Admin: barcha foydalanuvchilar buyurtmalari va holatini boshqarish.
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  OrderStatus? _filter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<OrdersProvider>().loadAll(),
    );
  }

  Future<void> _change(Order order, OrderStatus status) async {
    try {
      await context.read<OrdersProvider>().updateStatus(order, status);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final all = provider.allOrders;
    final list =
        _filter == null ? all : all.where((o) => o.status == _filter).toList();

    Widget body;
    if (provider.allStatus != LoadStatus.ready && all.isEmpty) {
      body = provider.allStatus == LoadStatus.error
          ? ErrorView(code: provider.errorCode, onRetry: provider.loadAll)
          : const Center(child: CircularProgressIndicator());
    } else if (list.isEmpty) {
      body = EmptyState(emoji: '📦', title: context.tr('orders_empty'));
    } else {
      body = RefreshIndicator(
        onRefresh: provider.loadAll,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final order = list[i];
            return OrderCard(
              order: order,
              trailing: Row(
                children: [
                  Text(
                    context.tr('change_status'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  DropdownButton<OrderStatus>(
                    value: order.status,
                    borderRadius: BorderRadius.circular(14),
                    underline: const SizedBox.shrink(),
                    items: OrderStatus.values
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: StatusPill(status: s),
                            ))
                        .toList(),
                    onChanged: (s) {
                      if (s != null && s != order.status) _change(order, s);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(title: Text(context.tr('all_orders'))),
        body: Column(
          children: [
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('${context.tr('all')} (${all.length})'),
                      selected: _filter == null,
                      onSelected: (_) => setState(() => _filter = null),
                    ),
                  ),
                  for (final s in OrderStatus.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          '${context.tr(s.labelKey)} '
                          '(${all.where((o) => o.status == s).length})',
                        ),
                        selected: _filter == s,
                        onSelected: (_) => setState(() => _filter = s),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
