import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:picapool/models/product_model.dart';
import 'package:picapool/utils/theme.dart';

class SelectableWidget extends StatefulWidget {
  final int quantity;
  final Function(int) onQuantityChange;
  final Product product;
  const SelectableWidget({
    super.key,
    required this.quantity,
    required this.onQuantityChange,
    required this.product,
  });

  @override
  State<SelectableWidget> createState() => _SelectableWidgetState();
}

class _SelectableWidgetState extends State<SelectableWidget> {
  TextTheme get textTheme => Theme.of(context).textTheme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        if (widget.quantity == 0) {
          widget.onQuantityChange(widget.quantity + 1);
        }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: (widget.product.images.firstOrNull == null)
                  ? Image.asset(
                      "assets/dominos/Margherita Pizza.png",
                      width: 80,
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: widget.product.images.first,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.product.name,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
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
                  const SizedBox(height: 5),
                  Text.rich(
                    TextSpan(
                      text: "₹ ${widget.product.offerPrice}",
                      style: textTheme.bodySmall,
                      children: <TextSpan>[
                        const TextSpan(
                          text: ' M.R.P. ',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'MontserratR',
                            color: Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: "₹ ${widget.product.mrp}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'MontserratR',
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
