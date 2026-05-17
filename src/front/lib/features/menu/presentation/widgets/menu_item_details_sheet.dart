import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/menu/domain/entities/menu_item_entity.dart';
import 'package:frontend/features/widgets/app_network_image.dart';

class MenuItemDetailsSheet extends StatelessWidget {
  const MenuItemDetailsSheet({super.key, required this.item, this.onAddToCart});

  final MenuItemEntity item;
  final Future<void> Function(int quantity)? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200, minHeight: 720),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingXl),
                  child: isWide
                      ? Row(
                          children: [
                            Expanded(flex: 5, child: _ImagePanel(item: item)),
                            const SizedBox(width: AppDimensions.spacingXl),
                            Expanded(
                              flex: 4,
                              child: _DetailsPanel(
                                item: item,
                                onAddToCart: onAddToCart,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _ImagePanel(item: item),
                            const SizedBox(height: AppDimensions.spacingXl),
                            _DetailsPanel(item: item, onAddToCart: onAddToCart),
                          ],
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ImagePanel extends StatelessWidget {
  const _ImagePanel({required this.item});

  final MenuItemEntity item;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: AppNetworkImage(
        imageUrl: item.imageUrl ?? 'https://via.placeholder.com/300',
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
    );
  }
}

class _DetailsPanel extends StatefulWidget {
  const _DetailsPanel({required this.item, required this.onAddToCart});

  final MenuItemEntity item;
  final Future<void> Function(int quantity)? onAddToCart;

  @override
  State<_DetailsPanel> createState() => _DetailsPanelState();
}

class _DetailsPanelState extends State<_DetailsPanel> {
  int quantity = 1;
  bool _isSubmitting = false;

  Future<void> _handleAddToCart() async {
    final addToCart = widget.onAddToCart;
    if (addToCart == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await addToCart(quantity);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final total = widget.item.price * quantity;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SelectableText(
                  widget.item.title,
                  style: textTheme.headlineLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMd,
                  vertical: AppDimensions.paddingSm,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMax),
                ),
                child: SelectableText(
                  '\$${widget.item.price.toStringAsFixed(2)}',
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Wrap(
            spacing: AppDimensions.spacingSm,
            runSpacing: AppDimensions.spacingSm,
            children: [
              _Chip(text: widget.item.available ? 'Available' : 'Unavailable'),
              _Chip(text: widget.item.categoryId),
              _Chip(text: 'Item ID: ${widget.item.id}'),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXl),
          SelectableText(
            widget.item.description ?? "No description available",
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXxl),
          SelectableText('Quantity', style: textTheme.headlineMedium),
          const SizedBox(height: AppDimensions.spacingMd),
          Row(
            children: [
              _QuantityButton(
                icon: Icons.remove,
                onTap: quantity > 1 ? () => setState(() => quantity--) : null,
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              SelectableText('$quantity', style: textTheme.headlineMedium),
              const SizedBox(width: AppDimensions.spacingMd),
              _QuantityButton(
                icon: Icons.add,
                onTap: () => setState(() => quantity++),
                filled: true,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXxl),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText('Total price', style: textTheme.labelLarge),
                  SelectableText(
                    '\$${total.toStringAsFixed(2)}',
                    style: textTheme.headlineLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: widget.item.available && !_isSubmitting
                      ? _handleAddToCart
                      : null,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Add to Cart'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.paddingSm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMax),
      ),
      child: SelectableText(text, style: textTheme.labelLarge),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: filled
              ? colorScheme.primary
              : colorScheme.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: filled ? colorScheme.onPrimary : colorScheme.onSurface,
        ),
      ),
    );
  }
}
