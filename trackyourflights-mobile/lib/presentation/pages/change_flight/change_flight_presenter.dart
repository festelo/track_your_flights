import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:trackyourflights/domain/entities/either.dart';

import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/entities/flight_presearch_result.dart';
import 'package:trackyourflights/presentation/date_formats.dart';
import 'package:trackyourflights/presentation/event/app_notifier.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_search_by_time_range/flight_search_by_time_range_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/models.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';
import 'package:trackyourflights/presentation/widgets/primary_button.dart';
import 'package:trackyourflights/repositories.dart';

final changeFlightContainer = PresenterStandaloneContainerWithParameter<
    ChangeFlightPresenter, ChangeFlightPresenterParams>(
  (o) => ChangeFlightPresenter(o.orderId, o.flight),
);

class ChangeFlightPresenterParams with EquatableMixin {
  const ChangeFlightPresenterParams({
    required this.orderId,
    required this.flight,
  });

  final String orderId;
  final OrderFlight flight;

  @override
  List<Object?> get props => [orderId, flight];
}

class ChangeFlightPresenter extends CompletePresenterStandalone {
  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<PrimaryButtonState> buttonKey = GlobalKey();

  final FlightPresenter flightPresenter = FlightPresenter();
  bool loading = false;

  final OrderFlight flight;
  final String orderId;

  ChangeFlightPresenter(this.orderId, this.flight);

  @override
  void initState() {
    super.initState();
    if (flight.flightOrSearch.search != null) {
      final search = flight.flightOrSearch.search!;
      flightPresenter.searchType = SearchType.byDateRange;
      final presenter =
          flightPresenter.searchPresenter as FlightSearchByTimeRangePresenter;
      presenter.state.aproxDate = DateTime.utc(
          search.aproxDate.year, search.aproxDate.month, search.aproxDate.day);
      presenter.state.aproxTimeController.text =
          search.aproxDate.formattedTime(null);
      presenter.state.departureAirportController.text = search.originItea ?? '';
      presenter.state.arrivalAirportController.text = search.destItea ?? '';
      presenter.state.flightNumberController.text = search.ident;
      presenter.state.flightPresearch = Either.value(
        FlightPresearchResult(
          description: search.ident,
          ident: search.ident,
        ),
      );
      flightPresenter.state.personsController.text =
          flight.personsCount.toString();
    }
    attachFlightPresenter(flightPresenter);
  }

  void attachFlightPresenter(FlightPresenter flightPresenter) {
    flightPresenter.addListener(() => notify());
    flightPresenter.initState();
  }

  Future<void> save() async {
    notify(() => loading = true);
    try {
      String? error;
      if (!formKey.currentState!.validate()) {
        error = 'Check your fields';
      }
      error = flightPresenter.validate();
      if (error != null) {
        buttonKey.currentState?.addError(error);
        return;
      }
      final newFlight = await flightPresenter.flight();
      if (newFlight.flightOrSearch.flight != null) {
        await trackRepository.saveFlightTrack(newFlight.flightOrSearch.flight!);
      }
      await historyRepository.updateOrderFlight(orderId, flight.id!, newFlight);
      appNotifier.push(OrderChangedEvent());
      if (context != null) {
        Navigator.of(context!).pop();
      }
    } finally {
      notify(() => loading = false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    flightPresenter.dispose();
  }
}
