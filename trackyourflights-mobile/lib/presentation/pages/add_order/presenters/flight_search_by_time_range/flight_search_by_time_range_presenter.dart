import 'package:flutter/material.dart';
import 'package:trackyourflights/domain/entities/either.dart';
import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/presentation/date_formats.dart';
import 'package:trackyourflights/presentation/debounce.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_search_presenter.dart';
import 'package:trackyourflights/repositories.dart';

import 'flight_search_by_time_range_state.dart';

class FlightSearchByTimeRangePresenter implements FlightSearchPresenter {
  FlightSearchByTimeRangePresenter(
    this._notify,
    this._contextResolver,
  );

  final FlightSearchByTimeRangeState state = FlightSearchByTimeRangeState();
  final VoidCallback _notify;
  final BuildContext Function() _contextResolver;

  BuildContext get _context => _contextResolver();

  final Debounce _presearchDebounce = Debounce();

  @override
  String? get preview => state.flightPresearch.value?.description;

  @override
  void initState() {
    state.flightNumberController.addListener(_onFlightNumberChanged);
  }

  void _onFlightNumberChanged() {
    _presearchDebounce.exec((nonce) async {
      final newFlightNumber = state.flightNumberController.text.trim();
      state.flightPresearch = const Either.empty();
      if (newFlightNumber.isEmpty) {
        return;
      }
      final value = await flightSearchRepository.presearch(newFlightNumber);
      if (!_presearchDebounce.shouldApplyValue(nonce)) {
        return;
      }
      state.flightPresearch = Either.value(value);
      _notify();
    });
  }

  Future<void> selectAproxDate() async {
    final date = await showDatePicker(
      context: _context,
      initialDate: state.aproxDate ?? DateTime.now(),
      initialEntryMode: DatePickerEntryMode.input,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (date == null) return;
    state.aproxDate = DateTime.utc(date.year, date.month, date.day);
    _notify();
  }

  @override
  Future<FlightOrSearch> flightOrSearch() async {
    final time = DateTimeParser.time(_context, state.aproxTimeController.text)!;
    final search = await complexSearchRepository.createSearch(
      ident: state.flightPresearch.value!.ident,
      aproxDate: state.aproxDate!.add(
        Duration(
          hours: time.hour,
          minutes: time.minute,
        ),
      ),
      originItea: state.departureAirportController.text.trim(),
      destItea: state.arrivalAirportController.text.trim(),
      restart: false,
    );
    return FlightOrSearch.search(search);
  }

  @override
  String? validate() {
    return null;
  }

  @override
  void dispose() {
    state.flightNumberController.dispose();
    state.departureAirportController.dispose();
    state.arrivalAirportController.dispose();
    state.aproxTimeController.dispose();
  }
}
