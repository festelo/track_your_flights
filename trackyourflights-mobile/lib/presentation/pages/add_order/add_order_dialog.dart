import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/add_order_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/widgets/flight_form.dart';
import 'package:trackyourflights/presentation/pages/add_order/widgets/flight_title.dart';
import 'package:trackyourflights/presentation/pages/add_order/widgets/order_info_form.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';
import 'package:trackyourflights/presentation/widgets/loading_overlay.dart';

class AddOrderDialog extends ConsumerWidget {
  const AddOrderDialog({Key? key}) : super(key: key);

  Widget orderDetailsTab({
    required ScrollController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Enter your flight order info',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            controller: controller,
            child: const OrderInfoForm(),
          ),
        )
      ],
    );
  }

  Widget flightTab({
    required int flightNumber,
    required FlightPresenter presenter,
    required ScrollController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        FlightTitle(
          flightNumber: flightNumber,
          presenter: presenter,
          onRemove: null,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: FlightForm(presenter: presenter),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(addOrderContainer());
    return CompleteBridge(
      presenter: presenter,
      child: Center(
        child: Container(
          width: 600,
          height: 520,
          margin: const EdgeInsets.symmetric(vertical: 60),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: LoadingOverlay(
            loading: presenter.loading,
            child: Scaffold(
              body: Row(
                children: [
                  Expanded(
                    child: IndexedStack(
                      index: presenter.currentTab,
                      children: [
                        orderDetailsTab(
                          controller: presenter.scrollControllers.first,
                        ),
                        for (final entry
                            in presenter.flightPresenters.asMap().entries)
                          flightTab(
                            flightNumber: entry.key,
                            presenter: entry.value,
                            controller:
                                presenter.scrollControllers[entry.key + 1],
                          ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.black,
                    height: double.infinity,
                    width: 1,
                  ),
                  SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.info_outline),
                                title: const Text('Order details'),
                                selected: presenter.currentTab == 0,
                                onTap: () => presenter.currentTab = 0,
                              ),
                              for (final entry in presenter.flightPresenters
                                  .asMap()
                                  .entries) ...[
                                ListTile(
                                  leading: const Icon(Icons.flight),
                                  selected:
                                      presenter.currentTab == entry.key + 1,
                                  title: Text(
                                    'Flight ${entry.key + 1}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () =>
                                      presenter.currentTab = entry.key + 1,
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                    ),
                                    iconSize: 18,
                                    onPressed: () =>
                                        presenter.removeFlight(entry.value),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.add),
                          title: const Text('Add flight'),
                          onTap: presenter.addFlight,
                        ),
                        ListTile(
                          leading: const Icon(Icons.done),
                          title: const Text('Save'),
                          visualDensity: VisualDensity.standard,
                          onTap: presenter.save,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ConstantValueListanable<T> extends ValueListenable<T> {
  const ConstantValueListanable(this.value);

  @override
  final T value;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}
