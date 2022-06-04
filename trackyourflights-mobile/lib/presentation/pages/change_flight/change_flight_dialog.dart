import 'package:flutter/material.dart';

import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/presentation/pages/add_order/widgets/flight_form.dart';
import 'package:trackyourflights/presentation/pages/change_flight/change_flight_presenter.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';
import 'package:trackyourflights/presentation/widgets/loading_overlay.dart';
import 'package:trackyourflights/presentation/widgets/primary_button.dart';

class ChangeFlightDialog extends ConsumerWidget {
  const ChangeFlightDialog({
    Key? key,
    required this.orderId,
    required this.flight,
  }) : super(key: key);

  final String orderId;
  final OrderFlight flight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(
      changeFlightContainer(
        ChangeFlightPresenterParams(
          orderId: orderId,
          flight: flight,
        ),
      ),
    );
    return CompleteBridge(
      presenter: presenter,
      child: Form(
        key: presenter.formKey,
        child: Center(
          child: Container(
            width: 450,
            height: 520,
            margin: const EdgeInsets.symmetric(vertical: 60),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: LoadingOverlay(
              loading: presenter.loading,
              child: Scaffold(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Enter your flight order info',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: ScrollController(),
                        child: FlightForm(presenter: presenter.flightPresenter),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 200,
                          child: PrimaryButton(
                            key: presenter.buttonKey,
                            onTap: presenter.save,
                            text: 'Save',
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_forever_outlined),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
