import 'package:flutter/material.dart';

import 'expansions/context_expansion.dart';
import 'expansions/error_expansion.dart';
import 'expansions/message_expansion.dart';
import 'expansions/reactive_expansion.dart';
import 'expansions/text_editing_expansion.dart';

abstract class BasePresenter {
  void initState() {}

  @protected
  void notify([void Function()? fun]);

  @mustCallSuper
  void dispose() {}
}

abstract class BaseCompletePresenter extends BasePresenter
    with
        ReactivePresenterExpansion,
        TextEditingPresenterExpansion,
        ErrorPresenterExpansion,
        MessagePresenterExpansion,
        ContextPresenterExpansion {}
