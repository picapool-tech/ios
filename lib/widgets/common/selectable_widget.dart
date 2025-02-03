import 'package:flutter/material.dart';
import 'package:picapool/utils/theme.dart';

class SelectableWidget extends StatefulWidget {
  final int quantity;
  final Function(int) onQuantityChange;
  final Widget child;
  const SelectableWidget({
    super.key,
    required this.quantity,
    required this.onQuantityChange,
    required this.child,
  });

  @override
  State<SelectableWidget> createState() => _SelectableWidgetState();
}

class _SelectableWidgetState extends State<SelectableWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        widget.onQuantityChange(widget.quantity + 1);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: widget.quantity > 0
              ? Border.all(
                  color: AppTheme.light.primaryColor,
                  width: 2,
                )
              : null,
        ),
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: widget.child,
            ),
            if (widget.quantity > 0)
              quantityButton()
            else
              FilledButton.tonal(
                onPressed: () {
                  widget.onQuantityChange(widget.quantity + 1);
                },
                child: const Text('Add'),
              ),
          ],
        ),
      ),
    );
  }

  Widget quantityButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            if (widget.quantity > 0) {
              widget.onQuantityChange(widget.quantity - 1);
            }
          },
        ),
        Text(widget.quantity.toString()),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            widget.onQuantityChange(widget.quantity + 1);
          },
        ),
      ],
    );
  }
}
