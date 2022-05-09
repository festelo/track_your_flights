import 'package:flutter/material.dart';
import 'package:trackyourflights/domain/entities/currency.dart';
import 'package:trackyourflights/domain/entities/order.dart';
import 'package:trackyourflights/domain/entities/price.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_presenter.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';
import 'package:trackyourflights/presentation/widgets/primary_button.dart';
import 'package:trackyourflights/repositories.dart';

final addOrderContainer =
    PresenterStandaloneContainer<AddOrderPresenter>(() => AddOrderPresenter());

class AddOrderPresenter extends CompletePresenterStandalone {
  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<PrimaryButtonState> buttonKey = GlobalKey();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  Currency? orderCurrency;
  DateTime? orderDate;
  bool loading = false;

  // used only by add_order_dialog
  int _currentTab = 0;
  int get currentTab => _currentTab;
  set currentTab(int value) {
    _currentTab = value;
    notify();
  }

  final List<FlightPresenter> flightPresenters = [
    FlightPresenter(),
  ];

  @override
  void initState() {
    super.initState();
    attachFlightPresenter(flightPresenters[0]);
  }

  void attachFlightPresenter(FlightPresenter flightPresenter) {
    flightPresenter.addListener(() => notify());
    flightPresenter.initState();
  }

  void unsubscribeFromFlightPresenter() {}

  Future<void> selectOrderDate() async {
    final date = await showDatePicker(
      context: context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (date == null) return;

    orderDate = date;
    notify();
  }

  Future<void> selectOrderCurrency() async {
    orderCurrency = Currency.eur;
    notify();
  }

  void addFlight() {
    flightPresenters.add(FlightPresenter());
    attachFlightPresenter(flightPresenters.last);
    notify();
  }

  void removeFlight(FlightPresenter presenter) {
    flightPresenters.remove(presenter);
    if (currentTab > flightPresenters.length) {
      currentTab--;
    }
    notify();
  }

  Future<void> save() async {
    notify(() => loading = true);
    try {
      if (!formKey.currentState!.validate()) {
        buttonKey.currentState?.addError('Check your fields');
        return;
      }
      for (final flightPresenter in flightPresenters) {
        final error = flightPresenter.validate();
        if (error != null) {
          buttonKey.currentState?.addError(error);
          return;
        }
      }
      final flights = flightPresenters.map((e) => e.flight).toList();
      final order = Order(
        id: uuid,
        price: Price(
          amount: double.parse(priceController.text),
          currency: orderCurrency!,
        ),
        flights: flights,
        orderedAt: orderDate!,
      );
      await trackRepository.saveOrderTracks(order);
      await historyRepository.saveOrder(order);
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
    priceController.dispose();
    commentController.dispose();
    for (var e in flightPresenters) {
      e.dispose();
    }
  }
}
