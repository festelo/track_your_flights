import 'package:flutter/material.dart';
import 'package:trackyourflights/presentation/date_formats.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/add_order_presenter.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';
import 'package:trackyourflights/presentation/widgets/button_styled_as_text_field.dart';

class OrderInfoForm extends ConsumerWidget {
  const OrderInfoForm({Key? key}) : super(key: key);

  ProviderBase<AddOrderPresenter> get presenter => addOrderContainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(this.presenter);
    return Form(
      key: presenter.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ButtonStyledAsTextField(
              label: 'Order Date',
              hint: 'Select date',
              value: presenter.orderDate?.formattedDate(context),
              onTap: presenter.selectOrderDate,
              validator: (e) => e == null || e.isEmpty ? 'Please enter' : null,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Order Price',
                hintText: '200',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              controller: presenter.priceController,
              validator: (s) =>
                  double.tryParse(s!) == null ? 'Float please' : null,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ButtonStyledAsTextField(
              label: 'Order Currency',
              hint: 'Select currency',
              value: presenter.orderCurrency?.name,
              onTap: presenter.selectOrderCurrency,
              validator: (e) => e == null || e.isEmpty ? 'Please select' : null,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Order Comment',
                hintText: 'You can enter any comment',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              maxLines: null,
              controller: presenter.commentController,
            ),
          ),
        ],
      ),
    );
  }
}
