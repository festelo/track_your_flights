import 'package:flutter/material.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_search_by_link/flight_search_by_link_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/models.dart';
import 'package:trackyourflights/presentation/date_formats.dart';

class FlightFormByLink extends StatelessWidget {
  const FlightFormByLink({
    Key? key,
    required this.flightPresenter,
    required this.searchPresenter,
  }) : super(key: key);

  final FlightPresenter flightPresenter;
  final FlightSearchByLinkPresenter searchPresenter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () => flightPresenter.searchType = SearchType.byParameters,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                'Find by Flight parameters',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: AnimatedBuilder(
            animation: searchPresenter.state.flightAwareLinkFocusNode,
            builder: (ctx, _) => TextFormField(
              decoration: InputDecoration(
                labelText: 'Flight Aware Link',
                hintText: 'https://flightaware.com/live/flight/AFL1000',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon:
                    searchPresenter.state.flightAwareLinkFocusNode.hasFocus
                        ? InkWell(
                            child: const Icon(Icons.done),
                            onTap: () => FocusScope.of(context).unfocus(),
                          )
                        : null,
              ),
              focusNode: searchPresenter.state.flightAwareLinkFocusNode,
              controller: searchPresenter.state.flightAwareLinkController,
              validator: (s) => s == null || s.isEmpty ? 'Please enter' : null,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Persons count',
              hintText: '2',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            controller: flightPresenter.state.personsController,
            validator: (s) => int.tryParse(s!) == null ? 'Number please' : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
        if (searchPresenter.state.flightLoading) ...[
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'I\'m trying to find your flight, one moment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ] else if (searchPresenter.state.foundFlights.error != null) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              searchPresenter.state.foundFlights.error!.text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ] else if (searchPresenter.state.foundFlights.value?.isNotEmpty ??
            false) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Seems like this is a flight from ${searchPresenter.state.selectedFlight!.origin.city} to ${searchPresenter.state.selectedFlight!.destination.city}.\n\nTake off was at ${searchPresenter.state.foundFlights.value![0].takeoffTimes.actual?.formattedTime(context)} and landing at ${searchPresenter.state.foundFlights.value![0].landingTimes.actual?.formattedTime(context)}\nAirplane - ${searchPresenter.state.foundFlights.value![0].aircraft.name}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ]
      ],
    );
  }
}
