import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_badge_cubit.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_badge_state.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:frontend/features/notifications/presentation/widgets/notification_badge.dart';
import 'package:frontend/features/notifications/presentation/widgets/notification_popup.dart';

class NotificationBellWithPopup extends StatefulWidget {
  const NotificationBellWithPopup({super.key});

  @override
  State<NotificationBellWithPopup> createState() =>
      _NotificationBellWithPopupState();
}

class _NotificationBellWithPopupState extends State<NotificationBellWithPopup> {
  bool _isPopupVisible = false;
  final GlobalKey _bellKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // Load unread count when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationBadgeCubit>().loadUnreadCount();
      context.read<NotificationCubit>().loadNotifications();
    });
  }

  void _togglePopup() {
    if (_isPopupVisible) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _closePopup() {
    _removeOverlay();
  }

  void _showOverlay() {
    final renderBox = _bellKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context);
    if (renderBox == null || overlay == null) return;

    // Preserve existing cubit providers for the overlay so Inherited widgets
    // (BlocProviders) remain available to the popup's subtree.
    final notificationCubit = context.read<NotificationCubit>();
    final badgeCubit = context.read<NotificationBadgeCubit>();

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    // Compute responsive popup size and clamp to screen
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final double maxPopupWidth = 360.0;
    final double maxPopupHeight = 500.0;
    final double horizontalMargin = 8.0;

    final popupWidth = screenWidth - (horizontalMargin * 2) < maxPopupWidth
        ? screenWidth - (horizontalMargin * 2)
        : maxPopupWidth;

    // By default show below the bell; if not enough space, show above
    double proposedTop = offset.dy + size.height + AppDimensions.spacingSm;
    double availableBelow = screenHeight - proposedTop - horizontalMargin;
    double popupHeight = availableBelow >= maxPopupHeight
        ? maxPopupHeight
        : (availableBelow > 120 ? availableBelow : maxPopupHeight);

    if (availableBelow < 180) {
      // Not enough space below; try placing above
      final proposedAboveTop = offset.dy - AppDimensions.spacingSm - maxPopupHeight;
      if (proposedAboveTop > horizontalMargin) {
        proposedTop = proposedAboveTop;
        popupHeight = maxPopupHeight;
      } else {
        // Clamp to fit on screen
        proposedTop = horizontalMargin;
        popupHeight = screenHeight - (horizontalMargin * 2);
      }
    }

    double left = offset.dx;
    if (left + popupWidth + horizontalMargin > screenWidth) {
      left = screenWidth - popupWidth - horizontalMargin;
    }
    if (left < horizontalMargin) left = horizontalMargin;

    _overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        left: left,
        top: proposedTop,
        width: popupWidth,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Scrim to close when tapping outside
              Positioned.fill(
                child: GestureDetector(
                  onTap: _removeOverlay,
                  child: Container(color: Colors.transparent),
                ),
              ),
              // The popup itself; re-provide cubits via .value to the overlay
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: popupWidth,
                  height: popupHeight,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: notificationCubit),
                      BlocProvider.value(value: badgeCubit),
                    ],
                    child: NotificationPopup(onClose: _removeOverlay),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

    overlay.insert(_overlayEntry!);
    setState(() => _isPopupVisible = true);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isPopupVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Bell button
        GestureDetector(
          key: _bellKey,
          onTap: _togglePopup,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _togglePopup,
              borderRadius: BorderRadius.circular(50),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingXs),
                child: Stack(
                  children: [
                    Icon(
                      Icons.notifications_none_outlined,
                      color: colorScheme.onSurfaceVariant,
                      size: AppDimensions.iconAppBar,
                    ),
                    // Badge
                    BlocBuilder<NotificationBadgeCubit, NotificationBadgeState>(
                      builder: (context, state) {
                        return NotificationBadge(count: state.unreadCount);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // (OverlayEntry handles popup and scrim)
      ],
    );
  }
}
