import 'package:flutter/material.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_search_by_params/flight_search_by_params_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/models.dart';
import 'package:trackyourflights/presentation/date_formats.dart';
import 'package:trackyourflights/presentation/pages/add_order/widgets/airport_field.dart';
import 'package:trackyourflights/presentation/widgets/button_styled_as_text_field.dart';

class FlightFormByParams extends StatelessWidget {
  const FlightFormByParams({
    Key? key,
    required this.flightPresenter,
    required this.searchPresenter,
  }) : super(key: key);

  final FlightPresenter flightPresenter;
  final FlightSearchByParamsPresenter searchPresenter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () =>
                flightPresenter.searchType = SearchType.byFlightAwareLink,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                'Find by Flightaware link',
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
            animation: searchPresenter.state.flightNumberFocusNode,
            builder: (ctx, _) => TextFormField(
              decoration: InputDecoration(
                labelText: 'Flight Number',
                hintText: 'TK173',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon:
                    searchPresenter.state.flightNumberFocusNode.hasFocus &&
                            searchPresenter.state.flightDate != null
                        ? InkWell(
                            child: const Icon(Icons.done),
                            onTap: () => FocusScope.of(context).unfocus(),
                          )
                        : null,
              ),
              style: TextStyle(
                color: searchPresenter.state.flightPresearch.error != null
                    ? Colors.red
                    : null,
              ),
              focusNode: searchPresenter.state.flightNumberFocusNode,
              controller: searchPresenter.state.flightNumberController,
              validator: (s) => s == null || s.isEmpty ? 'Please enter' : null,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ButtonStyledAsTextField(
            label: 'Flight Date',
            hint: 'Select date',
            value: searchPresenter.state.flightDate?.formattedDate(context),
            onTap: searchPresenter.selectFlightDate,
            validator: (s) => s == null || s.isEmpty ? 'Please select' : null,
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
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: AnimatedBuilder(
            animation: searchPresenter.state.departureTimeFocusNode,
            builder: (ctx, _) => TextFormField(
              decoration: InputDecoration(
                labelText: 'Scheduled Departure Time',
                hintText: searchPresenter
                        .state.selectedFlight?.takeoffTimes.scheduled
                        ?.formattedTime(context) ??
                    '00:00',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon:
                    searchPresenter.state.departureTimeFocusNode.hasFocus &&
                            searchPresenter.state.flightDate != null &&
                            searchPresenter.state.flightPresearch.value != null
                        ? InkWell(
                            child: const Icon(Icons.done),
                            onTap: () => FocusScope.of(context).unfocus(),
                          )
                        : null,
              ),
              focusNode: searchPresenter.state.departureTimeFocusNode,
              controller: searchPresenter.state.departureTimeController,
              validator: (s) {
                s = s?.trim();
                if (s == null || s.isEmpty) return null;
                return DateTimeParser.time(context, s) == null ? 'HH:MM' : null;
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: AirportField(
            labelText: 'Departure Airport',
            showConfirmButton: searchPresenter.state.flightDate != null &&
                searchPresenter.state.flightPresearch.value != null,
            focusNode: searchPresenter.state.departureAirportFocusNode,
            controller: searchPresenter.state.departureAirportController,
            hintText: 'DDDD',
            waypoint: searchPresenter.state.selectedFlight?.origin,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: AirportField(
            labelText: 'Arrival Airport',
            showConfirmButton: searchPresenter.state.flightDate != null &&
                searchPresenter.state.flightPresearch.value != null,
            focusNode: searchPresenter.state.arrivalAirportFocusNode,
            controller: searchPresenter.state.arrivalAirportController,
            hintText: 'AAAA',
            waypoint: searchPresenter.state.selectedFlight?.destination,
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
          if (searchPresenter
              .state.foundFlights.error!.showSearchRangeSuggestion)
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () =>
                    flightPresenter.searchType = SearchType.byDateRange,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Text(
                    'Try search flight by time range',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
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
