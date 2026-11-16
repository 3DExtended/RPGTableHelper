import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';

/// One page in a [PageTabStrip].
class PageTabStripItem {
  const PageTabStripItem({required this.label, this.iconBuilder});

  final String label;

  /// Optional icon in front of the label, e.g. a tab icon the player chose.
  final Widget Function(Color color)? iconBuilder;
}

/// Page navigation with names for phones, shown under the [Navbar]
/// (UX test 2026-11-16, B8 / SP-5).
///
/// Every page gets its name. A small diamond under the name marks the
/// current page, like the diamond row on tablets. When the names do not fit,
/// the row scrolls sideways, keeps the current page in view and fades out at
/// the edge that has more. With [pinLastItem] the last page (the notes) stays
/// visible at the right end in any case.
class PageTabStrip extends StatefulWidget {
  const PageTabStrip({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    this.onLongPress,
    this.pinLastItem = false,
  });

  final List<PageTabStripItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final ValueChanged<int>? onLongPress;
  final bool pinLastItem;

  /// Key of the tab for the page at [index], for tests.
  static ValueKey<String> tabKey(int index) => ValueKey('pageTab-$index');

  @override
  State<PageTabStrip> createState() => _PageTabStripState();
}

class _PageTabStripState extends State<PageTabStrip> {
  final ScrollController _scrollController = ScrollController();
  List<GlobalKey> _tabKeys = [];
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _syncKeys();
    _scrollCurrentIntoViewAfterLayout(animate: false);
  }

  @override
  void didUpdateWidget(covariant PageTabStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncKeys();
    if (oldWidget.currentIndex != widget.currentIndex ||
        oldWidget.items.length != widget.items.length) {
      _scrollCurrentIntoViewAfterLayout(animate: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _syncKeys() {
    if (_tabKeys.length != widget.items.length) {
      _tabKeys = List.generate(widget.items.length, (_) => GlobalKey());
    }
  }

  void _scrollCurrentIntoViewAfterLayout({required bool animate}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final index = widget.currentIndex;
      if (index < 0 || index >= _tabKeys.length) return;
      final tabContext = _tabKeys[index].currentContext;
      if (tabContext == null || !_scrollController.hasClients) return;
      // The pinned tab is not inside the scroll view.
      if (widget.pinLastItem && index == widget.items.length - 1) return;
      Scrollable.ensureVisible(
        tabContext,
        alignment: 0.5,
        duration: animate ? const Duration(milliseconds: 200) : Duration.zero,
        curve: Curves.easeOut,
      );
    });
  }

  bool _updateScrollHints(ScrollMetrics metrics) {
    final canLeft = metrics.pixels > metrics.minScrollExtent + 1;
    final canRight = metrics.pixels < metrics.maxScrollExtent - 1;
    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) return const SizedBox.shrink();

    final pinnedIndex = widget.pinLastItem && items.length > 1
        ? items.length - 1
        : null;
    final scrollingIndices = [
      for (var i = 0; i < items.length; i++)
        if (i != pinnedIndex) i,
    ];

    final background = navbarBackgroundColor(context);
    final foreground = navbarForegroundColor(context);

    Widget scrollingTabs = LayoutBuilder(
      builder: (context, constraints) {
        return NotificationListener<ScrollMetricsNotification>(
          onNotification: (n) => _updateScrollHints(n.metrics),
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) => _updateScrollHints(n.metrics),
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    // Few pages: spread them over the whole width.
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (final i in scrollingIndices) _buildTab(context, i),
                      ],
                    ),
                  ),
                ),
                if (_canScrollLeft) _edgeFade(background, alignLeft: true),
                if (_canScrollRight) _edgeFade(background, alignLeft: false),
              ],
            ),
          ),
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(child: scrollingTabs),
          if (pinnedIndex != null) ...[
            Container(
              width: 1,
              height: 22,
              color: foreground.withValues(alpha: 0.3),
            ),
            _buildTab(context, pinnedIndex),
          ],
        ],
      ),
    );
  }

  Widget _edgeFade(Color background, {required bool alignLeft}) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: alignLeft ? 0 : null,
      right: alignLeft ? null : 0,
      width: 24,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
              end: alignLeft ? Alignment.centerRight : Alignment.centerLeft,
              colors: [background, background.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index) {
    final item = widget.items[index];
    final selected = index == widget.currentIndex;
    final decorated = isDecoratedSheetSkinActive(context);
    final accent = ledgerNavbarAccent(context);
    final foreground = navbarForegroundColor(context);
    final color = selected ? accent : foreground.withValues(alpha: 0.85);

    Widget tab = CupertinoButton(
      key: PageTabStrip.tabKey(index),
      padding: EdgeInsets.zero,
      minimumSize: const Size(44, 44),
      onPressed: () => widget.onSelected(index),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(7, 8, 7, 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.iconBuilder != null) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: FittedBox(child: item.iconBuilder!(color)),
                  ),
                  const SizedBox(width: 5),
                ],
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: color,
                      fontSize: decorated ? 16 : 14,
                      fontFamily: decorated ? 'Ruwudu' : null,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            CustomPaint(
              size: const Size(7, 7),
              painter: _TabDiamondPainter(
                color: selected ? accent : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.onLongPress != null) {
      tab = GestureDetector(
        onLongPress: () => widget.onLongPress!(index),
        child: tab,
      );
    }

    return Semantics(key: _tabKeys[index], selected: selected, child: tab);
  }
}

/// The small diamond under the name of the current page.
class _TabDiamondPainter extends CustomPainter {
  _TabDiamondPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (color.a == 0) return;
    final c = Offset(size.width / 2, size.height / 2);
    final r = min(size.width, size.height) / 2;
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r, c.dy)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r, c.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TabDiamondPainter oldDelegate) =>
      oldDelegate.color != color;
}
