
class NavDestination {
  final String label;
  final String icon;
  final String? activeIcon;
  final int? index;

  const NavDestination({
    required this.label,
    required this.icon,
    this.activeIcon,
    this.index,
  });
}
