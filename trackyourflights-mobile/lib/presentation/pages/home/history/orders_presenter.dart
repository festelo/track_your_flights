import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/entities/flight_search_status_update.dart';
import 'package:trackyourflights/domain/entities/order.dart';
import 'package:trackyourflights/presentation/date_formats.dart';
import 'package:trackyourflights/presentation/disposables/disposable_stream.dart';
import 'package:trackyourflights/presentation/event/app_notifier.dart';
import 'package:trackyourflights/presentation/pages/add_order/add_order_dialog.dart';
import 'package:trackyourflights/presentation/pages/add_order/add_order_page.dart';
import 'package:trackyourflights/presentation/pages/change_flight/change_flight_dialog.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';
import 'package:trackyourflights/repositories.dart';

import 'orders_state.dart';

final ordersContainer =
    PresenterContainer<OrdersPresenter, OrdersState>(() => OrdersPresenter());

class OrdersPresenter extends CompletePresenter<OrdersState> {
  OrdersPresenter() : super(OrdersState());

  @override
  void initState() {
    super.initState();
    refreshOrders();
    appNotifier.events
        .whereType<OrdersModifiedEvent>()
        .listen((e) => refreshOrders())
        .disposeWith(this);

    complexSearchRepository.onStatusChange
        .listen(_onSearchUpdate)
        .disposeWith(this);
  }

  void _onSearchUpdate(FlightSearchStatusUpdate event) {
    for (final o in state.orders ?? <Order>[]) {
      for (final f in o.flights) {
        if (f.flightOrSearch.search != null &&
            f.flightOrSearch.search!.id == event.id) {
          if (event.progress != null) {
            f.flightOrSearch.search!.progress = event.progress;
          }
          if (event.data != null) {
            f.flightOrSearch.search!.flight = event.data;
          }
          if (event.error != null) {
            f.flightOrSearch.search!.error = event.error;
          }
          switch (event.status) {
            case FlightSearchStatus.failed:
              f.flightOrSearch.search!.state = 'failed';
              break;
            case FlightSearchStatus.completed:
              f.flightOrSearch.search!.state = 'completed';
              break;
            case FlightSearchStatus.started:
            case FlightSearchStatus.progress:
              break;
          }
          notify();
          break;
        }
      }
    }
  }

  void selectOrder(Order order) {
    notify(() => state.selectedOrder = order);
  }

  void unselectOrder() {
    notify(() => state.selectedOrder = null);
  }

  Future<void> refreshOrders() async {
    final orders = await historyRepository.listOrders();
    state.orders = orders;
    if (state.selectedOrder != null) {
      if (state.orders == null) {
        state.selectedOrder = null;
        notify();
      }
      if (!state.orders!.contains(state.selectedOrder)) {
        state.selectedOrder = state.orders!.firstWhereOrNull(
          (o) => o.id == state.selectedOrder!.id,
        );
        notify();
      }
    }
    notify();
  }

  Future<void> addOrder() async {
    if (MediaQuery.of(context!).size.width > 800) {
      await showDialog(
        context: context!,
        builder: (ctx) => const AddOrderDialog(),
      );
    } else {
      await navigator?.push(
        CupertinoPageRoute(
          builder: (ctx) => const AddOrderPage(),
        ),
      );
    }
  }

  Future<void> changeOrderFlight(
      String orderId, OrderFlight orderFlight) async {
    if (MediaQuery.of(context!).size.width > 800) {
      await showDialog(
        context: context!,
        builder: (ctx) => ChangeFlightDialog(
          flight: orderFlight,
          orderId: orderId,
        ),
      );
    } else {
      await navigator?.push(
        CupertinoPageRoute(
          builder: (ctx) => const AddOrderPage(),
        ),
      );
    }
  }

  Future<void> cancelOrderFlightSearch(OrderFlight orderFlight) async {
    final res = await showDialog(
      context: context!,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to cancel the search?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    ) as bool?;
    if (res != true) return;
    await complexSearchRepository
        .cancelSearch(orderFlight.flightOrSearch.search!.id);
    refreshOrders();
  }

  Future<void> applyOrderFlightSearch(
      String orderId, OrderFlight orderFlight) async {
    final flight = orderFlight.flightOrSearch.search!.flight!;
    final res = await showDialog(
      context: context!,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: SizedBox(
          width: 400,
          child: Text(
              'We found a flight from ${flight.origin.airport} ${flight.takeoffTimes.display?.formattedTimeDate(context)}  to ${flight.destination.airport} ${flight.landingTimes.display?.formattedTimeDate(context)}'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apply'),
          ),
        ],
      ),
    ) as bool?;
    if (res != true) return;
    await trackRepository.saveFlightTrack(flight);
    await historyRepository.updateOrderFlight(
      orderId,
      orderFlight.id!,
      OrderFlight(
        id: orderFlight.id!,
        trackExists: false,
        flightOrSearch: FlightOrSearch.flight(flight),
        personsCount: orderFlight.personsCount,
      ),
    );
    refreshOrders();
  }
}
