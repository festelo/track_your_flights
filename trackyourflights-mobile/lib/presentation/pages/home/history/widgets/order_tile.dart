import 'package:flutter/material.dart';
import 'package:trackyourflights/domain/entities/flight.dart';

import 'package:trackyourflights/domain/entities/order.dart';
import 'package:trackyourflights/presentation/pages/home/history/widgets/flight_tile.dart';

import 'flight_search_tile.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({
    Key? key,
    required this.order,
    required this.onFlightEdit,
    required this.onFlightSearchCancel,
    required this.onFlightSearchApply,
    this.alwaysShowFlightEdit = false,
  }) : super(key: key);

  final Order order;
  final bool alwaysShowFlightEdit;
  final void Function(OrderFlight) onFlightEdit;
  final void Function(OrderFlight) onFlightSearchCancel;
  final void Function(OrderFlight) onFlightSearchApply;

  Widget _buildFlightOrSearchTile(
      BuildContext context, OrderFlight orderFlight) {
    if (orderFlight.flightOrSearch.flight != null) {
      return FlightTile(
        orderFlight: orderFlight,
        alwaysShowFlightEdit: alwaysShowFlightEdit,
        onEdit: () => onFlightEdit(orderFlight),
      );
    } else {
      return FlightSearchTile(
        orderFlight: orderFlight,
        onEdit: () => onFlightEdit(orderFlight),
        onCancel: () => onFlightSearchCancel(orderFlight),
        onApply: () => onFlightSearchApply(orderFlight),
      );
    }
  }

  Widget _buildPriceBox(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
        ),
      ),
      width: 115,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8, right: 12),
      child: Text(
        order.price.currency.symbol + order.price.amount.toStringAsFixed(2),
        maxLines: 1,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w300,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildTileWithComment(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              for (final flight in order.flights)
                _buildFlightOrSearchTile(context, flight)
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      order.comment!,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: _buildPriceBox(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTileWithoutComment(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                for (final flight in order.flights)
                  _buildFlightOrSearchTile(context, flight),
                if (order.comment != null &&
                    order.comment!.trim().isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      order.comment!,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: _buildPriceBox(context),
        ),
      ],
    );
  }

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
      child: order.comment != null && order.comment!.trim().isNotEmpty
          ? _buildTileWithComment(context)
          : _buildTileWithoutComment(context),
    );
  }
}
