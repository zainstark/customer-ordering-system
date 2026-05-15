import 'package:flutter/material.dart';
import 'package:frontend/Core/router/routes.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:go_router/go_router.dart';

class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({
    super.key,
    required this.currentPath,
    required this.child,
  });

  final String currentPath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    return Scaffold(
      body: Column(
        children: [
          _ShellTopBar(currentPath: currentPath),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : _ShellBottomNavBar(currentPath: currentPath),
    );
  }
}

class _ShellTopBar extends StatelessWidget {
  const _ShellTopBar({required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingXl,
        vertical: AppDimensions.paddingMd,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: .4),
          ),
        ),
      ),
      child: Row(
        children: [
          SelectableText(
            'Whatever',
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const Spacer(),
          if (isDesktop) ...[
            _TopNavItem(
              label: 'Menu',
              selected: currentPath == RoutesPath.menu,
              onTap: () => context.replace(RoutesPath.menu),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            _TopNavItem(
              label: 'Orders',
              selected: currentPath == RoutesPath.orders,
              onTap: () => context.replace(RoutesPath.orders),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            _TopNavItem(
              label: 'Cart',
              selected: currentPath == RoutesPath.cart,
              onTap: () => context.replace(RoutesPath.cart),
            ),
            const SizedBox(width: AppDimensions.spacingLg),
          ],
          Icon(
            Icons.notifications_none_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          CircleAvatar(
            radius: AppDimensions.avatarSizeSm / 2,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(
              Icons.person_outline,
              color: colorScheme.onPrimaryContainer,
              size: AppDimensions.iconSm,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopNavItem extends StatelessWidget {
  const _TopNavItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.paddingSm,
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ShellBottomNavBar extends StatelessWidget {
  const _ShellBottomNavBar({required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    final paths = <String>[RoutesPath.menu, RoutesPath.orders, RoutesPath.cart];
    final selectedIndex = paths.contains(currentPath)
        ? paths.indexOf(currentPath)
        : 0;

    return NavigationBar(
      selectedIndex: selectedIndex,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
        NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Orders'),
        NavigationDestination(
          icon: Icon(Icons.shopping_bag_outlined),
          label: 'Cart',
        ),
      ],
      onDestinationSelected: (index) => context.go(paths[index]),
    );
  }
}
