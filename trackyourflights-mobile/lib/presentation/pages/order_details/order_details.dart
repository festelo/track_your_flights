import 'package:flutter/material.dart';
import 'package:trackyourflights/domain/entities/flight.dart';

import 'package:trackyourflights/domain/entities/order.dart';
import 'package:trackyourflights/presentation/date_formats.dart';
import 'package:trackyourflights/presentation/pages/home/history/widgets/order_tile.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderDetails extends StatelessWidget {
  const OrderDetails({
    Key? key,
    required this.order,
    required this.onFlightEdit,
  }) : super(key: key);

  final Order order;
  final void Function(OrderFlight) onFlightEdit;

  @override
  Widget build(BuildContext context) {
    const descriptionStyle =
        TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OrderTile(
          order: order,
          alwaysShowFlightEdit: true,
          onFlightEdit: onFlightEdit,
          onFlightSearchCancel: (_) {},
          onFlightSearchApply: (_) {},
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (order.seller != null && order.seller!.isNotEmpty)
                Row(
                  children: [
                    const Text(
                      'Bought at:',
                      style: descriptionStyle,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.seller!,
                      style: descriptionStyle,
                    ),
                  ],
                ),
              Row(
                children: [
                  const Text(
                    'Ordered at ',
                    style: descriptionStyle,
                  ),
                  Text(
                    order.orderedAt.formattedDate(context),
                    style: descriptionStyle,
                  ),
                ],
              ),
              if (order.link != null && order.link!.isNotEmpty)
                InkWell(
                  child: Text(
                    'Open order link',
                    style: descriptionStyle.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () => launchUrlString(order.link!),
                ),
            ],
          ),
        )
      ],
    );
  }
}
