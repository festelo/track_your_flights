import 'package:flutter/material.dart';

import 'package:trackyourflights/presentation/date_formats.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_presenter.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';
import 'package:trackyourflights/presentation/widgets/button_styled_as_text_field.dart';

class FlightForm extends PresenterWidget {
  const FlightForm({
    Key? key,
    required this.presenter,
  }) : super(key: key);

  final FlightPresenter presenter;

  @override
  PresenterState<FlightForm> createState() => FlightFormState();
}

class FlightFormState extends PresenterState<FlightForm> {
  @override
  Widget build(BuildContext context) {
    final presenter = widget.presenter;
    return CompleteBridge(
      presenter: presenter,
      child: Form(
        key: presenter.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AnimatedBuilder(
                animation: presenter.flightNumberFocusNode,
                builder: (ctx, _) => TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Flight Number',
                    hintText: 'TK173',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: presenter.flightNumberFocusNode.hasFocus &&
                            presenter.flightDate != null
                        ? InkWell(
                            child: const Icon(Icons.done),
                            onTap: () => FocusScope.of(context).unfocus(),
                          )
                        : null,
                  ),
                  style: TextStyle(
                    color: presenter.flightPresearch.error != null
                        ? Colors.red
                        : null,
                  ),
                  focusNode: presenter.flightNumberFocusNode,
                  controller: presenter.flightNumberController,
                  validator: (s) =>
                      s == null || s.isEmpty ? 'Please enter' : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ButtonStyledAsTextField(
                label: 'Flight Date',
                hint: 'Select date',
                value: presenter.flightDate?.formattedDate(context),
                onTap: presenter.selectFlightDate,
                validator: (s) =>
                    s == null || s.isEmpty ? 'Please select' : null,
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
                controller: presenter.personsController,
                validator: (s) =>
                    int.tryParse(s!) == null ? 'Number please' : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AnimatedBuilder(
                animation: presenter.departureTimeFocusNode,
                builder: (ctx, _) => TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Scheduled Departure Time',
                    hintText: presenter.selectedFlight?.takeoffTimes.scheduled
                            ?.formattedTime(context) ??
                        '00:00',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: presenter.departureTimeFocusNode.hasFocus &&
                            presenter.flightDate != null &&
                            presenter.flightPresearch.value != null
                        ? InkWell(
                            child: const Icon(Icons.done),
                            onTap: () => FocusScope.of(context).unfocus(),
                          )
                        : null,
                  ),
                  focusNode: presenter.departureTimeFocusNode,
                  controller: presenter.departureTimeController,
                  validator: (s) {
                    s = s?.trim();
                    if (s == null || s.isEmpty) return null;
                    return DateTimeParser.time(context, s) == null
                        ? 'HH:MM'
                        : null;
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AnimatedBuilder(
                animation: presenter.departureAirportFocusNode,
                builder: (ctx, _) => TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Departure Airport',
                    hintText: presenter.selectedFlight?.origin.iata ?? 'DDDD',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: presenter.departureAirportFocusNode.hasFocus &&
                            presenter.flightDate != null &&
                            presenter.flightPresearch.value != null
                        ? InkWell(
                            child: const Icon(Icons.done),
                            onTap: () => FocusScope.of(context).unfocus(),
                          )
                        : null,
                  ),
                  focusNode: presenter.departureAirportFocusNode,
                  controller: presenter.departureAirportController,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AnimatedBuilder(
                animation: presenter.arrivalAirportFocusNode,
                builder: (ctx, _) => TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Arrival Airport',
                    hintText:
                        presenter.selectedFlight?.destination.iata ?? 'AAAA',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: presenter.arrivalAirportFocusNode.hasFocus &&
                            presenter.flightDate != null &&
                            presenter.flightPresearch.value != null
                        ? InkWell(
                            child: const Icon(Icons.done),
                            onTap: () => FocusScope.of(context).unfocus(),
                          )
                        : null,
                  ),
                  focusNode: presenter.arrivalAirportFocusNode,
                  controller: presenter.arrivalAirportController,
                ),
              ),
            ),
            if (presenter.flightLoading) ...[
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
            ] else if (presenter.foundFlights.error != null) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  presenter.foundFlights.error!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ] else if (presenter.foundFlights.value?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Seems like this is a flight from ${presenter.selectedFlight!.origin.city} to ${presenter.selectedFlight!.destination.city}.\n\nTake off was at ${presenter.foundFlights.value![0].takeoffTimes.actual?.formattedTime(context)} and landing at ${presenter.foundFlights.value![0].landingTimes.actual?.formattedTime(context)}\nAirplane - ${presenter.foundFlights.value![0].aircraft.name}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
