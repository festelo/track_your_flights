import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trackyourflights/presentation/pages/add_order/add_order_dialog.dart';
import 'package:trackyourflights/presentation/pages/add_order/add_order_page.dart';
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
  }

  Future<void> refreshOrders() async {
    final orders = await historyRepository.listOrders();
    state.orders = orders;
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
    await refreshOrders();
  }
}
