import 'dart:math';

import 'package:flutter/material.dart';

class PieChart extends StatelessWidget {
  const PieChart({Key? key, required int winCount, required int totalPlayed, required double radius})
      : _winCount = winCount,
        _totalPlayed = totalPlayed,
        _radius = radius,
        super(key: key);

  final int _winCount;
  final int _totalPlayed;
  final double _radius;

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Container(
        height: _radius,
        width: _radius,
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.grey),
          shape: BoxShape.circle,
          gradient: SweepGradient(
              colors: [Colors.green.shade700, Colors.green.shade100],
              stops: [_winCount / _totalPlayed, _winCount / _totalPlayed],
              transform: const GradientRotation(-pi / 2)),
        ),
      ),
      Container(
          alignment: Alignment.center,
          height: _radius - 20,
          width: _radius - 20,
          decoration: const BoxDecoration(
            // border: Border.all(color: Colors.grey),
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Text('${(_winCount / _totalPlayed * 100).toStringAsFixed(1)} %')),
    ]);
  }
}
