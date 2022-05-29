import 'package:flutter/material.dart';
import 'package:trackyourflights/domain/entities/airport.dart';

import 'package:trackyourflights/domain/entities/waypoint.dart';
import 'package:trackyourflights/presentation/debounce.dart';
import 'package:trackyourflights/presentation/widgets/search_pop_up.dart';
import 'package:trackyourflights/repositories.dart';

class AirportField extends StatefulWidget {
  const AirportField({
    Key? key,
    required this.labelText,
    this.hintText,
    this.waypoint,
    required this.showConfirmButton,
    required this.focusNode,
    required this.controller,
  }) : super(key: key);

  final String labelText;
  final String? hintText;
  final Waypoint? waypoint;
  final bool showConfirmButton;
  final FocusNode focusNode;
  final TextEditingController controller;

  @override
  State<AirportField> createState() => _AirportFieldState();
}

class _AirportFieldState extends State<AirportField> {
  RelativePopupController? popupController;
  StateSetter? popupStateSetter;

  final Debounce _searchDebounce = Debounce();
  List<Airport>? _airports;
  Map<String, Airport> _airportsByIcao = {};

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_focusNodeListener);
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _searchDebounce.exec((nonce) async {
      final text = widget.controller.text.trim();
      List<Airport> airports;
      if (text.isEmpty) {
        airports = [];
      } else {
        airports =
            await airportsRepository.search(widget.controller.text.trim());
      }
      if (_searchDebounce.shouldApplyValue(nonce)) {
        _airports = airports;
        _airportsByIcao =
            airports.asMap().map((key, value) => MapEntry(value.icao, value));
        if (mounted) {
          setState(() {});
          popupStateSetter?.call(() {});
        }
      }
    });
  }

  void _focusNodeListener() {
    if (!widget.focusNode.hasFocus) {
      popupController?.hide();
      popupController = null;
      popupStateSetter = null;
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_focusNodeListener);
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  Widget airportsPopup() {
    final children = [
      for (final airport in _airports ?? <Airport>[])
        ListTile(
          title: Text(airport.description),
          onTap: () {
            widget.controller.text = airport.icao;
            FocusScope.of(context).unfocus();
          },
        ),
    ];

    Widget child;
    if (children.length > 3) {
      child = SizedBox(
        height: 200,
        child: Scrollbar(
          thumbVisibility: true,
          child: ListView(
            children: children,
          ),
        ),
      );
    } else {
      child = Column(
        children: children,
      );
    }

    return Container(
      color: Colors.white,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    String? waypointData;
    if (widget.waypoint != null) {
      waypointData =
          '${widget.waypoint!.iata ?? '?'} - ${widget.waypoint!.city}';
    }
    return AnimatedBuilder(
      animation: widget.focusNode,
      builder: (ctx, _) => AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) => RelativePopupHost(
          builder: (ctx) => TextFormField(
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: waypointData ?? widget.hintText,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixText:
                  _airportsByIcao[widget.controller.text.trim()]?.description,
              suffixIcon: widget.focusNode.hasFocus && widget.showConfirmButton
                  ? InkWell(
                      child: const Icon(Icons.done),
                      onTap: () => FocusScope.of(context).unfocus(),
                    )
                  : null,
            ),
            onTap: () {
              if (popupController != null) return;
              popupController = showRelativePopup(
                ctx,
                builder: (ctx, rect) => Positioned(
                  top: rect.bottom,
                  left: rect.left,
                  width: rect.right - rect.left,
                  child: StatefulBuilder(
                    builder: (ctx, setState) {
                      popupStateSetter = setState;
                      return airportsPopup();
                    },
                  ),
                ),
              );
            },
            focusNode: widget.focusNode,
            controller: widget.controller,
          ),
        ),
      ),
    );
  }
}
