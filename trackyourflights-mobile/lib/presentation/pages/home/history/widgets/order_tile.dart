import 'package:flutter/material.dart';

import 'package:trackyourflights/domain/entities/order.dart';
import 'package:trackyourflights/presentation/pages/home/history/widgets/flight_tile.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({
    Key? key,
    required this.order,
  }) : super(key: key);

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                for (final flight in order.flights)
                  FlightTile(
                    orderFlight: flight,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
              ),
            ),
            padding:
                const EdgeInsets.only(left: 12, top: 13, bottom: 12, right: 12),
            child: Text(
              order.price.currency.symbol +
                  order.price.amount.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
