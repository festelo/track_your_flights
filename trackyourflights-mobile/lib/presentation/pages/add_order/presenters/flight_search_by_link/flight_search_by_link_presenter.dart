import 'package:flutter/material.dart';
import 'package:trackyourflights/domain/entities/either.dart';
import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/presentation/nonce.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_search_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/models.dart';
import 'package:trackyourflights/repositories.dart';

import 'flight_search_by_link_state.dart';

class FlightSearchByLinkPresenter implements FlightSearchPresenter {
  FlightSearchByLinkPresenter(this._notify);

  final FlightSearchByLinkState state = FlightSearchByLinkState();

  final VoidCallback _notify;

  String _lastFlightAwareLink = '';
  final Nonce _foundFlightsNonce = Nonce();
  @override
  String? get preview => null;

  @override
  void initState() {
    state.flightAwareLinkFocusNode.addListener(() {
      if (!state.flightAwareLinkFocusNode.hasFocus &&
          _lastFlightAwareLink != state.flightAwareLinkController.text.trim()) {
        _lastFlightAwareLink = state.flightAwareLinkController.text.trim();
        _maybeSearchByFlightawareLink();
      }
    });
  }

  void _maybeSearchByFlightawareLink() {
    if (state.flightAwareLinkController.text.trim().isEmpty) {
      return;
    }
    _searchFlights();
  }

  Future<void> _searchFlights() async {
    state.flightLoading = true;
    state.foundFlights = const Either.empty();
    _notify();

    final nonce = _foundFlightsNonce.increase();

    try {
      final List<Flight> flights;
      flights = await flightSearchRepository
          .findByFlightaware(state.flightAwareLinkController.text.trim());

      if (!_foundFlightsNonce.shouldApplyValue(nonce)) {
        return;
      }

      if (flights.isNotEmpty) {
        state.foundFlights = Either.value(flights);
      } else {
        state.foundFlights = const Either.error(
          SearchError(
            'Flight not found :(',
            showSearchRangeSuggestion: true,
          ),
        );
      }
    } catch (e) {
      if (!_foundFlightsNonce.shouldApplyValue(nonce)) {
        return;
      }

      state.foundFlights =
          const Either.error(SearchError('Oh no, I faced some problems'));
    } finally {
      if (_foundFlightsNonce.shouldApplyValue(nonce)) {
        state.flightLoading = false;
        _notify();
      }
    }
  }

  @override
  FlightOrSearch flightOrSearch() =>
      FlightOrSearch.flight(state.selectedFlight!);

  @override
  String? validate() {
    if (state.flightLoading) {
      return 'Wait a moment, we are searching';
    }
    if (state.foundFlights.error != null) {
      return 'There\'s an error in flight search';
    }
    if (state.foundFlights.value?.isEmpty ?? true) {
      return 'Flights not found yet';
    }
    return null;
  }

  @override
  void dispose() {
    state.flightAwareLinkController.dispose();
    state.flightAwareLinkFocusNode.dispose();
  }
}
