import 'package:flutter/material.dart';

import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/presentation/date_formats.dart';

class FlightTile extends StatelessWidget {
  const FlightTile({
    Key? key,
    required this.orderFlight,
  }) : super(key: key);

  final OrderFlight orderFlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderFlight.flight.origin.city,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            orderFlight.flight.takeoffTimes.display
                                    ?.formattedTime(context) ??
                                '-',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            orderFlight.flight.takeoffTimes.display
                                    ?.formattedDateShort(context) ??
                                '-',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderFlight.flight.destination.city,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          orderFlight.flight.landingTimes.display
                                  ?.formattedTime(context) ??
                              '-',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          orderFlight.flight.landingTimes.display
                                  ?.formattedDateShort(context) ??
                              '-',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (ctx, constr) => Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (constr.maxWidth > 50) ...[
                  const Icon(
                    Icons.person,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    orderFlight.personsCount.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
                if (constr.maxWidth > 100) ...[
                  const SizedBox(width: 18),
                  const Icon(
                    Icons.airplanemode_active,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    orderFlight.flight.aircraft.shortName,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
                if (constr.maxWidth > 160) ...[
                  const SizedBox(width: 18),
                  const Icon(
                    Icons.schedule,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  if (orderFlight.flight.landingTimes.display != null &&
                      orderFlight.flight.takeoffTimes.display != null)
                    Text(
                      orderFlight.flight.landingTimes.display!
                          .difference(orderFlight.flight.takeoffTimes.display!)
                          .formattedTime(context),
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
