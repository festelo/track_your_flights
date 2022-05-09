import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef PresenterWidget = StatefulHookConsumerWidget;

abstract class PresenterState<T extends ConsumerStatefulWidget>
    extends ConsumerState<T> {
  void notify() => mounted ? setState(() {}) : null;
}
