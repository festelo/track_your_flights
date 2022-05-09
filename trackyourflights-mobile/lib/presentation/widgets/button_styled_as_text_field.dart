import 'package:flutter/material.dart';

class ButtonStyledAsTextField extends StatefulWidget {
  const ButtonStyledAsTextField({
    Key? key,
    required this.value,
    required this.hint,
    required this.label,
    required this.onTap,
    this.validator,
  }) : super(key: key);

  final String? value;
  final String? hint;
  final String? label;
  final VoidCallback onTap;
  final FormFieldValidator<String>? validator;

  @override
  State<ButtonStyledAsTextField> createState() =>
      _ButtonStyledAsTextFieldState();
}

class _ButtonStyledAsTextFieldState extends State<ButtonStyledAsTextField> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      controller.text = widget.value!;
    }
  }

  @override
  void didUpdateWidget(covariant ButtonStyledAsTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        controller.text = widget.value!;
      });
    } else if (oldWidget.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        controller.text = '';
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: widget.validator,
      controller: controller,
      readOnly: true,
      onTap: widget.onTap,
    );
  }
}
