import 'package:flutter/material.dart';
import 'package:trackyourflights/domain/entities/either.dart';

import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/entities/flight_presearch_result.dart';
import 'package:trackyourflights/domain/entities/flight_search.dart';
import 'package:trackyourflights/presentation/date_formats.dart';
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

  void fillFromOrderFlight(OrderFlight orderFlight) {
    if (orderFlight.flightOrSearch.search != null) {
      fillFromFlightSearch(
        orderFlight.flightOrSearch.search!,
        personsCount: orderFlight.personsCount,
      );
    }
    if (orderFlight.flightOrSearch.flight != null) {
      fillFromFlight(
        orderFlight.flightOrSearch.flight!,
        personsCount: orderFlight.personsCount,
      );
    }
  }

  void fillFromFlightSearch(FlightSearch search, {required int personsCount}) {
    searchType = SearchType.byDateRange;
    final searchPresenter = _searchByTimeRangePresenter;
    searchPresenter.state.aproxDate = DateTime.utc(
      search.aproxDate.year,
      search.aproxDate.month,
      search.aproxDate.day,
    );
    searchPresenter.state.aproxTimeController.text =
        search.aproxDate.formattedTime(null);
    searchPresenter.state.departureAirportController.text =
        search.originItea ?? '';
    searchPresenter.state.arrivalAirportController.text = search.destItea ?? '';
    searchPresenter.state.flightNumberController.text = search.ident;
    searchPresenter.state.flightPresearch = Either.value(
      FlightPresearchResult(
        description: search.ident,
        ident: search.ident,
      ),
    );
    state.personsController.text = personsCount.toString();
  }

  void fillFromFlight(Flight flight, {required int personsCount}) {
    searchType = SearchType.byParameters;
    final searchByParamsPresenter = _searchByParamsPresenter;
    searchByParamsPresenter.state.flightNumberController.text = flight.ident;
    searchByParamsPresenter.state.flightDate = flight.takeoffTimes.display;
    state.personsController.text = personsCount.toString();

    final departureTime = flight.takeoffTimes.scheduled ??
        flight.takeoffTimes.actual ??
        flight.takeoffTimes.estimated;

    searchByParamsPresenter.state.departureTimeController.text =
        departureTime?.toUtc().formattedTime(null) ?? '';
    searchByParamsPresenter.state.departureAirportController.text =
        flight.origin.iata ?? flight.origin.airport;
    searchByParamsPresenter.state.arrivalAirportController.text =
        flight.destination.iata ?? flight.destination.airport;
    searchByParamsPresenter.state.flightPresearch = Either.value(
      FlightPresearchResult(
        description: flight.ident,
        ident: flight.ident,
      ),
    );
    searchByParamsPresenter.state.foundFlights = Either.value([flight]);

    final searchByLinkPresenter = _searchByLinkPresenter;
    searchByLinkPresenter.state.flightAwareLinkController.text =
        flight.flightAwarePermaLink;
    searchByLinkPresenter.state.foundFlights = Either.value([flight]);
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
