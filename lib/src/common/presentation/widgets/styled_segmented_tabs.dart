import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StyledSegmentedTabs extends StatefulWidget {
  final List<StyledSegmentedTab> tabs;
  final int currentIndex;
  final void Function(int index) onTabChanged;
  final double? height;
  final Color? backgroundColor;
  final TabController? tabController;
  final bool isScrollable;
  final double fontSize;
  final bool showSelectedColor;

  const StyledSegmentedTabs({
    required this.tabs,
    required this.currentIndex,
    required this.onTabChanged,
    this.height = 40.0,
    super.key,
    this.backgroundColor,
    this.tabController,
    this.isScrollable = false,
    this.showSelectedColor = true,
    this.fontSize = 14.0,
  });

  @override
  State<StyledSegmentedTabs> createState() => _StyledSegmentedTabsState();
}

class _StyledSegmentedTabsState extends State<StyledSegmentedTabs>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  List<StyledSegmentedTab> get tabs => widget.tabs;

  @override
  void initState() {
    super.initState();
    tabController = widget.tabController ??
        TabController(
          length: widget.tabs.length,
          vsync: this,
          initialIndex: widget.currentIndex,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: TabBar(
          tabAlignment:
              widget.isScrollable ? TabAlignment.start : TabAlignment.fill,
          isScrollable: widget.isScrollable,
          dividerHeight: 0,
          splashBorderRadius: BorderRadius.circular(16.0),
          controller: tabController,
          tabs: List.generate(tabs.length, (index) {
            final isSelected = tabController.index == index;
            return Tab(
              key: Key(tabs[index].key),
              child: _buildTabChild(
                tabs[index].label,
                showBadge: tabs[index].showBadge,
                isSelected: isSelected,
                icon: tabs[index].icon,
                index: index,
              ),
            );
          }),
          indicatorColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: context.theme.primaryColor,
          ),
          indicatorWeight: 0,
          labelColor: Colors.white,
          unselectedLabelColor: !widget.showSelectedColor
              ? context.theme.primaryColor
              : context.isDarkMode
                  ? Colors.grey.shade400
                  : Colors.grey.shade900,
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
          labelStyle: TextStyle(fontSize: widget.fontSize),
          unselectedLabelStyle: TextStyle(fontSize: widget.fontSize),
          onTap: widget.onTabChanged,
        ),
      ),
    );
  }

  Widget _buildTabChild(
    String label, {
    bool showBadge = false,
    bool isSelected = false,
    String? icon,
    required int index,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: widget.height! - 8,
      alignment: Alignment.center,
      decoration: widget.showSelectedColor && !isSelected
          ? BoxDecoration(
              color: context.isDarkMode
                  ? Colors.grey.shade900
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (index != 0 && icon != null) ...[
            SvgPicture.asset(
              icon,
              height: 16,
              width: 16,
              colorFilter: ColorFilter.mode(
                isSelected ? Colors.white : context.theme.iconTheme.color!,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(label),
          ),
          if (showBadge) ...[
            const SizedBox(width: 4),
            Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                color: context.theme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
