import 'package:flutter/material.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_search_by_link/flight_search_by_link_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_search_by_params/flight_search_by_params_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_search_by_time_range/flight_search_by_time_range_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/widgets/flight_form_by_link.dart';
import 'package:trackyourflights/presentation/pages/add_order/widgets/flight_form_by_params.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';

import 'flight_form_by_time_range.dart';

class FlightForm extends PresenterWidget {
  const FlightForm({
    Key? key,
    required this.presenter,
  }) : super(key: key);

  final FlightPresenter presenter;

  @override
  PresenterState<FlightForm> createState() => FlightFormState();
}

class FlightFormState extends PresenterState<FlightForm> {
  @override
  Widget build(BuildContext context) {
    final presenter = widget.presenter;
    return CompleteBridge(
      presenter: presenter,
      child: Form(
          key: presenter.formKey,
          child: () {
            if (presenter.searchPresenter is FlightSearchByLinkPresenter) {
              return FlightFormByLink(
                flightPresenter: presenter,
                searchPresenter:
                    presenter.searchPresenter as FlightSearchByLinkPresenter,
              );
            }
            if (presenter.searchPresenter is FlightSearchByParamsPresenter) {
              return FlightFormByParams(
                flightPresenter: presenter,
                searchPresenter:
                    presenter.searchPresenter as FlightSearchByParamsPresenter,
              );
            }
            if (presenter.searchPresenter is FlightSearchByTimeRangePresenter) {
              return FlightFormByTimeRange(
                flightPresenter: presenter,
                searchPresenter: presenter.searchPresenter
                    as FlightSearchByTimeRangePresenter,
              );
            }
            return const SizedBox();
          }()),
    );
  }
}
