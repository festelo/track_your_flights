import 'package:flutter/material.dart';

import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_search_by_link/flight_search_by_link_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_search_by_params/flight_search_by_params_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_search_by_time_range/flight_search_by_time_range_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_search_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_state.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';

import 'models.dart';

class FlightPresenter extends CompletePresenterStandalone {
  final GlobalKey<FormState> formKey = GlobalKey();

  FlightState state = FlightState();

  late final FlightSearchByLinkPresenter _searchByLinkPresenter =
      FlightSearchByLinkPresenter(
    () => searchPresenter == _searchByLinkPresenter ? notify() : null,
  );

  late final FlightSearchByParamsPresenter _searchByParamsPresenter =
      FlightSearchByParamsPresenter(
    () => searchPresenter == _searchByParamsPresenter ? notify() : null,
    () => context!,
  );

  late final FlightSearchByTimeRangePresenter _searchByTimeRangePresenter =
      FlightSearchByTimeRangePresenter(
    () => searchPresenter == _searchByTimeRangePresenter ? notify() : null,
    () => context!,
  );

  late FlightSearchPresenter _searchPresenter = _searchByParamsPresenter;

  FlightSearchPresenter get searchPresenter => _searchPresenter;

  SearchType get searchType {
    if (searchPresenter is FlightSearchByLinkPresenter) {
      return SearchType.byFlightAwareLink;
    }
    if (searchPresenter is FlightSearchByParamsPresenter) {
      return SearchType.byParameters;
    }
    throw Exception('SearchType unknown');
  }

  set searchType(SearchType val) {
    if (val == SearchType.byParameters) {
      if (_searchPresenter is FlightSearchByTimeRangePresenter) {
        _searchByParamsPresenter.state.flightPresearch =
            _searchByTimeRangePresenter.state.flightPresearch;
        _searchByParamsPresenter.state.flightDate =
            _searchByTimeRangePresenter.state.aproxDate;
        _searchByParamsPresenter.state.departureTimeController.text =
            _searchByTimeRangePresenter.state.aproxTimeController.text;
        _searchByParamsPresenter.state.departureAirportController.text =
            _searchByTimeRangePresenter.state.departureAirportController.text;
        _searchByParamsPresenter.state.arrivalAirportController.text =
            _searchByTimeRangePresenter.state.arrivalAirportController.text;
        _searchByParamsPresenter.state.flightNumberController.text =
            _searchByTimeRangePresenter.state.flightNumberController.text;
      }
      _searchPresenter = _searchByParamsPresenter;
    } else if (val == SearchType.byFlightAwareLink) {
      _searchPresenter = _searchByLinkPresenter;
    } else if (val == SearchType.byDateRange) {
      if (_searchPresenter is FlightSearchByParamsPresenter) {
        _searchByTimeRangePresenter.state.flightPresearch =
            _searchByParamsPresenter.state.flightPresearch;
        _searchByTimeRangePresenter.state.aproxDate =
            _searchByParamsPresenter.state.flightDate;
        _searchByTimeRangePresenter.state.aproxTimeController.text =
            _searchByParamsPresenter.state.departureTimeController.text;
        _searchByTimeRangePresenter.state.departureAirportController.text =
            _searchByParamsPresenter.state.departureAirportController.text;
        _searchByTimeRangePresenter.state.arrivalAirportController.text =
            _searchByParamsPresenter.state.arrivalAirportController.text;
        _searchByTimeRangePresenter.state.flightNumberController.text =
            _searchByParamsPresenter.state.flightNumberController.text;
      }
      _searchPresenter = _searchByTimeRangePresenter;
    }
    notify();
  }

  @override
  void initState() {
    super.initState();
    _searchByLinkPresenter.initState();
    _searchByParamsPresenter.initState();
    _searchByTimeRangePresenter.initState();
  }

  String? validate() {
    if (!formKey.currentState!.validate()) {
      return 'Oops. Issues found, please fix them';
    }
    return searchPresenter.validate();
  }

  Future<OrderFlight> flight() async {
    return OrderFlight(
      id: null,
      trackExists: false,
      flightOrSearch: await searchPresenter.flightOrSearch(),
      personsCount: int.parse(state.personsController.text),
    );
  }

  @override
  void dispose() {
    super.dispose();
    state.personsController.dispose();
  }
}
