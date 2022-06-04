import 'package:flutter/material.dart';

import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/presentation/date_formats.dart';

class FlightSearchTile extends StatelessWidget {
  const FlightSearchTile({
    Key? key,
    required this.orderFlight,
    required this.onApply,
    required this.onEdit,
    required this.onCancel,
  }) : super(key: key);

  final OrderFlight orderFlight;
  final void Function() onApply;
  final void Function() onEdit;
  final void Function() onCancel;

  @override
  Widget build(BuildContext context) {
    final search = orderFlight.flightOrSearch.search!;
    final showChangeParams =
        search.state == 'completed' && search.flight == null;
    final showFailed = search.state == 'failed';

    return GestureDetector(
      onTap: showChangeParams || showFailed ? onEdit : null,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    search.ident,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        search.aproxDate.formattedTimeDate(context),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (search.originItea != null &&
                          search.originItea!.isNotEmpty &&
                          search.destItea != null &&
                          search.destItea!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(${search.originItea} - ${search.destItea})',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            if (search.state == 'completed' && search.flight != null)
              SizedBox(
                width: 90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      iconSize: 16,
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: onApply,
                      icon: const Icon(Icons.check),
                    ),
                  ],
                ),
              )
            else if (showChangeParams)
              SizedBox(
                width: 90,
                child: Column(
                  children: [
                    const Text('Not found'),
                    const SizedBox(height: 4),
                    Text(
                      'Change params',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              )
            else if (showFailed)
              SizedBox(
                width: 90,
                child: Column(
                  children: [
                    const Text('Failed'),
                    const SizedBox(height: 4),
                    Text(
                      'Review info',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              )
            else
              GestureDetector(
                onTap: onCancel,
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: search.progress,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
