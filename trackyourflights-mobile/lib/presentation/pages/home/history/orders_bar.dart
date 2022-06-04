import 'package:flutter/material.dart';
import 'package:trackyourflights/presentation/pages/home/history/orders_presenter.dart';
import 'package:trackyourflights/presentation/pages/home/history/orders_state.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';

import 'widgets/order_tile.dart';

class OrdersBar extends ConsumerWidget {
  const OrdersBar({Key? key}) : super(key: key);

  ProviderBase<OrdersPresenter> get presenter => ordersContainer.actions;

  ProviderBase<OrdersState> get state => ordersContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CompleteBridge(
      presenter: ref.watch(presenter),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                ),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Orders history',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                IconButton(
                  onPressed: ref.watch(presenter).addOrder,
                  iconSize: 26,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final order in ref.watch(state).orders ?? [])
                  OrderTile(
                    order: order,
                    onFlightEdit: (f) =>
                        ref.watch(presenter).changeOrderFlight(order.id, f),
                    onFlightSearchCancel: (f) =>
                        ref.watch(presenter).cancelOrderFlightSearch(f),
                    onFlightSearchApply: (f) => ref
                        .watch(presenter)
                        .applyOrderFlightSearch(order.id, f),
                  ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
