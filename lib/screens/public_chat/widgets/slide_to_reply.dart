import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SlideToReplyWidget extends StatefulWidget {
  final VoidCallback onSlideComplete;
  final Widget label;
  final Color backgroundColor;
  final Color thumbColor;
  final IconData icon;
  final double width;
  final double height;

  const SlideToReplyWidget({
    super.key,
    required this.onSlideComplete,
    required this.label,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.thumbColor = Colors.blueAccent,
    this.icon = Icons.reply,
    this.width = 300,
    this.height = 70,
  });

  @override
  State<SlideToReplyWidget> createState() => _SlideToReplyWidgetState();
}

class _SlideToReplyWidgetState extends State<SlideToReplyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _resetController;
  double _dragX = 0;
  late double _maxDrag;
  bool _triggered = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            // color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 24),
          child: widget.label,
        ),
        Positioned(
          left: _dragX,
          top: 0,
          bottom: 0,
          child: GestureDetector(
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: Container(
              width: widget.height,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.thumbColor,
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _maxDrag = widget.width - widget.height;
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(() {
        setState(() {
          _dragX = _dragX * (1 - _resetController.value);
        });
      });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragX >= _maxDrag * 0.9 && !_triggered) {
      _triggered = true;
      HapticFeedback.mediumImpact();
      widget.onSlideComplete();
    }

    _resetController.forward(from: 0).then((_) {
      setState(() {
        _dragX = 0;
        _triggered = false;
      });
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragX += details.delta.dx;

      // Elastic drag effect beyond max drag
      if (_dragX > _maxDrag) {
        _dragX = _maxDrag + (_dragX - _maxDrag) * 0.2;
      } else if (_dragX < 0) {
        _dragX = 0;
      }
    });
  }
}
