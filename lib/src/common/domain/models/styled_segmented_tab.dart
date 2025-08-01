class StyledSegmentedTab {
  final String label;
  final bool showBadge;
  final String key;
  final String? icon;

  const StyledSegmentedTab({
    required this.key,
    required this.label,
    this.showBadge = false,
    this.icon,
  });
}
