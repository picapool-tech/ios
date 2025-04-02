import 'dart:async';

import 'package:flutter/material.dart';
import 'package:picapool/utils/date_time_helper.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime expiryTime;
  final TextStyle? style;
  final Color? warningColor;
  final VoidCallback? onExpired;

  const CountdownTimer({
    Key? key,
    required this.expiryTime,
    this.style,
    this.warningColor,
    this.onExpired,
  }) : super(key: key);

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  late Duration _remainingTime;
  bool _isExpired = false;

  String get _formattedTime {
    if (_isExpired) return "Expired";
    return DateTimeHelper.formatDateTimeExpiry(widget.expiryTime);
  }

  @override
  Widget build(BuildContext context) {
    // Different warning levels based on timeframe
    final isUrgent = _remainingTime.inMinutes < 30 && !_isExpired;
    final isWarning = _remainingTime.inHours < 24 && !isUrgent && !_isExpired;
    final isNearing =
        _remainingTime.inDays < 7 && !isWarning && !isUrgent && !_isExpired;

    final baseStyle = widget.style ?? const TextStyle();
    final warningColor = widget.warningColor ?? Colors.red;

    return Text(
      _formattedTime,
      key: ValueKey(
          _formattedTime), // Add a key to force rebuild when text changes
      style: baseStyle.copyWith(
        color: _isExpired
            ? Colors.grey
            : (isUrgent
                ? warningColor
                : (isWarning
                    ? Colors.orange
                    : (isNearing ? Colors.blue : baseStyle.color))),
        fontWeight:
            isUrgent || isWarning ? FontWeight.bold : baseStyle.fontWeight,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startTimer();
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    _remainingTime = widget.expiryTime.difference(now);
    _isExpired = _remainingTime.isNegative;

    if (_isExpired && widget.onExpired != null) {
      widget.onExpired!();
    }
  }

  Duration _getUpdateInterval() {
    if (_remainingTime.inDays > 30) {
      return const Duration(minutes: 15); // Every 15 minutes if > 30 days
    } else if (_remainingTime.inDays > 7) {
      return const Duration(minutes: 5); // Every 5 minutes if > 7 days
    } else if (_remainingTime.inDays > 1) {
      return const Duration(minutes: 2); // Every 2 minutes if > 1 day
    } else if (_remainingTime.inHours > 1) {
      return const Duration(minutes: 1); // Every minute if > 1 hour
    } else {
      return const Duration(seconds: 1); // Every second for the final hour
    }
  }

  void _startTimer() {
    // Cancel any existing timer
    _timer?.cancel();

    // Determine update frequency based on remaining time
    final interval = _getUpdateInterval();

    // Use a simpler timer approach
    _timer = Timer.periodic(interval, (timer) {
      if (mounted) {
        setState(() {
          _calculateRemainingTime();

          // If expired, cancel the timer
          if (_isExpired) {
            timer.cancel();
          }

          // Only change intervals for significant changes (avoid rapid restarts)
          final newInterval = _getUpdateInterval();
          if (newInterval.inSeconds > interval.inSeconds * 2 ||
              newInterval.inSeconds < interval.inSeconds / 2) {
            timer.cancel();
            _startTimer();
          }
        });
      }
    });
  }
}
