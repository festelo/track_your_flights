import 'package:flutter/material.dart';

import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/presentation/date_formats.dart';

class FlightTile extends StatelessWidget {
  const FlightTile({
    Key? key,
    required this.flight,
  }) : super(key: key);

  final Flight flight;

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
                        flight.from.airport.city,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        flight.from.dateTime.actual?.formattedTime(context) ??
                            '-',
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
                      flight.to.airport.city,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      flight.to.dateTime.actual?.formattedTime(context) ?? '-',
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
                    flight.personsCount.toString(),
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
                    flight.airplane.shortName,
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
                  Text(
                    flight.to.dateTime.actual!
                        .difference(flight.from.dateTime.actual!)
                        .inHours
                        .toString(),
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
