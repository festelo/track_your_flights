import 'package:flutter/material.dart';
import 'package:trackyourflights/presentation/pages/add_order/widgets/flight_form.dart';
import 'package:trackyourflights/presentation/pages/add_order/widgets/flight_title.dart';
import 'package:trackyourflights/presentation/pages/add_order/widgets/order_info_form.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/add_order_presenter.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';
import 'package:trackyourflights/presentation/widgets/loading_overlay.dart';
import 'package:trackyourflights/presentation/widgets/primary_button.dart';

class AddOrderPage extends ConsumerWidget {
  const AddOrderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(addOrderContainer());
    return CompleteBridge(
      presenter: presenter,
      child: LoadingOverlay(
        loading: presenter.loading,
        child: Scaffold(
          floatingActionButton: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(64),
              color: Colors.grey.shade300,
            ),
            margin: const EdgeInsets.only(bottom: 72, right: 18),
            child: InkWell(
              borderRadius: BorderRadius.circular(64),
              onTap: presenter.addFlight,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Text('Add flight'),
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_ios),
                          ),
                          const Column(
                            children: [
                              SizedBox(height: 8),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'Enter your flight order info',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const OrderInfoForm(),
                      for (final entry
                          in presenter.flightPresenters.asMap().entries) ...[
                        const SizedBox(height: 32),
                        FlightTitle(
                          flightNumber: entry.key,
                          presenter: entry.value,
                          onRemove: () => presenter.removeFlight(entry.value),
                        ),
                        FlightForm(
                          presenter: entry.value,
                        ),
                      ],
                      const SizedBox(height: 64),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                    bottom: 24,
                    top: 24,
                    right: 32,
                    left: 32,
                  ),
                  width: double.infinity,
                  child: PrimaryButton(
                    key: presenter.buttonKey,
                    onTap: presenter.save,
                    text: 'Save',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
