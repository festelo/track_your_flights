import 'package:flutter/material.dart';
import 'package:trackyourflights/presentation/pages/home/history/orders_presenter.dart';
import 'package:trackyourflights/presentation/pages/home/history/widgets/order_tile.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';

import 'orders_state.dart';

class OrdersTab extends ConsumerWidget {
  const OrdersTab({Key? key}) : super(key: key);

  ProviderBase<OrdersPresenter> get presenter => ordersContainer.actions;

  ProviderBase<OrdersState> get state => ordersContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CompleteBridge(
      presenter: ref.watch(presenter),
      child: Scaffold(
        floatingActionButton: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(64),
            color: Colors.grey.shade300,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(64),
            onTap: ref.watch(presenter).addOrder,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Text('Add order'),
            ),
          ),
        ),
        body: ListView(
          children: [
            for (final order in ref.watch(state).orders ?? [])
              OrderTile(
                order: order,
              ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
