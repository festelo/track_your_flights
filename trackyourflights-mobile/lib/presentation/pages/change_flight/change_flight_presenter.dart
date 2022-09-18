import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/presentation/event/app_notifier.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_presenter.dart';
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
    flightPresenter.fillFromOrderFlight(flight);
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
