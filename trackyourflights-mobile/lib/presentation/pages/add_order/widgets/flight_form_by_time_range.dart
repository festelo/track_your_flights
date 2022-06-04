import 'package:flutter/material.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_search_by_time_range/flight_search_by_time_range_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/models.dart';
import 'package:trackyourflights/presentation/date_formats.dart';
import 'package:trackyourflights/presentation/pages/add_order/widgets/airport_field.dart';
import 'package:trackyourflights/presentation/widgets/button_styled_as_text_field.dart';

class FlightFormByTimeRange extends StatelessWidget {
  const FlightFormByTimeRange({
    Key? key,
    required this.flightPresenter,
    required this.searchPresenter,
  }) : super(key: key);

  final FlightPresenter flightPresenter;
  final FlightSearchByTimeRangePresenter searchPresenter;

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
                'Basic Search',
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
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Flight Number',
              hintText: 'TK173',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            controller: searchPresenter.state.flightNumberController,
            validator: (s) => s == null || s.isEmpty ? 'Please enter' : null,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ButtonStyledAsTextField(
            label: 'Approximately Departure Date',
            hint: 'Select date',
            value: searchPresenter.state.aproxDate?.formattedDate(context),
            onTap: searchPresenter.selectAproxDate,
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
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Approximately Departure Time',
              hintText: '00:00',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            controller: searchPresenter.state.aproxTimeController,
            validator: (s) {
              s = s?.trim();
              return DateTimeParser.time(context, s) == null ? 'HH:MM' : null;
            },
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: AirportField(
            labelText: 'Departure Airport',
            controller: searchPresenter.state.departureAirportController,
            hintText: 'DDDD',
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: AirportField(
            labelText: 'Arrival Airport',
            controller: searchPresenter.state.arrivalAirportController,
            hintText: 'AAAA',
          ),
        ),
      ],
    );
  }
}
