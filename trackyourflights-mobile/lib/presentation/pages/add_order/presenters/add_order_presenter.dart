import 'package:flutter/material.dart';
import 'package:trackyourflights/domain/entities/currency.dart';
import 'package:trackyourflights/domain/entities/order.dart';
import 'package:trackyourflights/domain/entities/price.dart';
import 'package:trackyourflights/presentation/event/app_notifier.dart';
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
  final TextEditingController linkController = TextEditingController();
  final TextEditingController sellerController = TextEditingController();

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

  Future<void> selectOrderCurrency(Currency currency) async {
    orderCurrency = currency;
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
      String? error;
      if (!formKey.currentState!.validate()) {
        error = 'Check your fields';
      }
      for (final flightPresenter in flightPresenters) {
        error = flightPresenter.validate();
      }
      if (error != null) {
        buttonKey.currentState?.addError(error);
        return;
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
        comment: commentController.text.trim(),
        link: linkController.text.trim(),
        seller: sellerController.text.trim(),
      );
      await trackRepository.saveOrderTracks(order);
      await historyRepository.saveOrder(order);
      appNotifier.push(OrderAddedEvent());
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
    linkController.dispose();
    sellerController.dispose();
    for (var e in flightPresenters) {
      e.dispose();
    }
  }
}
