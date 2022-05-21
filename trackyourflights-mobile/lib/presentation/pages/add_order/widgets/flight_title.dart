import 'package:flutter/material.dart';

import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_presenter.dart';

class FlightTitle extends StatelessWidget {
  const FlightTitle({
    Key? key,
    required this.flightNumber,
    required this.presenter,
    required this.onRemove,
  }) : super(key: key);

  final int flightNumber;
  final FlightPresenter presenter;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              presenter.flightPresearch.value == null
                  ? 'Flight ${flightNumber + 1}'
                  : 'Flight ${flightNumber + 1} (${presenter.flightPresearch.value!.description})',
              maxLines: 1,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close),
            )
        ],
      ),
    );
  }
}
