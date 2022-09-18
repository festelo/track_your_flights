import 'package:flutter/material.dart';

import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/presentation/date_formats.dart';

class FlightTile extends StatelessWidget {
  const FlightTile({
    Key? key,
    required this.orderFlight,
    required this.alwaysShowFlightEdit,
    required this.onEdit,
  }) : super(key: key);

  final OrderFlight orderFlight;
  final bool alwaysShowFlightEdit;
  final void Function() onEdit;

  @override
  Widget build(BuildContext context) {
    final flight = orderFlight.flightOrSearch.flight!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: SizedBox(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              flight.origin.city,
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
                                  flight.takeoffTimes.display
                                          ?.formattedTime(context) ??
                                      '-',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  flight.takeoffTimes.display
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
                            flight.destination.city,
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
                                flight.landingTimes.display
                                        ?.formattedTime(context) ??
                                    '-',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                flight.landingTimes.display
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
              ),
              SizedBox(
                width: 100,
                child: alwaysShowFlightEdit
                    ? Row(
                        children: [
                          IconButton(
                            onPressed: onEdit,
                            iconSize: 16,
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {},
                            iconSize: 16,
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      )
                    : null,
              )
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
                  Icon(
                    Icons.airplanemode_active,
                    color: orderFlight.trackExists ? null : Colors.red,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    flight.aircraft.shortName,
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
                  if (flight.landingTimes.display != null &&
                      flight.takeoffTimes.display != null)
                    Text(
                      flight.landingTimes.display!
                          .difference(flight.takeoffTimes.display!)
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
