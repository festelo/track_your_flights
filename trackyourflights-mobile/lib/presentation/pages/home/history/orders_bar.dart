import 'package:flutter/material.dart';
import 'package:trackyourflights/domain/entities/order.dart';
import 'package:trackyourflights/presentation/pages/home/history/orders_presenter.dart';
import 'package:trackyourflights/presentation/pages/home/history/orders_state.dart';
import 'package:trackyourflights/presentation/pages/order_details/order_details.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';

import 'widgets/order_tile.dart';

const _orderOpeningTransitionDuration = Duration(milliseconds: 400);
const _orderScrollTransitionDuration = Duration(milliseconds: 200);

class OrdersBar extends PresenterWidget {
  const OrdersBar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OrdersBarState();
}

class _OrdersBarState extends PresenterState<OrdersBar>
    with SingleTickerProviderStateMixin {
  ProviderBase<OrdersPresenter> get presenter => ordersContainer.actions;

  ProviderBase<OrdersState> get state => ordersContainer.state;

  final ScrollController _scrollController = ScrollController();

  Animation<double> get _hidingOrderTileAnimation => TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0).chain(
            CurveTween(curve: Curves.easeOutCubic),
          ),
          weight: 0.5,
        ),
        TweenSequenceItem(
          tween: ConstantTween(0),
          weight: 0.5,
        ),
      ]).animate(_openingOrderTileAnimationController);

  Animation<double> get _showingOrderDetailsAnimation => TweenSequence<double>([
        TweenSequenceItem(
          tween: ConstantTween(0),
          weight: 0.5,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: Curves.easeInCubic),
          ),
          weight: 0.5,
        ),
      ]).animate(_openingOrderTileAnimationController);

  late final AnimationController _openingOrderTileAnimationController =
      AnimationController(
    vsync: this,
    duration: _orderOpeningTransitionDuration,
  );

  var _openingOrderTile = false;
  Order? closingOrder;

  Future<void> scrollTo({
    required BuildContext orderTileContext,
    required Order order,
  }) async {
    final scrollable = Scrollable.of(orderTileContext)!;
    final extentBefore = scrollable.position.extentBefore;

    final renderObject = orderTileContext.findRenderObject();
    final matrix =
        renderObject?.getTransformTo(scrollable.context.findRenderObject());
    final rect = MatrixUtils.transformRect(matrix!, renderObject!.paintBounds);

    setState(() {
      _openingOrderTile = true;
    });
    ref.read(presenter).selectOrder(order);
    _openingOrderTileAnimationController.forward();
    await scrollable.position.animateTo(
      rect.top + extentBefore,
      duration: _orderScrollTransitionDuration,
      curve: Curves.easeOutCubic,
    );
    setState(() => _openingOrderTile = false);
  }

  void closeOrder() async {
    closingOrder = ref.read(state).selectedOrder;
    ref.read(presenter).unselectOrder();
    setState(() {});
    await _openingOrderTileAnimationController.reverse();
    closingOrder = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final openedOrder = ref.watch(state).selectedOrder;
    return CompleteBridge(
      presenter: ref.watch(presenter),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                ),
              ),
            ),
            child: Row(
              children: [
                AnimatedSize(
                  duration: _orderOpeningTransitionDuration,
                  curve: Curves.easeOutCubic,
                  child: SizedBox(
                    width: openedOrder == null ? 0 : null,
                    child: Visibility(
                      visible: openedOrder != null,
                      child: IconButton(
                        onPressed: closeOrder,
                        icon: const Icon(Icons.arrow_back_ios),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    openedOrder == null ? 'Orders history' : 'Order details',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                AnimatedSize(
                  duration: _orderOpeningTransitionDuration,
                  curve: Curves.easeOutCubic,
                  child: openedOrder == null
                      ? IconButton(
                          onPressed: ref.watch(presenter).addOrder,
                          iconSize: 26,
                          icon: const Icon(Icons.add),
                        )
                      : InkWell(
                          onTap: () {},
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                iconSize: 26,
                                icon: const Icon(Icons.add),
                              ),
                              const Text(
                                'Add flight',
                                textAlign: TextAlign.left,
                                maxLines: 1,
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                        ),
                ),
                AnimatedSize(
                  duration: _orderOpeningTransitionDuration,
                  curve: Curves.easeOutCubic,
                  child: SizedBox(
                    width: openedOrder == null ? 0 : null,
                    child: Visibility(
                      visible: openedOrder != null,
                      child: InkWell(
                        onTap: () {},
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              iconSize: 18,
                              icon: const Icon(Icons.edit),
                            ),
                            const Text(
                              'Change order',
                              textAlign: TextAlign.left,
                              maxLines: 1,
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                IgnorePointer(
                  ignoring: openedOrder != null,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: ref.watch(state).orders?.length ?? 0,
                    physics: _openingOrderTile
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    itemBuilder: (context, i) => Builder(
                      builder: (context) => FadeTransition(
                        opacity: openedOrder == ref.watch(state).orders![i] ||
                                closingOrder == ref.watch(state).orders![i]
                            ? const AlwaysStoppedAnimation(1)
                            : _hidingOrderTileAnimation,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: GestureDetector(
                            onTap: () => scrollTo(
                              orderTileContext: context,
                              order: ref.watch(state).orders![i],
                            ),
                            behavior: HitTestBehavior.opaque,
                            child: OrderTile(
                              order: ref.watch(state).orders![i],
                              onFlightEdit: (f) => ref
                                  .watch(presenter)
                                  .changeOrderFlight(
                                      ref.watch(state).orders![i].id, f),
                              onFlightSearchCancel: (f) => ref
                                  .watch(presenter)
                                  .cancelOrderFlightSearch(f),
                              onFlightSearchApply: (f) => ref
                                  .watch(presenter)
                                  .applyOrderFlightSearch(
                                      ref.watch(state).orders![i].id, f),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: _showingOrderDetailsAnimation,
                  child: openedOrder == null
                      ? Container()
                      : OrderDetails(
                          order: openedOrder!,
                          onFlightEdit: (f) => ref
                              .watch(presenter)
                              .changeOrderFlight(openedOrder!.id, f),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
