import 'package:flutter/material.dart';

class SearchableTextField extends StatefulWidget {
  const SearchableTextField({Key? key}) : super(key: key);

  @override
  State<SearchableTextField> createState() => _SearchableTextFieldState();
}

class _SearchableTextFieldState extends State<SearchableTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: () {},
    );
  }
}
